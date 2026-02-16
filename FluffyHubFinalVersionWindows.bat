@echo off

REM This script is for backup with ADB

REM Get current date and time in YYYY-MM-DD format
set "datetime=%date:~0,4%-%date:~5,2%-%date:~8,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%"
set "adbPath=D:\path\to\adb.exe"  REM Change to your ADB path

REM Load config file if exists
if exist config.txt (
    for /f "tokens=1 delims=" %%a in (config.txt) do set "adbPath=%%a"
)

REM Backup commands
REM Fixing broken quotes for backup
"%adbPath%" backup -f "backup_%datetime%.ab" -apk -shared -all -system
if errorlevel 1 (
    echo ADB Backup failed. Please check the ADB path and make sure your device is connected correctly.
    exit /b 1
)

REM More backup commands...

echo Backup completed successfully!