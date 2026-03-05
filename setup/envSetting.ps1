Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "❌ 必须以管理员身份运行此脚本！"
  return
}

function setEnv {
  param(
    [Parameter(Mandatory)][string]$name,
    [Parameter(Mandatory)][string]$value,
    [ValidateSet("Process", "User", "Machine")][string]$target = "User",
    [switch]$ResolvePath
  )

  if ($ResolvePath -and (Test-Path $value)) {
    $value = (Resolve-Path -Path $value).Path
  }

  [Environment]::SetEnvironmentVariable($name, $value, $target)
}

function optionCreate() {
  param([string]$folder)
  if (!(Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder | Out-Null
  }
}
# ------------------------

$devDrive = (Resolve-Path -Path "D:/").Path
$cacheFolder = "$devDrive/DevCache"
optionCreate -folder $cacheFolder
$cacheFolder = (Resolve-Path -Path $cacheFolder).Path

# ------------------------
# LLVM
# ------------------------
$systemPathVariable = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$LLVMPath = (Resolve-Path -Path "$env:ProgramFiles/LLVM/bin").Path
setEnv -name "PATH" -value ($systemPathVariable + ";" + $LLVMPath) -target "Machine"

# ------------------------
# python uv
# ------------------------

$targetUv = "$cacheFolder/uv"
optionCreate -folder $targetUv
$targetUv = (Resolve-Path -Path $targetUv).Path

$uvCacheDir = "$targetUv/cache"
$uvPythonDir = "$targetUv/python"
$uvToolsDir = "$targetUv/tool"
optionCreate -folder $uvCacheDir
optionCreate -folder $uvPythonDir
optionCreate -folder $uvToolsDir
setEnv -name "UV_CACHE_DIR" -value $uvCacheDir -target "User" -ResolvePath
setEnv -name "UV_PYTHON_INSTALL_DIR" -value $uvPythonDir -target "User" -ResolvePath
setEnv -name "UV_TOOL_DIR" -value $uvToolsDir -target "User" -ResolvePath

# ------------------------
# rustup
# ------------------------
$rustupServer = "https://rsproxy.cn"
$rustupRoot = "https://rsproxy.cn/rustup"
setEnv -name "RUSTUP_DIST_SERVER" -value $rustupServer -target "User"
setEnv -name "RUSTUP_UPDATE_ROOT" -value $rustupRoot -target "User"

# ------------------------
# bun
# ------------------------
$targetBun = "$cacheFolder/.bun"
optionCreate -folder $targetBun
$targetBun = (Resolve-Path -Path $targetBun).Path
$targetBunCache = "$targetBun/cache"
optionCreate -folder $targetBunCache

setEnv -name "BUN_INSTALL" -value $targetBun -target "User" -ResolvePath
setEnv -name "BUN_INSTALL_CACHE" -value $targetBunCache -target "User" -ResolvePath

# ------------------------
# Winget Links
# ------------------------

$winget_links = "$env:LOCALAPPDATA/Microsoft/WinGet/Links"

setEnv -name "WINGET_LINKS" -value $winget_links -target "User" -ResolvePath
