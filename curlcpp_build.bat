@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo =====================================
echo        CURLCPP BUILD SCRIPT
echo =====================================

REM ==========================================================
REM ROOT PATHS
REM ==========================================================

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT_DIR=%%~fI"

set "SOURCE_DIR=%ROOT_DIR%\curlcpp"
set "BUILD_ROOT=%ROOT_DIR%\build\curlcpp"
set "CURL_DIR=%ROOT_DIR%\curl"

echo.
echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%
echo Curl   : %CURL_DIR%

REM ==========================================================
REM CHECKS
REM ==========================================================

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
    echo.
    echo [ERROR] curlcpp source not found.
    pause
    exit /b 1
)

if not exist "%CURL_DIR%\include" (
    echo.
    echo [ERROR] curl include directory not found.
    pause
    exit /b 1
)

REM ==========================================================
REM BUILD MATRIX
REM ==========================================================

call :build x64 Debug
if errorlevel 1 goto :failed

call :build x64 Release
if errorlevel 1 goto :failed

call :build x86 Debug
if errorlevel 1 goto :failed

call :build x86 Release
if errorlevel 1 goto :failed

echo.
echo =====================================
echo      CURLCPP BUILD SUCCESS
echo =====================================
pause
exit /b 0

:failed
echo.
echo =====================================
echo      CURLCPP BUILD FAILED
echo =====================================
pause
exit /b 1

REM ==========================================================
REM BUILD FUNCTION
REM ==========================================================

:build

set "PLATFORM=%~1"
set "CONFIG=%~2"

if /I "%PLATFORM%"=="x86" (
    set "ARCH=Win32"
) else (
    set "ARCH=x64"
)

if /I "%CONFIG%"=="Debug" (
    set "RUNTIME=MultiThreadedDebug"
    set "CURL_LIB=%ROOT_DIR%\build\curl\lib\%PLATFORM%\Debug\libcurl-d.lib"
) else (
    set "RUNTIME=MultiThreaded"
    set "CURL_LIB=%ROOT_DIR%\build\curl\lib\%PLATFORM%\Release\libcurl.lib"
)

set "BUILD_DIR=%BUILD_ROOT%\build_tmp\%PLATFORM%\%CONFIG%"
set "OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%\%CONFIG%"

echo.
echo =====================================
echo Building: %PLATFORM% %CONFIG%
echo =====================================

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"

mkdir "%BUILD_DIR%"
mkdir "%OUT_DIR%"

cd /d "%BUILD_DIR%"

REM ==========================================================
REM CONFIGURE
REM ==========================================================

cmake "%SOURCE_DIR%" ^
-G "Visual Studio 17 2022" ^
-T v143 ^
-A %ARCH% ^
-DCMAKE_INSTALL_PREFIX="%OUT_DIR%" ^
-DCURL_INCLUDE_DIR="%CURL_DIR%\include" ^
-DCURL_LIBRARY="%CURL_LIB%" ^
-DBUILD_SHARED_LIBS=OFF ^
-DCMAKE_MSVC_RUNTIME_LIBRARY="%RUNTIME%"

if errorlevel 1 (
    echo.
    echo [ERROR] Configure failed.
    exit /b 1
)

REM ==========================================================
REM BUILD
REM ==========================================================

cmake --build . --config %CONFIG% --target curlcpp

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed.
    exit /b 1
)

REM ==========================================================
REM COPY OUTPUT
REM ==========================================================

set "LIB_SRC=%BUILD_DIR%\src\%CONFIG%\curlcpp.lib"

if not exist "%LIB_SRC%" (
    echo.
    echo [ERROR] curlcpp.lib not found:
    echo %LIB_SRC%
    exit /b 1
)

copy /Y "%LIB_SRC%" "%OUT_DIR%\curlcpp.lib" >nul

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to copy curlcpp.lib
    exit /b 1
)

echo.
echo [OK] %PLATFORM% %CONFIG%

exit /b 0