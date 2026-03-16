# Self-elevate the script if required
# link: https://www.chezmoi.io/user-guide/machines/windows/#run-a-powershell-script-as-admin-on-windows
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -Wait -FilePath pwsh.exe -Verb Runas -ArgumentList $CommandLine
    Exit
  }
}

# enable developer mode
# link: https://learn.microsoft.com/en-us/windows/advanced-settings/developer-mode#use-powershell-to-enable-your-device
function enableDeveloperMode() {
  $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
  $name = "AllowDevelopmentWithoutDevLicense"

  if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
  }
  Set-ItemProperty -Path $registryPath -Name $name -Value 1
}


#################################

enableDeveloperMode

# 设置服务为自动启动
Set-Service -Name ssh-agent -StartupType Automatic
# 启动服务
Start-Service ssh-agent