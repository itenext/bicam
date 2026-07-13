@echo off
setlocal

set "ROOT=%~dp0"
set "ENV_FILE=%ROOT%backend\.env"
set "BACKUP_DIR=%ROOT%backups"
set "PSQL=C:\Program Files\PostgreSQL\17\bin\psql.exe"

if not exist "%ENV_FILE%" (
  echo ERROR: Missing backend environment file: "%ENV_FILE%"
  exit /b 1
)

if not exist "%PSQL%" (
  echo ERROR: psql.exe not found at "%PSQL%"
  exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
  if "%%A"=="DB_HOST" set "DB_HOST=%%B"
  if "%%A"=="DB_PORT" set "DB_PORT=%%B"
  if "%%A"=="DB_NAME" set "DB_NAME=%%B"
  if "%%A"=="DB_USER" set "DB_USER=%%B"
  if "%%A"=="DB_PASSWORD" set "PGPASSWORD=%%B"
)

if "%DB_HOST%"=="" set "DB_HOST=localhost"
if "%DB_PORT%"=="" set "DB_PORT=5432"
if "%DB_NAME%"=="" set "DB_NAME=bichem_sfa"
if "%DB_USER%"=="" set "DB_USER=postgres"

set "RESTORE_FILE=%~1"
if "%RESTORE_FILE%"=="" (
  for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "$f = Get-ChildItem -LiteralPath '%BACKUP_DIR%' -Filter '%DB_NAME%_*.sql' | Sort-Object LastWriteTime -Descending | Select-Object -First 1; if ($f) { $f.FullName }"`) do set "RESTORE_FILE=%%F"
)

if "%RESTORE_FILE%"=="" (
  echo ERROR: No backup file found in "%BACKUP_DIR%"
  exit /b 1
)

if not exist "%RESTORE_FILE%" (
  echo ERROR: Backup file not found: "%RESTORE_FILE%"
  exit /b 1
)

echo This will restore database "%DB_NAME%" from:
echo "%RESTORE_FILE%"
echo.
choice /C YN /M "Continue"
if errorlevel 2 exit /b 0

"%PSQL%" --host "%DB_HOST%" --port "%DB_PORT%" --username "%DB_USER%" --dbname "%DB_NAME%" --file "%RESTORE_FILE%"
if errorlevel 1 (
  echo.
  echo ERROR: Restore failed.
  exit /b 1
)

echo.
echo Restore completed successfully.
exit /b 0
