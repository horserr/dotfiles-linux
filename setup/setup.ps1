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
