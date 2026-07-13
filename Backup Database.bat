@echo off
setlocal

set "ROOT=%~dp0"
set "ENV_FILE=%ROOT%backend\.env"
set "BACKUP_DIR=%ROOT%backups"
set "PG_DUMP=C:\Program Files\PostgreSQL\17\bin\pg_dump.exe"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

if not exist "%ENV_FILE%" (
  echo ERROR: Missing backend environment file: "%ENV_FILE%"
  exit /b 1
)

if not exist "%PG_DUMP%" (
  echo ERROR: pg_dump.exe not found at "%PG_DUMP%"
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

for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set "STAMP=%%T"
set "BACKUP_FILE=%BACKUP_DIR%\%DB_NAME%_%STAMP%.sql"

echo Creating backup:
echo "%BACKUP_FILE%"

"%PG_DUMP%" --host "%DB_HOST%" --port "%DB_PORT%" --username "%DB_USER%" --dbname "%DB_NAME%" --format plain --clean --if-exists --no-owner --no-privileges --file "%BACKUP_FILE%"
if errorlevel 1 (
  echo.
  echo ERROR: Backup failed.
  exit /b 1
)

powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%BACKUP_DIR%' -Filter '%DB_NAME%_*.sql' | Sort-Object LastWriteTime -Descending | Select-Object -Skip 30 | Remove-Item -Force"

echo.
echo Backup completed successfully:
echo "%BACKUP_FILE%"
exit /b 0
