@echo off
setlocal EnableDelayedExpansion

echo =====================================
echo        7ZIP FULL BUILD SCRIPT
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

set OUT_DIR=%BUILD_ROOT%\bin

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

if not exist "%SOURCE_DIR%\CPP\7zip\Bundles\Alone2\makefile" (
    echo [ERROR] 7-Zip source not found
    pause
    exit /b 1
)

call :build x86
call :build x64

echo.
echo =====================================
echo     7ZIP BUILD COMPLETED
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
echo BUILD PLATFORM: %PLATFORM%
echo =====================================

set TMP=%BUILD_ROOT%\build_tmp\%PLATFORM%
set BIN=%OUT_DIR%\%PLATFORM%

if exist "%TMP%" rmdir /s /q "%TMP%"
mkdir "%TMP%"

if not exist "%BIN%" mkdir "%BIN%"

REM ====================================================
REM VISUAL STUDIO ENV
REM ====================================================

if "%PLATFORM%"=="x64" (
    call "%ProgramFiles%\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
) else (
    call "%ProgramFiles%\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars32.bat"
)

if errorlevel 1 (
    echo [ERROR] VC environment failed
    exit /b 1
)

REM ====================================================
REM 1) BUILD EXE (Alone2 -> 7zz.exe)
REM ====================================================

echo [STEP] Building EXE (7zz.exe)

cd /d "%SOURCE_DIR%\CPP\7zip\Bundles\Alone2"

nmake clean
nmake PLATFORM=%PLATFORM% O="%TMP%\exe"

if errorlevel 1 (
    echo [ERROR] EXE build failed
    exit /b 1
)

if exist "%TMP%\exe\7zz.exe" (
    copy /Y "%TMP%\exe\7zz.exe" "%BIN%\7zz.exe" >nul
)

REM ====================================================
REM 2) BUILD DLL (Format7z -> 7za.dll)
REM ====================================================

echo [STEP] Building DLL (7za.dll)

cd /d "%SOURCE_DIR%\CPP\7zip\Bundles\Format7z"

nmake clean
nmake PLATFORM=%PLATFORM% O="%TMP%\dll"

if errorlevel 1 (
    echo [ERROR] DLL build failed
    exit /b 1
)

if exist "%TMP%\dll\7za.dll" (
    copy /Y "%TMP%\dll\7za.dll" "%BIN%\7za.dll" >nul
)

REM ====================================================
REM DONE
REM ====================================================

echo [OK] %PLATFORM% DONE
exit /b 0