@echo off
setlocal

REM =====================================
REM ROOT DETECTION
REM =====================================
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"

REM =====================================
REM DXSDK SCRIPT LOCATION
REM =====================================
set "DXSDK_DIR=%REPO_ROOT%\directxsdk_jun10"

REM çalıştırılacak script (standart isim varsayımı)
set "DXSDK_SCRIPT=build_dxsdk_jun10.bat"

set "SCRIPT_PATH=%DXSDK_DIR%\%DXSDK_SCRIPT%"

echo =====================================
echo DXSDK JUN10 LAUNCHER
echo =====================================
echo REPO_ROOT : %REPO_ROOT%
echo TARGET    : %DXSDK_DIR%
echo SCRIPT    : %DXSDK_SCRIPT%
echo =====================================
echo.

REM =====================================
REM VALIDATION
REM =====================================
if not exist "%DXSDK_DIR%" (
    echo [ERROR] DXSDK directory not found
    exit /b 1
)

if not exist "%SCRIPT_PATH%" (
    echo [ERROR] Build script not found
    echo %SCRIPT_PATH%
    exit /b 1
)

REM =====================================
REM RUN
REM =====================================
pushd "%DXSDK_DIR%"

echo [INFO] Running DXSDK build...
call "%DXSDK_SCRIPT%"

set "ERR=%ERRORLEVEL%"

popd

echo.
echo =====================================
if "%ERR%"=="0" (
    echo DXSDK BUILD SUCCESS
) else (
    echo DXSDK BUILD FAILED (%ERR%)
)
echo =====================================

exit /b %ERR%