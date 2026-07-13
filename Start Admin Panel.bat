@echo off
title Bichem SFA - Admin Panel
echo Starting Bichem SFA Admin Panel...
echo Admin Panel will open at http://localhost:3000
echo Press Ctrl+C to stop.
echo.
cd /d "%~dp0admin-panel"
npm start
