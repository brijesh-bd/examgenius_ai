# Runs the app on a USB-connected Android phone against the local backend.
# Also starts a background watcher that keeps the phone -> PC port forward
# alive for the whole session (it is wiped whenever the phone reconnects,
# which causes "Cannot reach the ExamGenius server").
#
# Usage (from this folder):   .\run_phone.ps1
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) { $adb = 'adb' }

& $adb wait-for-device
& $adb reverse tcp:3000 tcp:3000
if ($LASTEXITCODE -ne 0) { Write-Error 'adb reverse failed - is the phone connected with USB debugging on?'; exit 1 }
Write-Host 'Port forward OK (phone 127.0.0.1:3000 -> PC:3000)'

$keeper = Start-Job -ArgumentList $adb -ScriptBlock {
  param($adb)
  while ($true) {
    if (-not ((& $adb reverse --list 2>$null) -match 'tcp:3000 tcp:3000')) {
      & $adb reverse tcp:3000 tcp:3000 2>$null | Out-Null
    }
    Start-Sleep -Seconds 3
  }
}
try {
  flutter run @args
} finally {
  Stop-Job $keeper; Remove-Job $keeper
}
