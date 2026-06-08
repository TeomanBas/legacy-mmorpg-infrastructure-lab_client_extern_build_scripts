@echo off
setlocal enabledelayedexpansion

echo =====================================
echo          IMATH BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\Imath
set BUILD_ROOT=%ROOT_DIR%\build\Imath

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

REM =========================
REM CHECK SOURCE
REM =========================

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
    echo [ERROR] Imath source not found!
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
echo        IMATH BUILD DONE
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
set OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%

echo.
echo =====================================
echo Building Imath %PLATFORM% - %CONFIG%
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
-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%OUT_DIR%" ^
-DCMAKE_LIBRARY_OUTPUT_DIRECTORY="%OUT_DIR%" ^
-DCMAKE_RUNTIME_OUTPUT_DIRECTORY="%OUT_DIR%" ^
-DBUILD_SHARED_LIBS=OFF ^
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
REM EXPORT (SAFETY COPY)
REM =========================

echo [INFO] Exporting artifacts...

for %%f in (*.lib *.dll *.exe) do (
    if exist "%%f" copy /Y "%%f" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG% completed
exit /b 0