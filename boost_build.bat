@echo off
setlocal enabledelayedexpansion

echo =====================================
echo          BOOST BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATHS
REM =========================

set SCRIPT_DIR=%~dp0

for %%I in ("%SCRIPT_DIR%..") do (
set ROOT_DIR=%%~fI
)

set BOOST_DIR=%ROOT_DIR%\boost
set OUT_ROOT=%ROOT_DIR%\build\boost\

echo Root  : %ROOT_DIR%
echo Boost : %BOOST_DIR%
echo Out   : %OUT_ROOT%

if not exist "%BOOST_DIR%\b2.exe" (
echo [ERROR] b2.exe not found.
echo Run bootstrap.bat first.
pause
exit /b 1
)

REM =========================
REM BUILD MATRIX
REM =========================

call :build x86 Debug
call :build x86 Release
call :build x64 Debug
call :build x64 Release

echo.
echo =====================================
echo         BOOST BUILD DONE
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
set ADDRESS_MODEL=32
) else (
set ADDRESS_MODEL=64
)

if "%CONFIG%"=="Debug" (
set VARIANT=debug
set RUNTIME=runtime-debugging=on
) else (
set VARIANT=release
set RUNTIME=runtime-debugging=off
)

set OUT_DIR=%OUT_ROOT%\%PLATFORM%\%CONFIG%

if not exist "%OUT_DIR%" (
mkdir "%OUT_DIR%"
)

echo.
echo =====================================
echo Building %PLATFORM% %CONFIG%
echo =====================================

pushd "%BOOST_DIR%"

b2 ^
--build-dir=build_tmp/%PLATFORM%/%CONFIG% ^
--stagedir="%OUT_DIR%" ^
toolset=msvc-14.3 ^
address-model=%ADDRESS_MODEL% ^
variant=%VARIANT% ^
link=static ^
runtime-link=static ^
threading=multi ^
%RUNTIME% ^
cxxflags="/D__SSE2__ /arch:SSE2" ^
--with-filesystem ^
--with-system ^
--with-thread ^
--with-chrono ^
--with-date_time ^
--with-atomic ^
--with-iostreams ^
--with-locale ^
--with-regex ^
stage

if errorlevel 1 (
popd
echo [ERROR] Build failed (%PLATFORM% %CONFIG%)
pause
exit /b 1
)

popd

echo [OK] %PLATFORM% %CONFIG%

exit /b 0
