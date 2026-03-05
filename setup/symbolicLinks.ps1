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

  # uv config
  "$env:APPDATA/uv/uv.toml" = "$dotRoot/uv"

  # cargo Config
  "$env:USERPROFILE/.cargo/config.toml" = "$dotRoot/cargo"

  # word normal template
  "$env:APPDATA/Microsoft/Templates/Normal.dotm" = "$dotRoot/Office/Word/Normal.dotm"
}

Write-Host "`n🔗 正在同步 Dotfiles 配置..." -ForegroundColor Cyan

foreach ($from in $mappings.Keys) {
  $to = $mappings[$from]
  # create parent folder without error or override if exists
  New-Item -Path (Split-Path $from -Parent) -ItemType Directory -Force | Out-Null

  # create symbolic link regardless of folder and file
  New-Item -ItemType SymbolicLink -Path $from -Target $to -Force | Out-Null
}

# #################

$mappings = @{
  # rust cargo
  "$env:USERPROFILE/.cargo"          = "$cacheFolder/.cargo"

  # NuGet 全局包缓存 (非常推荐)
  "$env:USERPROFILE/.nuget/packages" = "$cacheFolder/nuget-packages"
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
    robocopy "$from" "$to" /E /MOVE /R:2 /W:2
    # note: add /L to list files without copying
    # robocopy "$from" "$to" /E /MOVE /XF "Web Data-journal" /NFL /NDL /NJH | Out-Null
    # display message and process
  }
  else {
    Write-Host "⚠️ 源不存在，跳过: $from"
  }

  New-Item -ItemType SymbolicLink -Path $from -Target $to -Force | Out-Null
}
