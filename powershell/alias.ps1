# 别名配置

# 移除默认别名
if (Get-Alias -Name "ls" -ErrorAction SilentlyContinue) {
  Remove-Alias ls -Force
}
if (Get-Alias -Name "diff" -ErrorAction SilentlyContinue) {
  Remove-Alias diff -Force
}
if (Get-Alias -Name "rm" -ErrorAction SilentlyContinue) {
  Remove-Alias rm -Force
}

# 设置别名
Set-Alias -Name g -Value git
Set-Alias -Name c -Value code
Set-Alias -Name edge -Value msedge.exe
Set-Alias -Name f -Value Invoke-Fzf
