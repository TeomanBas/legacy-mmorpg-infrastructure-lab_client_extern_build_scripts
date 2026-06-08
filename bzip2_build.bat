@echo off
setlocal enabledelayedexpansion

echo =====================================
echo         BZIP2 CLEAN BUILD
echo     (x86 / x64 ONLY - NMAKE)
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\bzip2
set BUILD_ROOT=%ROOT_DIR%\build\bzip2

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

if not exist "%SOURCE_DIR%\makefile.msc" (
    echo [ERROR] makefile.msc not found!
    pause
    exit /b 1
)

REM =========================
REM BUILD BOTH PLATFORMS
REM =========================

call :build x64
call :build x86

echo.
echo =====================================
echo        BZIP2 BUILD COMPLETED
echo =====================================

pause
exit /b 0


REM =========================
REM BUILD FUNCTION
REM =========================
:build

set PLATFORM=%1

set BUILD_DIR=%BUILD_ROOT%\build_tmp\%PLATFORM%
REM =========================
REM Debug directory or release directory 
REM =========================
set OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%\Debug\

echo.
echo =====================================
echo Building bzip2 - %PLATFORM%
echo =====================================

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
mkdir "%OUT_DIR%"

cd /d "%SOURCE_DIR%"

REM =========================
REM SET MSVC ENV
REM =========================

if "%PLATFORM%"=="x64" (
    echo [INFO] Setting x64 environment...
    call "%VSINSTALLDIR%VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
) else (
    echo [INFO] Setting x86 environment...
    call "%VSINSTALLDIR%VC\Auxiliary\Build\vcvars32.bat" >nul 2>&1
)

if errorlevel 1 (
    echo [WARNING] vcvars not found via VSINSTALLDIR, trying fallback...
)

REM =========================
REM CLEAN + BUILD
REM =========================

echo [INFO] Cleaning...
nmake -f makefile.msc clean >nul 2>&1

echo [INFO] Building...
REM =========================
REM for release 
REM =========================
REM nmake -f makefile.msc CFLAGS="-DWIN32 -MT -Ox -D_FILE_OFFSET_BITS=64 -nologo"
REM =========================
REM for debug 
REM =========================
nmake -f makefile.msc CFLAGS="-DWIN32 -MTd -Od -Zi -D_FILE_OFFSET_BITS=64 -nologo"
REM =========================
if errorlevel 1 (
    echo [ERROR] Build failed for %PLATFORM%
    exit /b 1
)

REM =========================
REM COPY OUTPUTS
REM =========================

echo [INFO] Copying outputs...

for %%F in (libbz2.lib bzip2.exe bzip2recover.exe) do (
    if exist "%%F" copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

REM =========================
REM COPY HEADERS
REM =========================

if not exist "%OUT_DIR%\include" mkdir "%OUT_DIR%\include"
copy /Y "%SOURCE_DIR%\bzlib.h" "%OUT_DIR%\include\" >nul 2>&1

echo [OK] %PLATFORM% DONE

exit /b 0