@echo off
setlocal enabledelayedexpansion

echo =====================================
echo        CURLCPP BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\curlcpp
set BUILD_ROOT=%ROOT_DIR%\build\curlcpp

set CURL_DIR=%ROOT_DIR%\curl

REM =========================
REM PATH NORMALIZATION (CRITICAL FIX)
REM =========================

set CURL_DIR=%CURL_DIR:\=/%

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%
echo Curl   : %CURL_DIR%

REM =========================
REM CHECK SOURCE
REM =========================

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
    echo [ERROR] curlcpp source not found!
    pause
    exit /b 1
)

if not exist "%CURL_DIR%\include" (
    echo [ERROR] curl include not found!
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
echo        CURLCPP COMPLETED
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


REM =========================
REM DEPENDENCIES
REM =========================

if "%CONFIG%"=="Debug" (
set CURL_LIB=%ROOT_DIR%\build\curl\lib\%PLATFORM%\%CONFIG%\libcurl-d.lib
) else (
set CURL_LIB=%ROOT_DIR%\build\curl\lib\%PLATFORM%\%CONFIG%\libcurl.lib
)

set BUILD_DIR=%BUILD_ROOT%\build_tmp\%PLATFORM%\%CONFIG%
set OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%\%CONFIG%

echo.
echo =====================================
echo Building curlcpp %PLATFORM% - %CONFIG%
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
-DCURL_INCLUDE_DIR="%ROOT_DIR%\curl\include" ^
-DCURL_LIBRARY=%CURL_LIB% ^
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
REM COPY OUTPUT
REM =========================

echo [INFO] Copying artifacts...

for /r "%BUILD_DIR%" %%F in (*.lib *.dll *.exe) do (
    copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG%
exit /b 0