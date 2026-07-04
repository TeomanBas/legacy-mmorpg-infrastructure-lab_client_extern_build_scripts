@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo =====================================
echo        LIBSODIUM BUILD SCRIPT
echo =====================================

REM =====================================================
REM ROOT
REM =====================================================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\libsodium
set SOLUTION=%SOURCE_DIR%\builds\msvc\vs2026\libsodium.sln
set BUILD_ROOT=%ROOT_DIR%\build\libsodium

echo Root     : %ROOT_DIR%
echo Source   : %SOURCE_DIR%
echo Solution : %SOLUTION%
echo Build    : %BUILD_ROOT%

REM =====================================================
REM CHECKS
REM =====================================================

if not exist "%SOURCE_DIR%" (
    echo [ERROR] libsodium source not found.
    pause
    exit /b 1
)

if not exist "%SOLUTION%" (
    echo [ERROR] libsodium.sln not found.
    pause
    exit /b 1
)

if exist "%BUILD_ROOT%" (
    rmdir /s /q "%BUILD_ROOT%"
)

mkdir "%BUILD_ROOT%"

REM =====================================================
REM BUILD MATRIX
REM =====================================================

call :build Win32 StaticDebug
call :build Win32 StaticRelease
call :build x64 StaticDebug
call :build x64 StaticRelease

echo.
echo =====================================
echo      LIBSODIUM BUILD COMPLETED
echo =====================================
pause
exit /b 0

REM =====================================================
REM BUILD FUNCTION
REM =====================================================

:build

set PLATFORM=%1
set CONFIG=%2

echo.
echo =====================================
echo Building %PLATFORM% %CONFIG%
echo =====================================

msbuild "%SOLUTION%" ^
/t:Build ^
/p:Configuration=%CONFIG% ^
/p:Platform=%PLATFORM%

if errorlevel 1 (
    echo [ERROR] Build failed.
    exit /b 1
)

REM =====================================================
REM EXPORT
REM =====================================================

set OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%\%CONFIG%

mkdir "%OUT_DIR%" >nul 2>&1

for /r "%SOURCE_DIR%" %%f in (*.lib *.dll *.pdb) do (
    copy /Y "%%f" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG%

exit /b 0