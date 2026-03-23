# TODO

1. refactor powershell scripts: move functions into the independent file
2. 将vscode setting拆分成多个文件
3. learn [gitconfig](https://github.com/twpayne/dotfiles/blob/da62cef4e6cc09ab4b11e9d13bc9f3ac2b41f570/home/dot_config/git/config.tmpl#L123)
4. ubuntu24.04之前的apt换源操作
5. 根据是否在国外进行换源操作
6. wsl.conf文件
7. 安装ffmpeg, build-essential, poppler, imagemagic
8. 获取vscode安装插件列表

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

## 检查是否为 root 用户（apt 安装需要 root 权限）

```bash
if [ "$(id -u)" -ne 0 ]; then
echo "❌错误：该脚本需要以 root 权限运行！"
echo "⚠️请使用 sudo 执行，例如：sudo $0"
exit 1
fi
```

## 更新与completion

```bash
uv generate-shell-completion fish > ~/.config/fish/completions/uv.fish
```

```bash
uvx generate-shell-completion fish > ~/.config/fish/completions/uvx.fish
```
