@echo off
setlocal enabledelayedexpansion

echo =====================================
echo           LIBPNG BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\libpng
set ZLIB_DIR=%ROOT_DIR%\zlib
set BUILD_ROOT=%ROOT_DIR%\build\libpng

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Zlib   : %ZLIB_DIR%
echo Build  : %BUILD_ROOT%

REM =========================
REM CHECKS
REM =========================

if not exist "%SOURCE_DIR%" (
    echo [ERROR] libpng source not found
    pause
    exit /b 1
)

if not exist "%ZLIB_DIR%" (
    echo [ERROR] zlib source not found
    pause
    exit /b 1
)

if exist "%BUILD_ROOT%" (
    rmdir /s /q "%BUILD_ROOT%"
)

REM =========================
REM BUILD MATRIX
REM =========================

call :build x64 Debug
call :build x64 Release
call :build x86 Debug
call :build x86 Release

echo.
echo =====================================
echo       LIBPNG BUILD COMPLETED
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

REM =========================
REM SELECT ZLIB LIB NAME
REM =========================

set ZLIB_LIB=

if "%CONFIG%"=="Debug" (
    set ZLIB_LIB=zd.lib
)

if "%CONFIG%"=="Release" (
    set ZLIB_LIB=z.lib
)

REM =========================
REM PATHS
REM =========================

set BUILD_DIR=%BUILD_ROOT%\build_tmp\%PLATFORM%\%CONFIG%
set OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%\%CONFIG%
set ZLIB_LIB_PATH=%ROOT_DIR%\build\zlib\lib\%PLATFORM%\%CONFIG%\%CONFIG%\%ZLIB_LIB%

echo.
echo =====================================
echo Building libpng %PLATFORM% - %CONFIG%
echo ZLIB LIB : %ZLIB_LIB%
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
-DZLIB_INCLUDE_DIR="%ZLIB_DIR%" ^
-DZLIB_LIBRARY="%ZLIB_LIB_PATH%" ^
-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%OUT_DIR%" ^
-DCMAKE_LIBRARY_OUTPUT_DIRECTORY="%OUT_DIR%" ^
-DCMAKE_RUNTIME_OUTPUT_DIRECTORY="%OUT_DIR%"

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
REM EXPORT SAFETY COPY
REM =========================

echo [INFO] Exporting artifacts...

for %%f in (*.lib *.dll *.exe) do (
    if exist "%%f" copy /Y "%%f" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG%
exit /b 0