@echo off
setlocal enabledelayedexpansion

echo =====================================
echo          LZO BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\lzo-2.10
set BUILD_ROOT=%ROOT_DIR%\build\lzo

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

REM =========================
REM CHECK SOURCE
REM =========================

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
    echo [ERROR] LZO source not found!
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
echo          LZO BUILD DONE
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
echo Building LZO %PLATFORM% - %CONFIG%
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
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
-DCMAKE_INSTALL_PREFIX="%OUT_DIR%" ^
-DBUILD_SHARED_LIBS=OFF ^
-DENABLE_SHARED=OFF ^
-DENABLE_STATIC=ON ^
-DLZO_BUILD_TESTS=OFF ^
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
REM COPY OUTPUTS
REM =========================

echo [INFO] Copying artifacts...

for /r "%BUILD_DIR%" %%F in (*.lib *.dll *.exe *.pdb) do (
    copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG%
exit /b 0