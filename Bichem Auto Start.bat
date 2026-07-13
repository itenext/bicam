@echo off
setlocal EnableDelayedExpansion
title Bichem SFA Auto Start

set "PROJECT=%~dp0"
set "LOG_DIR=%PROJECT%logs"
set "LOG_FILE=%LOG_DIR%\autostart.log"
set "BACKEND_URL=http://localhost:5000/health"
set "ADMIN_URL=http://localhost:3000"
set "TAILSCALE_EXE=C:\Program Files\Tailscale\tailscale.exe"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

call :log "=========================================="
call :log "Bichem SFA auto-start beginning"

call :log "Starting Tailscale service"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Service -Name 'Tailscale' -ErrorAction SilentlyContinue" >> "%LOG_FILE%" 2>&1
if exist "%TAILSCALE_EXE%" (
  "%TAILSCALE_EXE%" status >> "%LOG_FILE%" 2>&1
) else (
  call :log "WARNING: tailscale.exe not found at expected path"
)

call :log "Verifying PostgreSQL service"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$svc = Get-Service -Name 'postgresql-x64-17' -ErrorAction SilentlyContinue; if ($svc -and $svc.Status -ne 'Running') { Start-Service $svc.Name; $svc.WaitForStatus('Running','00:00:30') }; if ($svc) { (Get-Service $svc.Name).Status } else { 'PostgreSQL service not found' }" >> "%LOG_FILE%" 2>&1

call :log "Starting backend with PM2"
cd /d "%PROJECT%backend"
call pm2 restart bichem-api >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
  call pm2 start src\server.js --name bichem-api --cwd "%PROJECT%backend" >> "%LOG_FILE%" 2>&1
)

call :log "Starting admin panel"
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%ADMIN_URL%' -UseBasicParsing -TimeoutSec 2 | Out-Null; 'Admin already reachable' } catch { Start-Process -WindowStyle Hidden -FilePath 'cmd.exe' -ArgumentList '/c cd /d ""%PROJECT%admin-panel"" && npm start' ; 'Admin start requested' }" >> "%LOG_FILE%" 2>&1

call :waitUrl "%BACKEND_URL%" "Backend health" 60
call :waitUrl "%ADMIN_URL%" "Admin panel" 120

call :log "Bichem SFA auto-start finished"
exit /b 0

:waitUrl
set "URL=%~1"
set "NAME=%~2"
set "MAX=%~3"
set /a COUNT=0
:waitLoop
set /a COUNT+=1
curl.exe -s --max-time 2 "%URL%" >nul 2>&1
if not errorlevel 1 (
  call :log "%NAME% reachable"
  exit /b 0
)
if %COUNT% geq %MAX% (
  call :log "WARNING: %NAME% not reachable after %MAX% seconds"
  exit /b 1
)
timeout /t 1 /nobreak >nul
goto waitLoop

:log
echo [%date% %time%] %~1
echo [%date% %time%] %~1>> "%LOG_FILE%"
exit /b 0
