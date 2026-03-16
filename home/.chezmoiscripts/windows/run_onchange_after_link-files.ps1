Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ========================
# util functions need to be extracted later
function checkAdminAccess() {
  if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "❌ 必须以管理员身份运行此脚本！"
    exit
  }
}
function optionCreate() {
  param([string]$folder)
  if (!(Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder | Out-Null
  }
}

# ========================

# no need any more
# checkAdminAccess

$dotConfigPath = "$env:USERPROFILE\.config"
$documentPath = [Environment]::GetFolderPath("MyDocuments")
$vscodePath = "$env:APPDATA\Code\User"

$mappings = @{
  # PowerShell Profile (注意路径适配 Win11)
  "$documentPath\PowerShell\Microsoft.PowerShell_profile.ps1" = "$env:USERPROFILE\powershell\profile"

  # nvim
  "$env:LOCALAPPDATA\nvim" = "$dotConfigPath\nvim"
  # uv
  "$env:APPDATA\uv\uv.toml" = "$dotConfigPath\uv\uv.toml"
  # vscode
  "$vscodePath\keybindings.json"="$dotConfigPath\vscode\keybindings.jsonc"
  "$vscodePath\settings.json"="$dotConfigPath\vscode\settings.jsonc"
  "$vscodePath\snippets"="$dotConfigPath\vscode\snippets"

  # windows terminal preview
  (
    "$env:LOCALAPPDATA\Packages\" +
    "Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\" +
    "LocalState\settings.json"
  ) = "$dotConfigPath\windows-terminal.json"

  # win word normal.dotm
  "$env:APPDATA\Microsoft\Templates\normal.dotm" = "$env:OneDrive\Resource\Other\Office\Word\Normal.dotm"
}

foreach ($from in $mappings.Keys) {
  $to = $mappings[$from]
  # create parent folder without error or override if exists
  optionCreate (Split-Path $from)
  # create symbolic link regardless of folder and file
  New-Item -ItemType SymbolicLink -Path $from -Target $to -Force
}