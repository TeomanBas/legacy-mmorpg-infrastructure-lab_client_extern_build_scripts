@echo off
setlocal enabledelayedexpansion

echo =====================================
echo         LIBZIP BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\libzip
set BUILD_ROOT=%ROOT_DIR%\build\libzip

set ZLIB_DIR=%ROOT_DIR%\build\zlib
set ZSTD_DIR=%ROOT_DIR%\build\zstd

REM =========================
REM PATH NORMALIZATION
REM =========================

set ZLIB_DIR=%ZLIB_DIR:\=/%
set ZSTD_DIR=%ZSTD_DIR:\=/%

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

REM =========================
REM CHECK SOURCE
REM =========================

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
    echo [ERROR] libzip source not found!
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
echo         LIBZIP COMPLETED
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
echo Building libzip %PLATFORM% - %CONFIG%
echo =====================================

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
mkdir "%OUT_DIR%"

cd /d "%BUILD_DIR%"

REM =========================
REM CONFIG-SPECIFIC LIBS
REM =========================

if "%CONFIG%"=="Debug" (

    set ZLIB_LIB=%ROOT_DIR%\build\zlib\lib\%PLATFORM%\%CONFIG%\Debug\zd.lib
    set ZSTD_LIB=%ROOT_DIR%\build\zstd\lib\%PLATFORM%\Debug\zstd_static.lib

) else (

    set ZLIB_LIB=%ROOT_DIR%\build\zlib\lib\%PLATFORM%\%CONFIG%\Release\z.lib
    set ZSTD_LIB=%ROOT_DIR%\build\zstd\lib\%PLATFORM%\Release\zstd_static.lib

)

REM =========================
REM INCLUDE DIRS
REM =========================

set ZLIB_INC=%ROOT_DIR%\zlib
set ZSTD_INC=%ROOT_DIR%\zstd\lib

REM =========================
REM CMAKE CONFIGURE
REM =========================

cmake "%SOURCE_DIR%" ^
-G "Visual Studio 17 2022" ^
-A %ARCH% ^
-DCMAKE_BUILD_TYPE=%CONFIG% ^
-DCMAKE_INSTALL_PREFIX="%OUT_DIR%" ^
-DBUILD_SHARED_LIBS=OFF ^
-DENABLE_COMMONCRYPTO=OFF ^
-DENABLE_GNUTLS=OFF ^
-DENABLE_MBEDTLS=OFF ^
-DENABLE_OPENSSL=OFF ^
-DENABLE_WINDOWS_CRYPTO=ON ^
-DENABLE_BZIP2=OFF ^
-DENABLE_LZMA=OFF ^
-DENABLE_ZSTD=ON ^
-DZLIB_LIBRARY="%ZLIB_LIB%" ^
-DZLIB_INCLUDE_DIR="%ZLIB_INC%" ^
-DZSTD_LIBRARY="%ZSTD_LIB%" ^
-DZSTD_INCLUDE_DIR="%ZSTD_INC%"

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

for /r "%BUILD_DIR%" %%F in (*.lib *.dll *.exe) do (
    copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

echo [OK] %PLATFORM% %CONFIG%
exit /b 0