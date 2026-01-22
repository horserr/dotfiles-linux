# [Environment]::SetEnvironmentVariable($Name, $Value, "User")

$global:PS_CACHE_ROOT = Join-Path $env:TEMP "pwsh_cache"
$env:PS_CACHE_ROOT = $global:PS_CACHE_ROOT # 同时存入环境变量，方便 Job 访问
if (!(Test-Path $global:PS_CACHE_ROOT)) { New-Item -ItemType Directory -Path $global:PS_CACHE_ROOT | Out-Null }

$env:EDITOR = 'nvim'

# 扩展 PATH
$newPath = @(
  "C:\Program Files (x86)\Microsoft\Edge\Application",
  "C:\Program Files\7-Zip",
  "C:\Program Files\Everything 1.5a"
)
$env:Path = ($newPath + $env:Path.Split(';')) -join ';'

# FZF 配置
$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border=rounded --preview 'bat --color=always --line-range :500 {}'"
$env:_ZO_FZF_OPTS = "--height 50% --border=rounded --layout=reverse --info=inline"


# Oh-My-Posh 初始化（带缓存）
$themeName = "multiverse-neon"
# $themeName = "catppuccin_mocha"
$PoshCache = "$global:PS_CACHE_ROOT/posh_$themeName.ps1"
if (!(Test-Path $PoshCache)) {
  oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/$themeName.omp.json" | Out-File $PoshCache
}
. $PoshCache

$PostStartTask = {
  Import-Module Terminal-Icons
}

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action $PostStartTask | Out-Null