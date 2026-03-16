# TODO

## refactor powershell scripts

1. move functions into the independent file

## install apps

1. fix the path
2. only output error message

```pwsh
$installationFile = Join-Path -Path $PSScriptRoot -ChildPath "app.json"
$data = Get-Content $installationFile | ConvertFrom-Json

$packages = $data.Sources.Packages
# 使用 PowerShell 7 的并行功能，同时安装 3 个包
$packages | ForEach-Object -Parallel {
  winget install --id $_.PackageIdentifier --silent --accept-source-agreements --accept-package-agreements
} -ThrottleLimit 3
```

## install fonts

```pwsh
# 'lxgw/LxgwZhenKai'
# 'googlefonts/comfortaa'
# 'lxgw/LxgwMarkerGothic'
# 'atelier-anchor/smiley-sans'
# 'lxgw/yozai-font'
# 'lxgw/LxgwNeoXiHei'

# 7z e .\FiraCode.zip -o"$env:TEMP/fonts" "*.otf" -r

Install-PSResource -Name NerdFonts

$NerdFonts = @(
  '0xProto', '3270' , 'FiraCode',
  'FiraMono', 'Hack', 'Hurmit',
  'SauceCodePro', 'InconsolataGo',
  'JetBrainsMono', 'RecMono',
  'ProggyClean', 'Terminess', 'UbuntuMono'
)
$NerdFonts | Foreach-Object -ThrottleLimit 5 -Parallel {
  Install-NerdFont -Name $PSItem
}

# Get-ChildItem -Recurse | Where-Object { $_.Extension -in '.ttf', '.otf' } | Install-Font
```
