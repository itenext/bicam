@echo off
title Bichem SFA - Backend
echo Starting Bichem SFA Backend...
echo.

cd /d "%~dp0"

pm2 restart bichem-api 2>nul || pm2 start backend\src\server.js --name bichem-api --cwd "%~dp0backend"

echo.
timeout /t 3 /nobreak >nul

echo.
echo ============================================================
echo  Bichem SFA Backend
echo ============================================================
echo  PC (localhost):  http://localhost:5000/health
echo  PC (LAN IP):     http://192.168.1.11:5000/health
echo  Android test:    http://192.168.1.11:5000/ping
echo ============================================================
echo.

pm2 status bichem-api
echo.
pause
