@echo off
setlocal enabledelayedexpansion

echo =====================================
echo         LIBCURL BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0

for %%I in ("%SCRIPT_DIR%..") do (
set ROOT_DIR=%%~fI
)

set SOURCE_DIR=%ROOT_DIR%\curl
set BUILD_ROOT=%ROOT_DIR%\build\curl

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

REM =========================
REM CHECK SOURCE
REM =========================

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
echo [ERROR] curl source not found!
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
echo         LIBCURL BUILD DONE
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
echo Building curl %PLATFORM% - %CONFIG%
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
REM ZLIB
REM =========================
set ZLIB_INC=%ROOT_DIR%\zlib


REM =========================
REM DEPENDENCIES
REM =========================

if "%CONFIG%"=="Debug" (
set ZLIB_LIB=%ROOT_DIR%\build\zlib\lib\%PLATFORM%\%CONFIG%\zd.lib
) else (
set ZLIB_LIB=%ROOT_DIR%\build\zlib\lib\%PLATFORM%\%CONFIG%\z.lib
)

REM =========================
REM CMAKE CONFIGURE
REM =========================

cmake "%SOURCE_DIR%" ^
-G "Visual Studio 17 2022" ^
-A %ARCH% ^
-DCMAKE_BUILD_TYPE=%CONFIG% ^
-DCMAKE_INSTALL_PREFIX="%OUT_DIR%" ^
-DCMAKE_MSVC_RUNTIME_LIBRARY="%RUNTIME%" ^
-DBUILD_SHARED_LIBS=OFF ^
-DBUILD_STATIC_LIBS=ON ^
-DBUILD_CURL_EXE=OFF ^
-DBUILD_LIBCURL_DOCS=OFF ^
-DBUILD_MISC_DOCS=OFF ^
-DBUILD_TESTING=OFF ^
-DCURL_USE_SCHANNEL=ON ^
-DCURL_USE_OPENSSL=OFF ^
-DCURL_USE_LIBPSL=OFF ^
-DCURL_ZLIB=ON ^
-DZLIB_LIBRARY="%ZLIB_LIB%" ^
-DZLIB_INCLUDE_DIR="%ZLIB_INC%" 

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

echo [INFO] Copying artifacts...

for /r "%BUILD_DIR%" %%F in (*.lib *.dll *.exe) do (
copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG%

exit /b 0
