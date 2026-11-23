# Keeps the phone -> PC port forward alive (phone 127.0.0.1:3000 -> PC :3000).
# The forward is wiped whenever the phone reconnects, sleeps its USB link, or
# adb restarts — the app then shows "Cannot reach the ExamGenius server".
# Leave this running in its own terminal while you use the app:
#   .\keep_phone_connected.ps1
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) { $adb = 'adb' }

Write-Host 'Keeping phone connected to the backend (Ctrl+C to stop)...'
$wasOk = $null
while ($true) {
  $list = & $adb reverse --list 2>$null
  $ok = [bool]($list -match 'tcp:3000 tcp:3000')
  if (-not $ok) {
    & $adb reverse tcp:3000 tcp:3000 2>$null | Out-Null
    $ok = $LASTEXITCODE -eq 0
  }
  if ($ok -ne $wasOk) {
    $time = Get-Date -Format 'HH:mm:ss'
    if ($ok) { Write-Host "$time  connected" -ForegroundColor Green }
    else { Write-Host "$time  phone not found - plug it in with USB debugging on" -ForegroundColor Yellow }
    $wasOk = $ok
  }
  Start-Sleep -Seconds 3
}
