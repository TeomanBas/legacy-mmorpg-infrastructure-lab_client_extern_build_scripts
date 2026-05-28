@echo off
setlocal enabledelayedexpansion

echo =====================================
echo       OPENEXR 3.4 BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\OpenEXR
set BUILD_ROOT=%ROOT_DIR%\build\OpenEXR

set IMATH_DIR=%ROOT_DIR%\build\Imath

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%
echo Imath  : %IMATH_DIR%

REM =========================
REM CHECK SOURCE
REM =========================

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
    echo [ERROR] OpenEXR source not found!
    pause
    exit /b 1
)

REM =========================
REM CLEAN OLD BUILD (optional)
REM =========================

REM if exist "%BUILD_ROOT%" rmdir /s /q "%BUILD_ROOT%"

REM =========================
REM BUILD MATRIX
REM =========================

call :build x64 Debug
call :build x64 Release
call :build x86 Debug
call :build x86 Release

echo.
echo =====================================
echo     OPENEXR BUILD COMPLETED
echo =====================================
pause
exit /b 0


REM =========================
REM BUILD FUNCTION
REM =========================

:build
set PLATFORM=%1
set CONFIG=%2

if "%PLATFORM%"=="x86" (
    set ARCH=Win32
) else (
    set ARCH=x64
)

set BUILD_DIR=%BUILD_ROOT%\build_tmp\%PLATFORM%\%CONFIG%
set OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%\%CONFIG%

echo.
echo =====================================
echo Building OpenEXR %PLATFORM% - %CONFIG%
echo =====================================

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
mkdir "%OUT_DIR%"

cd /d "%BUILD_DIR%"

REM =========================
REM CMAKE CONFIGURE
REM =========================

cmake "%SOURCE_DIR%" ^
-G "Visual Studio 17 2022" ^
-A %ARCH% ^
-DCMAKE_BUILD_TYPE=%CONFIG% ^
-DCMAKE_INSTALL_PREFIX="%OUT_DIR%" ^
-DImath_DIR="%IMATH_DIR%" ^
-DCMAKE_PREFIX_PATH="%IMATH_DIR%" ^
-DBUILD_SHARED_LIBS=OFF

if errorlevel 1 (
    echo [ERROR] Configure failed %PLATFORM% %CONFIG%
    exit /b 1
)

REM =========================
REM BUILD
REM =========================

cmake --build . --config %CONFIG%

if errorlevel 1 (
    echo [ERROR] Build failed %PLATFORM% %CONFIG%
    exit /b 1
)

REM =========================
REM COPY ARTIFACTS
REM =========================

echo [INFO] Copying libs...

for /r "%BUILD_DIR%" %%F in (*.lib) do (
    copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

for /r "%BUILD_DIR%" %%F in (*.dll) do (
    copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG%
exit /b 0