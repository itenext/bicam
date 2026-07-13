@echo off
setlocal

set "PROJECT=%~dp0"
set "AUTO_START=%PROJECT%Bichem Auto Start.bat"

if not exist "%AUTO_START%" (
  echo ERROR: Missing "%AUTO_START%"
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$startup = [Environment]::GetFolderPath('Startup'); $wsh = New-Object -ComObject WScript.Shell; $lnk = $wsh.CreateShortcut((Join-Path $startup 'Bichem SFA Auto Start.lnk')); $lnk.TargetPath = '%AUTO_START%'; $lnk.WorkingDirectory = '%PROJECT%'; $lnk.Description = 'Start Bichem SFA services on Windows login'; $lnk.Save()"
if errorlevel 1 (
  echo.
  echo ERROR: Could not enable auto start.
  exit /b 1
)

echo.
echo Bichem SFA auto start enabled.
echo It will run from this user's Windows Startup folder.
pause
