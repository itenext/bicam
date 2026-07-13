@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -Command "$startup = [Environment]::GetFolderPath('Startup'); $lnk = Join-Path $startup 'Bichem SFA Auto Start.lnk'; if (Test-Path $lnk) { Remove-Item $lnk -Force; exit 0 } else { exit 1 }"
if errorlevel 1 (
  echo.
  echo Auto start shortcut was not found or could not be removed.
  exit /b 1
)

echo.
echo Bichem SFA auto start disabled.
pause
