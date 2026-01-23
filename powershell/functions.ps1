# 带参数的别名（需封装成函数，因为Set-Alias不支持参数）
function ll {
  if (!(Get-Module Terminal-Icons)) { Import-Module Terminal-Icons }
  Get-ChildItem -Force -Path $args[0]
}

function cd.. { Set-Location .. }                    # cd.. 快速回退目录
function conf { code (Split-Path -Parent $PSScriptRoot) }
function util {
  $command = "Invoke-RestMethod https://christitus.com/win | Invoke-Expression"
  powershell -NoProfile -Command $command
}
function myip { curl ifconfig.me }
function v { $Input | nvim - }                  # Get-Process | v

function gp {
  git push origin $(git branch --show-current)
}

function proxy-on {
  $env:HTTP_PROXY = "http://localhost:7897"
  $env:HTTPS_PROXY = "http://localhost:7897"
}

function e {
  Get-ChildItem . -Recurse -Attributes !Directory | `
    Invoke-Fzf | `
    ForEach-Object { nvim $_ }
}

function edit {
  Get-ChildItem . -Recurse -Attributes !Directory | `
    Invoke-Fzf | `
    ForEach-Object { code $_ }
}

function ex {
  param( [string]$Path = [Environment]::GetFolderPath('Desktop'))
  explorer.exe $Path
}

function env {
  rundll32 sysdm.cpl, EditEnvironmentVariables
}
function bios {
  Write-Host "You are going to restart computer and enter BIOS"
  Pause
  shutdown /r /fw /f /t 0
}

function which {
  param([string]$Path)
  Get-Command $Path | Select-Object source
}

# Update all ps resource
function up-all {
  Write-Host "正在全面更新 PowerShell 模块..." -ForegroundColor Yellow
  Update-PSResource -Force -AcceptLicense
  Write-Host "更新完成！" -ForegroundColor Green
}

function memo {
  Write-Host @"
Get-AppxPackage -Name *terminal*
(Get-MpPreference).ExclusionPath
Add-MpPreference -ExclusionPath "C:\MyFolder"
Remove-MpPreference -ExclusionPath "C:\MyFolder"
"@
}

function ssh-copy-id {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Target,  # 可以是 user@hostname，也可以是 config 里的别名

    [Parameter(ValueFromRemainingArguments = $true)]
    $AdditionalArgs   # 捕获所有其他参数，如 -p 2222 或 -i path/to/key
  )

  # 1. 自动定位公钥路径（优先使用 ed25519，通用使用 rsa）
  $publicKey = "$HOME/.ssh/id_rsa.pub"
  if (!(Test-Path $publicKey)) {
    $publicKey = "$HOME/.ssh/id_ed25519.pub"
  }

  if (!(Test-Path $publicKey)) {
    Write-Error "错误: 在 $HOME/.ssh/ 下未找到公钥文件 (id_rsa.pub 或 id_ed25519.pub)"
    return
  }

  Write-Host "正在将密钥 $publicKey 发送到 $Target..." -ForegroundColor Cyan

  # 2. 执行远程写入
  # 我们直接把 $Target 传给 ssh，ssh 会自动判断它是别名还是 user@host
  # $AdditionalArgs 允许你临时增加 -p 端口等参数
  Get-Content $publicKey | ssh $AdditionalArgs $Target "mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys"

  if ($LASTEXITCODE -eq 0) {
    Write-Host "成功！现在尝试使用 'ssh $Target' 连接。" -ForegroundColor Green
  }
  else {
    Write-Error "发送失败，请检查连接或密码。"
  }
}

function Get-FastSize {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
    [string]$Path = ".",
    [switch]$Raw
  )

  process {
    if (-not (Test-Path $Path)) { return 0 }
    $absPath = (Resolve-Path $Path).Path

    try {
      $totalBytes = 0
      # 优化：直接调用 .NET 方法获取 FileInfo 避免反复 New-Object
      $dirInfo = New-Object System.IO.DirectoryInfo($absPath)
      $files = $dirInfo.EnumerateFiles("*", [System.IO.SearchOption]::AllDirectories)

      foreach ($f in $files) {
        try { $totalBytes += $f.Length } catch { }
      }

      if ($Raw) { return $totalBytes }

      # 自动转换逻辑
      switch ($totalBytes) {
        { $_ -ge 1GB } { return "{0:N2} GB" -f ($_ / 1GB) }
        { $_ -ge 1MB } { return "{0:N2} MB" -f ($_ / 1MB) }
        { $_ -ge 1KB } { return "{0:N2} KB" -f ($_ / 1KB) }
        default { return "$_ Bytes" }
      }
    }
    catch {
      Write-Warning "无法完全访问路径: $absPath"
      return 0
    }
  }
}