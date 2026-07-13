@echo off
:: ============================================================
:: Bichem SFA — Fix Windows Firewall for Port 5000
:: RIGHT-CLICK this file → "Run as administrator"
:: ============================================================

echo.
echo [Bichem SFA] Adding firewall rule for port 5000...
echo.

:: Remove any old rule with same name (ignore error if not found)
netsh advfirewall firewall delete rule name="Bichem SFA Port 5000" >nul 2>&1

:: Add inbound TCP allow for port 5000 on ALL profiles
netsh advfirewall firewall add rule ^
  name="Bichem SFA Port 5000" ^
  dir=in ^
  action=allow ^
  protocol=TCP ^
  localport=5000 ^
  profile=any ^
  description="Allow Android app to reach Bichem SFA backend on LAN"

echo.
echo [Bichem SFA] Verifying rule...
netsh advfirewall firewall show rule name="Bichem SFA Port 5000"

echo.
echo [Bichem SFA] Testing port 5000...
curl -s -o - --max-time 3 http://192.168.1.11:5000/ping
echo.

echo.
echo ============================================================
echo DONE.
echo Now open this URL on your Android phone (Chrome):
echo   http://192.168.1.11:5000/ping
echo You should see:  {"success":true,"message":"pong",...}
echo ============================================================
echo.
pause
