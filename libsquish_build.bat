@echo off
setlocal enabledelayedexpansion

echo =====================================
echo         LIBSQUISH BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0

for %%I in ("%SCRIPT_DIR%..") do (
set ROOT_DIR=%%~fI
)

set SOURCE_DIR=%ROOT_DIR%\libsquish
set BUILD_ROOT=%ROOT_DIR%\build\libsquish

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
echo [ERROR] libsquish source not found
pause
exit /b 1
)

call :build x64 Debug
call :build x64 Release
call :build x86 Debug
call :build x86 Release

echo.
echo =====================================
echo       LIBSQUISH BUILD DONE
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
echo Building libsquish %PLATFORM% - %CONFIG%
echo =====================================

if exist "%BUILD_DIR%" (
rmdir /s /q "%BUILD_DIR%"
)

mkdir "%BUILD_DIR%"

if not exist "%OUT_DIR%" (
mkdir "%OUT_DIR%"
)

cd /d "%BUILD_DIR%"

REM =========================
REM CONFIGURE
REM =========================

cmake "%SOURCE_DIR%" ^
-G "Visual Studio 17 2022" ^
-A %ARCH% ^
-DCMAKE_BUILD_TYPE=%CONFIG% ^
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
-DBUILD_SHARED_LIBS=OFF ^
-DBUILD_SQUISH_WITH_OPENMP=OFF ^
-DBUILD_SQUISH_WITH_SSE2=ON ^
-DBUILD_SQUISH_WITH_ALTIVEC=OFF ^
-DCMAKE_SUPPRESS_REGENERATION=ON

if errorlevel 1 (
echo [ERROR] Configure failed %PLATFORM% %CONFIG%
pause
exit /b 1
)

REM =========================
REM BUILD
REM =========================

cmake --build . --config %CONFIG%

if errorlevel 1 (
echo [ERROR] Build failed %PLATFORM% %CONFIG%
pause
exit /b 1
)

REM =========================
REM COPY OUTPUTS
REM =========================

echo [INFO] Copying outputs...

for /r "%BUILD_DIR%" %%F in (*.lib *.dll *.exe) do (
copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

REM =========================
REM COPY HEADERS
REM =========================

if not exist "%OUT_DIR%\include" (
mkdir "%OUT_DIR%\include"
)

copy /Y "%SOURCE_DIR%*.h" "%OUT_DIR%\include" >nul 2>&1

echo [OK] %PLATFORM% %CONFIG%

exit /b 0
