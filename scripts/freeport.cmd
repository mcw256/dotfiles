@echo off
setlocal enabledelayedexpansion


if "%~1"=="-h" (
    goto :Help
)
if "%~1"=="--help" (
    goto :Help
)
if "%~1"=="-?" (
    goto :Help
)
if "%~1"=="" (
    goto :Help
)

set PORT=%1
set "KILLED_PIDS="

:: Find process ID(s) using the port and kill them
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /R "\:%PORT%[^0-9]"') do (
    set PID=%%a
    set "ALREADY_KILLED=0"

    :: Check if this PID was already processed
    for %%p in (!KILLED_PIDS!) do (
        if "%%p"=="!PID!" set "ALREADY_KILLED=1"
    )

    if "!ALREADY_KILLED!"=="0" (
        :: Get full process name using tasklist
        for /f "tokens=*" %%b in ('tasklist /FI "PID eq !PID!" ^| findstr /V "Image"') do (
            set PROCNAME=%%b
        )

        echo Killing process: !PROCNAME!
        taskkill /F /PID !PID!

        :: Store killed PIDs to avoid duplicates
        set "KILLED_PIDS=!KILLED_PIDS! !PID!"
    )
)

echo Done.
exit /b

:Help
echo This script helps to terminate processes that are using a specified port.
echo.
echo Usage: freeport ^<port_number^>
echo.
echo Options:
echo   -h, --help, -?   Show this help message and exit.
echo.
echo Example:
echo   freeport 8080   Terminate processes using port 8080.
echo.
exit /b
