# Link: https://blog.csdn.net/moklee/article/details/127559295
# run with
# powershell.exe -ExecutionPolicy Bypass -File ".\OpenHotSpot.ps1"

# 1. 必须包含 ContentType=WindowsRuntime，否则 5.1 找不到类型
[Windows.System.UserProfile.LockScreen, Windows.System.UserProfile, ContentType = WindowsRuntime] | Out-Null
Add-Type -AssemblyName System.Runtime.WindowsRuntime

# 2. 异步转换函数
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? {
    $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
  })[0]

function Await($WinRtTask, $ResultType) {
  $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
  $netTask = $asTask.Invoke($null, @($WinRtTask))
  $netTask.Wait(-1) | Out-Null
  return $netTask.Result
}

# 3. 使用 [类型, 命名空间, ContentType=WindowsRuntime] 格式加载
$connectionProfile = [Windows.Networking.Connectivity.NetworkInformation, Windows.Networking.Connectivity, ContentType = WindowsRuntime]::GetInternetConnectionProfile()
$tetheringManager = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager, Windows.Networking.NetworkOperators, ContentType = WindowsRuntime]::CreateFromConnectionProfile($connectionProfile)

if ($null -eq $tetheringManager) {
  Write-Error "Could not find a valid connection profile. Make sure you are connected to the Internet."
  return
}

# 4. 逻辑切换
if ($tetheringManager.TetheringOperationalState -eq 1) {
  Write-Host "Hotspot is ON. Stopping..." -ForegroundColor Yellow
  $result = Await ($tetheringManager.StopTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
  Write-Host "Stop result: $($result.Status)"
}
else {
  Write-Host "Hotspot is OFF. Configuring and starting..." -ForegroundColor Green

  $accessPoint = $tetheringManager.GetCurrentAccessPointConfiguration()
  $accessPoint.Ssid = "ASUSCOSMOS"
  $accessPoint.Passphrase = "hanahana"

  # 注意：配置本身也是异步的，如果不等待可能会导致开启时配置还没生效
  $tetheringManager.ConfigureAccessPointAsync($accessPoint) | Out-Null

  $result = Await ($tetheringManager.StartTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
  Write-Host "Start result: $($result.Status)"
}