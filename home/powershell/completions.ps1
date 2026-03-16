# ---------------------------------------------------------
# 配置与缓存
# ---------------------------------------------------------
$Completions = @{
  "uv"        = @("generate-shell-completion", "powershell")
  "uvx"       = @("--generate-shell-completion", "powershell")
  "tailscale" = @("completion", "powershell")
  "chezmoi" = @("completion", "powershell")
  "kubectl"   = @("completion", "powershell")
}
$modules = @("WSLTabCompletion", "DockerCompletion", "posh-cargo")

$CompletionCacheTtl = [TimeSpan]::FromDays(1)

function Update-CompletionCache {
  param(
    [string]$CmdName,
    [string[]]$ArgsList,
    [bool]$needRefresh = $false
  )

  $CacheFile = Join-Path $global:PS_CACHE_ROOT "completion_$CmdName.ps1"

  $needRefresh = -not (Test-Path $CacheFile)
  if (-not $needRefresh) {
    $lastWrite = (Get-Item $CacheFile).LastWriteTimeUtc
    $expiry = $lastWrite + $CompletionCacheTtl
    if ((Get-Date).ToUniversalTime() -gt $expiry) {
      $needRefresh = $true
    }
  }

  if ($needRefresh -and (Get-Command $CmdName -ErrorAction SilentlyContinue)) {
    try {
      & $CmdName @ArgsList | Out-File $CacheFile -Encoding utf8
    }
    catch {
      Write-Error "Failed to refresh completion for ${CmdName}: $_"
    }
  }

  return $CacheFile
}

function Import-Completion {
  param(
    [string]$CmdName,
    [string[]]$ArgsList
  )

  $cacheFile = Update-CompletionCache -CmdName $CmdName -ArgsList $ArgsList
  if (Test-Path $cacheFile) {
    . $cacheFile
  }
}

# 在 Profile 最后添加
$PostStartTask = {
  # zoxide
  $ZoxideCache = "$global:PS_CACHE_ROOT/zoxide_init.ps1"
  if (!(Test-Path $ZoxideCache)) {
    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
      zoxide init powershell | Out-File $ZoxideCache
    }
  }
  if (Test-Path $ZoxideCache) { . $ZoxideCache }

  # Winget 补全
  Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
      [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
  }

  # USBIPD 补全
  Register-ArgumentCompleter -Native -CommandName usbipd -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    usbipd [suggest:$cursorPosition] "$wordToComplete" | ForEach-Object {
      [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
  }

  # 1.
  $modules | ForEach-Object {
    Import-Module $_
  }

  # 2.
  foreach ($c in $Completions.Keys) {
    if (!(Get-Command $c -ErrorAction SilentlyContinue)) {
      continue
    }
    Import-Completion -CmdName $c -ArgsList $Completions[$c]
  }

  # 3.
  Get-ChildItem -Path "$PSScriptRoot/scripts/" -Filter "*_completion.ps1" | ForEach-Object {
    . $_.FullName
  }
}

# 注册一个引擎事件：在提示符准备就绪后运行
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action $PostStartTask | Out-Null