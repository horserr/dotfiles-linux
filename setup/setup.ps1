# D:\dotfiles\powershell\setup\setup.ps1
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "❌ 必须以管理员身份运行此脚本！"
  return
}

# $DotRoot = "D:/dotfiles"
$DotRoot = Split-Path -Path $PSScriptRoot -Parent

$RealDocuments = [Environment]::GetFolderPath("MyDocuments")

# 定义映射关系 [原位路径] -> [dotfiles 路径]
$Mappings = @{
  # PowerShell Profile (注意路径适配 Win11)
  "$RealDocuments\PowerShell\Microsoft.PowerShell_profile.ps1" = "$DotRoot\powershell\profile"

  # Git Config
  "$env:USERPROFILE\.gitconfig"                                = "$DotRoot\git"

  # WSL Config
  "$env:USERPROFILE\.wslconfig"                                = "$DotRoot\wsl"

  # IdeaVim
  "$env:USERPROFILE\.ideavimrc"                                = "$DotRoot\ideavim"

  # SSH Config (仅 Link config 文件而非整个文件夹，确保安全)
  "$env:USERPROFILE\.ssh\config"                               = "$DotRoot\ssh"

  # VS Code
  "$env:AppData\Code\User\settings.json"                       = "$DotRoot\vscode\settings"
  "$env:AppData\Code\User\keybindings.json"                    = "$DotRoot\vscode\keybindings"

  # NuGet
  "$env:AppData\NuGet\NuGet.Config"                            = "$DotRoot\nuget"

  # nvim
  "$env:LOCALAPPDATA\nvim"                                     = "$DotRoot\nvim"
}
# 专门处理 Terminal 的路径
$TerminalPath = Resolve-Path "$env:LocalAppData\Packages\Microsoft.WindowsTerminal*\LocalState\settings.json" -ErrorAction SilentlyContinue
if ($TerminalPath) {
  $Mappings[$TerminalPath.Path] = "$DotRoot\terminal"
}

$SuccessCount = 0
$FailureList = @()

Write-Host "`n🔗 正在同步 Dotfiles 配置..." -ForegroundColor Cyan
Write-Host "----------------------------------"

foreach ($Dest in $Mappings.Keys) {
  $Source = $Mappings[$Dest]
  try {
    if (Test-Path $Source) {
      # 确保父目录存在
      $ParentDir = Split-Path $Dest
      if (!(Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
      }

      if (Test-Path $Dest) {
        Remove-Item $Dest -Force -ErrorAction Stop
      }

      # 创建符号链接 (SymbolicLink)
      New-Item -ItemType SymbolicLink -Path $Dest -Target $Source -Force -ErrorAction Stop | Out-Null
      Write-Host "✅ [成功] $Dest" -ForegroundColor Green
      $SuccessCount++
    }
    else {
      throw "源文件不存在"
    }
  }
  catch {
    Write-Host "❌ [失败] $Dest" -ForegroundColor Red
    $FailureList += [PSCustomObject]@{ Target = $Dest; Reason = $_.Exception.Message }
  }
}

# --- 统计输出 ---
Write-Host "`n=================================="
Write-Host "📊 同步报告:" -ForegroundColor Cyan
Write-Host "成功数: $SuccessCount" -ForegroundColor Green
Write-Host "失败数: $($FailureList.Count)" -ForegroundColor ($FailureList.Count -eq 0 ? "Green" : "Red")

if ($FailureList.Count -gt 0) {
  Write-Host "`n具体错误明细:" -ForegroundColor Red
  $FailureList | Format-Table -AutoSize
}