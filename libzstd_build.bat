@echo off
setlocal enabledelayedexpansion

echo =====================================
echo         ZSTD BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\zstd\build\cmake
set BUILD_ROOT=%ROOT_DIR%\build\zstd

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

REM =========================
REM CHECK SOURCE
REM =========================

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
    echo [ERROR] zstd source not found!
    pause
    exit /b 1
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
echo         ZSTD BUILD DONE
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

if "%CONFIG%"=="Debug" (
    set RUNTIME=MultiThreadedDebug
) else (
    set RUNTIME=MultiThreaded
)


set BUILD_DIR=%BUILD_ROOT%\build_tmp\%PLATFORM%\%CONFIG%
set OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%\%CONFIG%

echo.
echo =====================================
echo Building zstd %PLATFORM% - %CONFIG%
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
-DZSTD_BUILD_PROGRAMS=OFF ^
-DZSTD_BUILD_SHARED=OFF ^
-DZSTD_BUILD_STATIC=ON ^
-DZSTD_BUILD_TESTS=OFF ^
-DCMAKE_MSVC_RUNTIME_LIBRARY="%RUNTIME%"

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
REM COPY OUTPUT
REM =========================

echo [INFO] Copying artifacts...

for /r "%BUILD_DIR%" %%F in (*.lib *.dll *.exe *.pdb) do (
    copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG%
exit /b 0