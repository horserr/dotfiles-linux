Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# D:\dotfiles\powershell\setup\setup.ps1
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "❌ 必须以管理员身份运行此脚本！"
  return
}

#----------------------------------
# VHDX
#----------------------------------
$vhdxPath = "C:\DevDrive.vhdx"
function CreateVHD() {
  param(
    [string]$vhdxPath,
    [Int64]$size = 50GB,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z]$')]
    [string]$mountDriveName
  )
  # 1. 创建虚拟磁盘
  # 2. 挂载磁盘
  # 3. 格式化为 ReFS 并命名为 "DevDrive"
  # 4. 分配盘符（假设使用 D 盘，如果 D 被占用请更改）
  New-VHD -Path $vhdxPath -SizeBytes $size -Dynamic | `
    Mount-VHD -Passthru | `
    Initialize-Disk -Passthru | `
    New-Partition -DriveLetter $mountDriveName -UseMaximumSize | `
    Format-Volume -FileSystem ReFS -NewFileSystemLabel "DevDrive"
}
$mountDriveName = 'D'
# if dev drive not exist
if (-not(Test-Path -Path "$mountDriveName`:")) {
  Write-Host 'Createing VHDX, please wait'
  CreateVHD -vhdxPath $vhdxPath -mountDriveName $mountDriveName
}

#----------------------------------
# Dotfiles
#----------------------------------
$currentDriveName = (Get-Location).Drive.Name
if ($currentDriveName -ne $mountDriveName) {
  throw "当前驱动器不是目标驱动器，停止执行。"
}
# $dotRoot = "D:/dotfiles"
$dotRoot = Split-Path -Path $PSScriptRoot -Parent
$documentPath = [Environment]::GetFolderPath("MyDocuments")

# 定义映射关系 [原位路径] -> [dotfiles 路径]
$mappings = @{
  # PowerShell Profile (注意路径适配 Win11)
  "$documentPath/PowerShell/Microsoft.PowerShell_profile.ps1" = "$dotRoot/powershell/profile"

  # Git Config
  "$env:USERPROFILE/.gitconfig" = "$dotRoot/git"

  # WSL Config
  "$env:USERPROFILE/.wslconfig" = "$dotRoot/wsl"

  # IdeaVim
  "$env:USERPROFILE/.ideavimrc" = "$dotRoot/ideavim"

  # SSH Config (仅 Link config 文件而非整个文件夹，确保安全)
  "$env:USERPROFILE/.ssh/config" = "$dotRoot/ssh"

  # VS Code
  "$env:AppData/Code/User/settings.json" = "$dotRoot/vscode/settings"
  "$env:AppData/Code/User/keybindings.json" = "$dotRoot/vscode/keybindings"

  # NuGet
  "$env:AppData/NuGet/NuGet.Config" = "$dotRoot/nuget"

  # nvim
  "$env:LOCALAPPDATA/nvim" = "$dotRoot/nvim"

  # windows terminal preview
  (
    "$env:LOCALAPPDATA/Packages/" +
    "Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/" +
    "LocalState/settings.json"
  ) = "$dotRoot/terminal"
}

Write-Host "`n🔗 正在同步 Dotfiles 配置..." -ForegroundColor Cyan

foreach ($from in $mappings.Keys) {
  $to = $mappings[$from]
  # create parent folder without error or override if exists
  New-Item -Path (Split-Path $from -Parent) -ItemType Directory -Force | Out-Null

  # create symbolic link regardless of folder and file
  New-Item -ItemType SymbolicLink -Path $from -Target $to -Force | Out-Null
}