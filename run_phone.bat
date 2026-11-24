@echo off
rem Double-click (or run) to start the app on the USB phone with the
rem phone -> PC port forward kept alive (see run_phone.ps1).
rem Extra arguments go to "flutter run", e.g.:  run_phone.bat --release
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_phone.ps1" %*
