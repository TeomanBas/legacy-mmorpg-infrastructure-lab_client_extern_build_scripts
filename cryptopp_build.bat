@echo off
setlocal enabledelayedexpansion

echo =====================================
echo        CRYPTOPP BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\cryptopp
set BUILD_ROOT=%ROOT_DIR%\build\cryptopp

set SOLUTION=%SOURCE_DIR%\cryptest.sln

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

REM =========================
REM CHECK SOURCE
REM =========================

if not exist "%SOLUTION%" (
    echo [ERROR] cryptest.sln not found!
    pause
    exit /b 1
)

REM =========================
REM VISUAL STUDIO ENV
REM =========================

call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"

REM =========================
REM BUILD MATRIX
REM =========================

call :build Win32 Debug
call :build Win32 Release
call :build x64 Debug
call :build x64 Release

echo.
echo =====================================
echo        CRYPTOPP COMPLETED
echo =====================================
pause
exit /b 0


REM =========================
REM BUILD FUNCTION
REM =========================

:build
set PLATFORM=%1
set CONFIG=%2

set OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%\%CONFIG%

echo.
echo =====================================
echo Building Crypto++ %PLATFORM% - %CONFIG%
echo =====================================

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

REM =========================
REM BUILD (MSBUILD)
REM =========================

msbuild "%SOLUTION%" ^
    /t:cryptlib ^
    /p:Configuration=%CONFIG% ^
    /p:Platform=%PLATFORM% ^
    /p:RuntimeLibrary=MultiThreaded

if errorlevel 1 (
    echo [ERROR] Build failed %PLATFORM% %CONFIG%
    exit /b 1
)

REM =========================
REM FIND LIB OUTPUT
REM =========================

set SRC_LIB=

for /r "%SOURCE_DIR%" %%F in (*.lib) do (
    echo %%F | findstr /i "\\%CONFIG%\\" >nul
    if not errorlevel 1 (
        set SRC_LIB=%%F
    )
)

REM =========================
REM COPY LIB
REM =========================

if exist "!SRC_LIB!" (
    copy /Y "!SRC_LIB!" "%OUT_DIR%\cryptlib.lib" >nul
    echo [OK] Copied: !SRC_LIB!
) else (
    echo [WARN] LIB not found for %PLATFORM% %CONFIG%
)

exit /b 0