@echo off
setlocal enabledelayedexpansion

echo =====================================
echo      FULL AUTO BUILD PIPELINE
echo =====================================

REM =========================
REM ROOT
REM =========================

set SCRIPT_DIR=%~dp0

for %%I in ("%SCRIPT_DIR%..") do (
set ROOT_DIR=%%~fI
)

set LIBTORRENT_DIR=%ROOT_DIR%\libtorrent

echo Root   : %ROOT_DIR%
echo libtorrent  : %LIBTORRENT_DIR%

REM =========================
REM CHECK GIT
REM =========================

git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git not found in PATH
    pause
    exit /b 1
)

REM =========================
REM SUBMODULE UPDATE
REM =========================

if not exist "%LIBTORRENT_DIR%\.git" (
    echo [ERROR] Not a git repository: %LIBTORRENT_DIR%
    pause
    exit /b 1
)

echo.
echo =====================================
echo   Updating submodules...
echo =====================================

pushd "%LIBTORRENT_DIR%"

git submodule sync --recursive
git submodule update --init --recursive

if errorlevel 1 (
    echo [ERROR] Submodule update failed
    popd
    pause
    exit /b 1
)

popd


REM =========================
REM BUILD
REM =========================

echo.
echo =====================================
echo   BUILD STARTING
echo =====================================

call "%SCRIPT_DIR%\libtorrent_build.bat"

if errorlevel 1 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)

echo.
echo =====================================
echo   ALL DONE SUCCESSFULLY
echo =====================================

pause
exit /b 0