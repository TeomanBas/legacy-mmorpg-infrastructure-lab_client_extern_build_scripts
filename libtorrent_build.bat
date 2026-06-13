@echo off
setlocal enabledelayedexpansion

echo =====================================
echo       LIBTORRENT BUILD SCRIPT
echo =====================================

REM =====================================
REM ROOT PATHS
REM =====================================

set SCRIPT_DIR=%~dp0

for %%I in ("%SCRIPT_DIR%..") do (
    set ROOT_DIR=%%~fI
)

set SOURCE_DIR=%ROOT_DIR%\libtorrent
set BUILD_ROOT=%ROOT_DIR%\build\libtorrent

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
    echo [ERROR] libtorrent source not found
    pause
    exit /b 1
)

REM =====================================
REM BOOST
REM =====================================

set BOOST_ROOT=%ROOT_DIR%\boost

if not exist "%BOOST_ROOT%" (
    echo [ERROR] Boost not found
    pause
    exit /b 1
)

REM =====================================
REM BUILD MATRIX
REM =====================================

call :build x86 Debug
call :build x86 Release
call :build x64 Debug
call :build x64 Release

echo.
echo =====================================
echo      LIBTORRENT BUILD DONE
echo =====================================

pause
exit /b 0


:build

set PLATFORM=%1
set CONFIG=%2

if "%PLATFORM%"=="x86" (
    set ARCH=Win32
    set ADDRESS_MODEL=32
) else (
    set ARCH=x64
    set ADDRESS_MODEL=64
)

set BUILD_DIR=%BUILD_ROOT%\build_tmp\%PLATFORM%\%CONFIG%
set OUT_DIR=%BUILD_ROOT%\lib\%PLATFORM%\%CONFIG%

echo.
echo =====================================
echo Building libtorrent %PLATFORM% %CONFIG%
echo =====================================

if exist "%BUILD_DIR%" (
    rmdir /s /q "%BUILD_DIR%"
)

mkdir "%BUILD_DIR%"

if not exist "%OUT_DIR%" (
    mkdir "%OUT_DIR%"
)

cd /d "%BUILD_DIR%"

REM =====================================
REM RUNTIME
REM =====================================

if "%CONFIG%"=="Debug" (
    set RUNTIME=MultiThreadedDebug
) else (
    set RUNTIME=MultiThreaded
)

REM =====================================
REM CMAKE CONFIGURE
REM =====================================

cmake "%SOURCE_DIR%" ^
-G "Visual Studio 17 2022" ^
-A %ARCH% ^
-DCMAKE_BUILD_TYPE=%CONFIG% ^
-DCMAKE_MSVC_RUNTIME_LIBRARY=%RUNTIME% ^
-DBUILD_SHARED_LIBS=OFF ^
-Ddeprecated-functions=ON ^
-Dbuild_tests=OFF ^
-Dbuild_examples=OFF ^
-Dbuild_tools=OFF ^
-Dbuild_fuzzers=OFF ^
-Dpython-bindings=OFF ^
-Dstatic_runtime=ON ^
-Dboost-link=static ^
-Dopenssl-link=none ^
-Dcrypto=wincrypto ^
-DBOOST_ROOT="%BOOST_ROOT%" ^
-DCMAKE_INSTALL_PREFIX="%OUT_DIR%"

if errorlevel 1 (
    echo [ERROR] Configure failed %PLATFORM% %CONFIG%
    pause
    exit /b 1
)

REM =====================================
REM BUILD
REM =====================================

cmake --build . --config %CONFIG%

if errorlevel 1 (
    echo [ERROR] Build failed %PLATFORM% %CONFIG%
    pause
    exit /b 1
)

REM =====================================
REM INSTALL
REM =====================================

cmake --install . --config %CONFIG%

REM =====================================
REM COPY EXTRA LIBS
REM =====================================

for /r "%BUILD_DIR%" %%F in (*.lib) do (
    copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG%

exit /b 0