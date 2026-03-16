# [Environment]::SetEnvironmentVariable($Name, $Value, "User")

$global:PS_CACHE_ROOT = Join-Path $env:TEMP "pwsh_cache"
$env:PS_CACHE_ROOT = $global:PS_CACHE_ROOT # 同时存入环境变量，方便 Job 访问
if (!(Test-Path $global:PS_CACHE_ROOT)) { New-Item -ItemType Directory -Path $global:PS_CACHE_ROOT | Out-Null }

$env:EDITOR = 'nvim'

# 扩展 PATH
$newPath = @(
  "D:\path",
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

# 覆盖 oh-my-posh 自动生成的 prompt 函数
$oldPrompt = $function:prompt
function prompt {
  # 执行原有的 oh-my-posh 逻辑
  & $oldPrompt
  # 发送路径信息给 Windows Terminal
  $loc = $executionContext.SessionState.Path.CurrentLocation
  if ($loc.Provider.Name -eq "FileSystem") {
    # 构造 Windows Terminal 识别的 OSC 9;9 序列
    $path = $loc.ProviderPath
    Write-Host -NoNewline "$([char]27)]9;9;`"$path`"$([char]27)\"
  }
  return " " # 保持格式
}


# Starship 初始化
# Invoke-Expression (&starship init powershell)
# link: https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory#powershell-with-starship
# function Invoke-Starship-PreCommand {
#   $loc = $executionContext.SessionState.Path.CurrentLocation;
#   $prompt = "$([char]27)]9;12$([char]7)"
#   if ($loc.Provider.Name -eq "FileSystem") {
#     $prompt += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
#   }
#   $host.ui.Write($prompt)
# }

# direnv 初始化
Invoke-Expression "$(direnv hook pwsh)"

##########################

$PostStartTask = {
  Import-Module Terminal-Icons
  # link: https://direnv.net/docs/hook.html#powershell
}

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action $PostStartTask | Out-Null