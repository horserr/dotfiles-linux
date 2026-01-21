Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "❌ 必须以管理员身份运行此脚本！"
  return
}

function optionCreate() {
  param([string]$folder)
  if (!(Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder | Out-Null
  }
}
# ------------------------

$devDrive = "D:/"
$cacheFolder = "$devDrive/DevCache"
optionCreate -folder $cacheFolder

# ------------------------
# python uv
# ------------------------

$targetUv = "$cacheFolder/uv"
optionCreate -folder $targetUv

[Environment]::SetEnvironmentVariable("UV_CACHE_DIR", $targetUv, "User")

# ------------------------
# bun
# ------------------------
$targetBun = "$cacheFolder/.bun"
optionCreate -folder $targetBun

[Environment]::SetEnvironmentVariable("BUN_INSTALL", "$targetBun", "User")
[Environment]::SetEnvironmentVariable("BUN_INSTALL_CACHE", "$targetBun/cache", "User")

# ------------------------
# Temp folder: do not change
# ------------------------

# $newTemp = "$cacheFolder/Temp"
# optionCreate -folder $newTemp

# [Environment]::SetEnvironmentVariable("TEMP", $newTemp, "User")
# [Environment]::SetEnvironmentVariable("TMP", $newTemp, "User")


$mappings = @{
  # rust cargo
  "$env:USERPROFILE/.cargo"                        = "$cacheFolder/.cargo"
  # vscode extensions
  "$env:USERPROFILE/.vscode/extensions"            = "$cacheFolder/.vscode-extensions"
  # edge data
  "$env:LocalAppData/Microsoft/Edge/User Data"     = "$cacheFolder/edge-data"
  # NuGet 全局包缓存 (非常推荐)
  "$env:USERPROFILE/.nuget/packages"               = "$cacheFolder/nuget-packages"

  # Visual Studio 本地缓存目录 (包含 IntelliSense、实验性功能设置等)
  "$env:LocalAppData/Microsoft/VisualStudio"       = "$cacheFolder/VS-LocalAppData"

  # Visual Studio 安装包缓存 (默认路径通常在 C:\ProgramData\Microsoft\VisualStudio\Packages)
  "C:/ProgramData/Microsoft/VisualStudio/Packages" = "$cacheFolder/VS-Package-Cache"
}

# 处理每个映射：移动文件夹内容并创建符号链接
foreach ($from in $mappings.Keys) {
  $to = $mappings[$from]

  # 确保目标文件夹存在
  optionCreate -folder $to

  # 如果源存在，使用 robocopy 移动文件到目标
  Write-Host "📦 移动: $from → $to"
  if (Test-Path $from) {
    Stop-Process -Name "msedge", "Code", "visualstudio" -ErrorAction SilentlyContinue

    # 修改后的 robocopy 逻辑建议添加重试限制，防止因个别锁定文件死循环
    # /R:2 /W:2 表示失败重试2次，等待2秒
    robocopy "$from" "$to" /E /MOVE /XF "Web Data-journal" /R:2 /W:2
    # note: add /L to list files without copying
    # robocopy "$from" "$to" /E /MOVE /XF "Web Data-journal" /NFL /NDL /NJH | Out-Null
    # display message and process
  }
  else {
    Write-Host "⚠️ 源不存在，跳过: $from"
  }

  New-Item -ItemType SymbolicLink -Path $from -Target $to -Force | Out-Null
}

