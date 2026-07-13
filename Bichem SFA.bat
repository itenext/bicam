@echo off
setlocal EnableDelayedExpansion
title Bichem SFA Launcher
color 0A

echo.
echo  ==========================================
echo    BICHEM SFA  -  Starting All Services
echo  ==========================================
echo.

set "PROJECT=C:\Users\mnshk\bichem-sfa"
set "BACKEND_URL=http://localhost:5000/health"
set "ADMIN_URL=http://localhost:3000"

:: ── Step 1: Backend ─────────────────────────────────────────────────────────
echo  [1/3] Starting Backend...
pm2 restart bichem-api >nul 2>&1
if errorlevel 1 (
    pm2 start src\server.js --name bichem-api --cwd "%PROJECT%\backend" >nul 2>&1
)
echo        Backend process started via PM2.

:: ── Step 2: Admin Panel ──────────────────────────────────────────────────────
echo  [2/3] Starting Admin Panel...
:: Check if already running on port 3000
curl -s --max-time 1 "%ADMIN_URL%" >nul 2>&1
if not errorlevel 1 (
    echo        Admin Panel already running.
) else (
    start "Bichem Admin Panel" /min cmd /c "cd /d "%PROJECT%\admin-panel" && npm start"
    echo        Admin Panel launched in background window.
)

:: ── Step 3: Wait for Backend ─────────────────────────────────────────────────
echo.
echo  [3/3] Waiting for services to be ready...
echo.

set /a TRIES=0
:WAIT_BACKEND
set /a TRIES+=1
if %TRIES% gtr 30 (
    echo  [!] Backend did not respond after 30s. Check PM2 logs: pm2 logs bichem-api
    goto WAIT_ADMIN
)
curl -s --max-time 2 "%BACKEND_URL%" >nul 2>&1
if errorlevel 1 (
    set /p "=        Backend: waiting... [!TRIES!s]" <nul
    echo(
    timeout /t 1 /nobreak >nul
    goto WAIT_BACKEND
)
echo        Backend READY at http://localhost:5000

:: ── Wait for Admin Panel ────────────────────────────────────────────────────
:WAIT_ADMIN
set /a TRIES=0
:WAIT_ADMIN_LOOP
set /a TRIES+=1
if %TRIES% gtr 60 (
    echo  [!] Admin Panel did not respond after 60s.
    goto OPEN
)
curl -s --max-time 2 "%ADMIN_URL%" >nul 2>&1
if errorlevel 1 (
    set /p "=        Admin Panel: compiling... [!TRIES!s]" <nul
    echo(
    timeout /t 1 /nobreak >nul
    goto WAIT_ADMIN_LOOP
)
echo        Admin Panel READY at http://localhost:3000

:: ── Step 4: Open Browser ────────────────────────────────────────────────────
:OPEN
echo.
echo  ==========================================
echo    All services ready. Opening browser...
echo  ==========================================
echo.
timeout /t 1 /nobreak >nul
start "" "http://localhost:3000"

echo  Done! Services running:
echo    Backend   -  http://localhost:5000
echo    Admin     -  http://localhost:3000
echo.
echo  Close this window to keep services running.
echo  To stop backend: run  pm2 stop bichem-api
echo.
pause
