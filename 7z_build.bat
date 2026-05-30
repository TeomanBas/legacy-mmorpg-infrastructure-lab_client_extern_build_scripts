@echo off
setlocal EnableDelayedExpansion

echo =====================================
echo           7ZIP BUILD SCRIPT
echo =====================================

REM ====================================================
REM ROOT PATH
REM ====================================================

set SCRIPT_DIR=%~dp0

for %%I in ("%SCRIPT_DIR%..") do (
    set ROOT_DIR=%%~fI
)

set SOURCE_DIR=%ROOT_DIR%\7zip
set BUILD_ROOT=%ROOT_DIR%\build\7zip

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

if not exist "%SOURCE_DIR%\CPP\7zip\UI\Client7z\makefile" (
    echo [ERROR] 7-Zip source not found
    pause
    exit /b 1
)

call :build x64
call :build x86

echo.
echo =====================================
echo         7ZIP BUILD COMPLETED
echo =====================================

pause
exit /b 0

REM ====================================================
REM BUILD FUNCTION
REM ====================================================

:build

set PLATFORM=%1

echo.
echo =====================================
echo Building 7-Zip %PLATFORM%
echo =====================================

set BUILD_DIR=%BUILD_ROOT%\build_tmp\%PLATFORM%
set OUT_DIR=%BUILD_ROOT%\bin\%PLATFORM%

if exist "%BUILD_DIR%" (
    rmdir /s /q "%BUILD_DIR%"
)

mkdir "%BUILD_DIR%"

if not exist "%OUT_DIR%" (
    mkdir "%OUT_DIR%"
)

REM ====================================================
REM VISUAL STUDIO ENVIRONMENT
REM ====================================================

if "%PLATFORM%"=="x64" (
    call "%ProgramFiles%\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
) else (
    call "%ProgramFiles%\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars32.bat"
)

if errorlevel 1 (
    echo [ERROR] Failed to load Visual Studio environment
    exit /b 1
)

REM ====================================================
REM BUILD
REM ====================================================

cd /d "%SOURCE_DIR%\CPP\7zip\UI\Console"

nmake -f makefile clean

nmake ^
PLATFORM=%PLATFORM% ^
O="%BUILD_DIR%"

if errorlevel 1 (
    echo [ERROR] Build failed %PLATFORM%
    pause
    exit /b 1
)

REM ====================================================
REM COPY OUTPUTS
REM ====================================================

echo [INFO] Copying outputs...

if exist "%BUILD_DIR%\7z.exe" (
    copy /Y "%BUILD_DIR%\7z.exe" "%OUT_DIR%\" >nul
)

if exist "%BUILD_DIR%\7z.dll" (
    copy /Y "%BUILD_DIR%\7z.dll" "%OUT_DIR%\" >nul
)

echo [OK] %PLATFORM%

exit /b 0