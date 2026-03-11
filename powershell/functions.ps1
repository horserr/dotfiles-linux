# 带参数的别名（需封装成函数，因为Set-Alias不支持参数）
function ll {
  if (!(Get-Module Terminal-Icons)) { Import-Module Terminal-Icons }
  Get-ChildItem -Force -Path $args[0]
}

function cd.. { Set-Location .. }                    # cd.. 快速回退目录
function conf {
  &code (Split-Path -Parent $PSScriptRoot); exit
}
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

function edit-history{
  nvim (Get-PSReadLineOption).HistorySavePath
}

function startRclone {
  proxy-on
  Start-Process "rclone" -ArgumentList "mount od_drive:/ Z: --vfs-cache-mode full --vfs-read-chunk-size 64M --vfs-read-chunk-size-limit 256M --buffer-size 32M --transfers 16 --network-mode --vfs-cache-max-age 24h --vfs-cache-max-size 30G --vfs-write-back 5s --links"
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

function eventvwr {
  mmc.exe eventvwr.msc
}

function bios {
  Write-Host "You are going to restart computer and enter BIOS"
  Pause
  shutdown /r /fw /f /t 0
}

function winre {
  Write-Host "You are going to restart computer and enter Windows Recovery Environment"
  Pause
  shutdown /r /o /f /t 0
}

function quickshutdown {
  write-host "You are going to shutdown computer immediately"
  Pause
  shutdown /s /t 0
}

function download {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$m3u8link,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$output
  )
  yt-dlp.exe --downloader aria2c --downloader-args "aria2c: -x 16 -s 16 -k 1M" $m3u8link -o $output
}

function special {
  param(
    [Parameter(Position = 0)]
    [string]$Name
  )
  $folders = [Environment+SpecialFolder]::GetValues([Environment+SpecialFolder])

  if (-not [string]::IsNullOrWhiteSpace($Name)) {
    # 尝试匹配枚举名称（不区分大小写）
    if ($Name -in $folders) {
      $path = [Environment]::GetFolderPath($Name)
      if (-not [string]::IsNullOrWhiteSpace($path)) {
        Write-Host "正在打开: $path" -ForegroundColor Cyan
        explorer.exe $path
      }
      else {
        Write-Error "该特殊文件夹路径在当前系统中为空。"
      }
    }
    else {
      Write-Error "未找到名为 '$Name' 的特殊文件夹。请运行不带参数的 'special' 命令查看可用列表。"
    }
    return
  }

  $results = foreach ($folder in $folders) {
    [PSCustomObject]@{
      FolderName = $folder
      Path       = [Environment]::GetFolderPath($folder)
    }
  }

  # 过滤掉路径为空的项（有些文件夹在当前系统环境下可能不存在）并按表格显示
  # $results | Where-Object { $_.Path -ne "" } | Out-GridView -Title "所有特殊文件夹路径" # 如果想要弹窗查看
  $results | Where-Object { $_.Path -ne "" } | Format-Table -AutoSize
  Write-Host "use `special <FolderName>` to open the folder directly." -ForegroundColor DarkMagenta
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
  spf: superfile
  trip: trippy
  exhyperv

robocopy C:\Source D:\Destination /MIR /Z /XA:H /W:5 /R:3

Get-AppxPackage -Name *terminal*
(Get-MpPreference).ExclusionPath

Add-MpPreference -ExclusionPath "C:\MyFolder"
Remove-MpPreference -ExclusionPath "C:\MyFolder"

git rm --cached file.txt  ; # 从 Git 索引中移除但保留工作区文件
git restore --staged file.txt ; # 将暂存区的文件恢复到工作区

{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "registry-mirrors": [
    "https://35rtko0a.mirror.aliyuncs.com",
    "https://docker.m.daocloud.io"
  ]
}
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