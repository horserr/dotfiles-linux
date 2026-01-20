# ---------------------------------------------------------
# 配置与缓存
# ---------------------------------------------------------
$Completions = @{
  "gh"        = @("completion", "-s", "powershell")
  "uv"        = @("generate-shell-completion", "powershell")
  "tailscale" = @("completion", "powershell")
  "kubectl"   = @("completion", "powershell")
}

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

  # 2. 静默加载模块，不输出任何内容
  # no need to import posh-git
  $modules = @("WSLTabCompletion", "DockerCompletion")
  foreach ($m in $modules) {
    if (!(Get-Module $m)) {
      Import-Module $m -ErrorAction SilentlyContinue | Out-Null
    }
  }

  Import-Completion -CmdName "uv" -ArgsList $Completions.uv
  Import-Completion -CmdName "tailscale" -ArgsList $Completions.tailscale
  Import-Completion -CmdName "kubectl" -ArgsList $Completions.kubectl

  # fixme dont know why
  # Import-Completion -CmdName "gh" -ArgsList $Completions.gh
  gh completion -s powershell | Out-String | Invoke-Expression
}

# 注册一个引擎事件：在提示符准备就绪后运行
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action $PostStartTask | Out-Null