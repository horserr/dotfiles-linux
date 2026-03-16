# QuickMigrate.ps1 -Mode Export 或 -Mode Import
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("Export", "Import")]
  [string]$Mode
)

$file = Join-Path -Path $PSScriptRoot -ChildPath "modules_list.txt"

if ($Mode -eq "Export") {
  Get-InstalledPSResource | Select-Object -ExpandProperty Name -Unique | Out-File $file
  Write-Host "清单已导出至 $file" -ForegroundColor Green
}
else {
  $list = Get-Content $file
  $list | ForEach-Object -Parallel {
    Install-PSResource -Name $_ -AcceptLicense -TrustRepository
  } -ThrottleLimit 5
  Write-Host "还原完成。" -ForegroundColor Green
}