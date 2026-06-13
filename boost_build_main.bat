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

set BOOST_DIR=%ROOT_DIR%\boost

echo Root   : %ROOT_DIR%
echo Boost  : %BOOST_DIR%

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

if not exist "%BOOST_DIR%\.git" (
    echo [ERROR] Not a git repository: %BOOST_DIR%
    pause
    exit /b 1
)

echo.
echo =====================================
echo   Updating submodules...
echo =====================================

pushd "%BOOST_DIR%"

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
REM BOOTSTRAP
REM =========================

echo.
echo =====================================
echo   Running bootstrap...
echo =====================================

pushd "%BOOST_DIR%"

if not exist bootstrap.bat (
    echo [ERROR] bootstrap.bat not found
    popd
    pause
    exit /b 1
)

call bootstrap.bat

if errorlevel 1 (
    echo [ERROR] Bootstrap failed
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

call "%SCRIPT_DIR%\boost_build.bat"

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