# 按键绑定配置

Set-PsReadLineOption -EditMode Vi
Set-PSReadLineOption -PredictionSource History -HistoryNoDuplicates
Set-PSReadLineKeyHandler -Key 'k' -Function HistorySearchBackward -ViMode Command
Set-PSReadLineKeyHandler -Key 'j' -Function HistorySearchForward -ViMode Command

# 在 Normal 模式下按 v，直接在记事本或 VS Code 中打开当前行进行编辑
Set-PSReadLineKeyHandler -Key 'v' -ViMode Command -ScriptBlock {
  # 尝试调用内置的视觉编辑功能，它会自动读取 $env:EDITOR
  [Microsoft.PowerShell.PSConsoleReadLine]::ViEditVisually()
}

Set-PsReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Set-PSReadLineKeyHandler -Key "Ctrl+n" -Function NextHistory
Set-PSReadLineKeyHandler -Key "Ctrl+p" -Function PreviousHistory

# 光标样式切换
$OnViModeChange = {
  if ($args[0] -eq 'Command') {
    Write-Host -NoNewLine "`e[2 q"
  }
  elseif ($args[0] -eq 'Insert') {
    Write-Host -NoNewLine "`e[5 q"
  }
  elseif ($args[0] -eq 'Replace') {
    Write-Host -NoNewLine "`e[4 q"
  }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $OnViModeChange

# 把当前输入的命令存入历史记录但不执行，然后清空当前行
Set-PSReadLineKeyHandler -Key 'Alt+w' -ScriptBlock {
  param($key, $arg)
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}

# 分号快速替换映射
$ReplaceMap = @{
  'l' = '|'
  's' = '-'
  'a' = '&'
}

foreach ($keyChar in $ReplaceMap.Keys) {
  $targetValue = $ReplaceMap[$keyChar]

  $sb = {
    param($key, $arg)
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0 -and $line[$cursor - 1] -eq ';') {
      [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar()
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert($targetValue)
    }
    else {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert($key.KeyChar)
    }
  }.GetNewClosure()

  Set-PSReadLineKeyHandler -Chord $keyChar -ScriptBlock $sb
}

# 分号本身的输入逻辑
Set-PSReadLineKeyHandler -Chord ';' -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert(';')
}

# FZF 集成
if (Get-Command fzf -ErrorAction SilentlyContinue) {
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+k' -PSReadlineChordReverseHistory 'Ctrl+r'
  Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
  Set-PsFzfOption -TabExpansion
  Set-PsFzfOption -EnableAliasFuzzyEdit
  Set-PsFzfOption -EnableAliasFuzzyHistory
  Set-PsFzfOption -EnableAliasFuzzyKillProcess
  Set-PsFzfOption -EnableAliasFuzzyScoop
  Set-PsFzfOption -EnableAliasFuzzyGitStatus
  Set-PsFzfOption -EnableAliasFuzzySetEverything
  Set-PsFzfOption -EnableAliasFuzzyZLocation
}

# Ctrl + i 快速插入命令
Set-PSReadLineKeyHandler -Chord 'Ctrl+i' -ScriptBlock {
  $command = Get-Command | Select-Object -ExpandProperty Name | Invoke-Fzf
  if ($command) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
  }
}

# Winget 补全
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
  $Local:word = $wordToComplete.Replace('"', '""')
  $Local:ast = $commandAst.ToString().Replace('"', '""')
  winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

# USBIPD 补全
Register-ArgumentCompleter -Native -CommandName usbipd -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  usbipd [suggest:$cursorPosition] "$wordToComplete" | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}
