@echo off
setlocal enabledelayedexpansion

echo =====================================
echo         LIBMNG BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\libmng-2.0.3
set BUILD_ROOT=%ROOT_DIR%\build

REM =========================
REM DEPENDENCIES
REM =========================

set ZLIB_DIR=%ROOT_DIR%\zlib
set JPEG_SRC_DIR=%ROOT_DIR%\libjpeg-turbo\src
set JPEG_BUILD_DIR=%BUILD_ROOT%\libjpeg-turbo
set LCMS2_INCLUDE_DIR=%ROOT_DIR%\Little-CMS\include

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

REM =========================
REM CHECK SOURCE
REM =========================

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
echo [ERROR] libmng source not found!
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
echo         LIBMNG COMPLETED
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

set BUILD_DIR=%BUILD_ROOT%\libmng\build_tmp\%PLATFORM%\%CONFIG%
set OUT_DIR=%BUILD_ROOT%\libmng\lib\%PLATFORM%\%CONFIG%

echo.
echo =====================================
echo Building libmng %PLATFORM% - %CONFIG%
echo =====================================

if exist "%BUILD_DIR%" (
rmdir /s /q "%BUILD_DIR%"
)

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

cd /d "%BUILD_DIR%"

REM =========================
REM DEPENDENCY LIBS
REM =========================

if /I "%CONFIG%"=="Debug" (


set ZLIB_LIB=%BUILD_ROOT%\zlib\lib\%PLATFORM%\Debug\Debug\zd.lib
set JPEG_LIB=%BUILD_ROOT%\libjpeg-turbo\lib\%PLATFORM%\Debug\Debug\jpeg-static.lib
set LCMS2_LIB=%BUILD_ROOT%\Little-CMS\lib\%PLATFORM%\Debug\Debug\lcms2d.lib

set JPEG_GEN_DIR=%JPEG_BUILD_DIR%\build_tmp\%PLATFORM%\Debug


) else (


set ZLIB_LIB=%BUILD_ROOT%\zlib\lib\%PLATFORM%\Release\Release\z.lib
set JPEG_LIB=%BUILD_ROOT%\libjpeg-turbo\lib\%PLATFORM%\Release\Release\jpeg-static.lib
set LCMS2_LIB=%BUILD_ROOT%\Little-CMS\lib\%PLATFORM%\Release\Release\lcms2.lib

set JPEG_GEN_DIR=%JPEG_BUILD_DIR%\build_tmp\%PLATFORM%\Release


)

echo.
echo =========================
echo Dependency Check
echo =========================

echo ZLIB_LIB  = %ZLIB_LIB%
echo JPEG_LIB  = %JPEG_LIB%
echo LCMS2_LIB = %LCMS2_LIB%

echo JPEG_SRC_DIR = %JPEG_SRC_DIR%
echo JPEG_GEN_DIR = %JPEG_GEN_DIR%
echo LCMS2_INCLUDE_DIR = %LCMS2_INCLUDE_DIR%

echo.

REM =========================
REM CMAKE CONFIGURE
REM =========================

cmake "%SOURCE_DIR%" ^
-G "Visual Studio 17 2022" ^
-A %ARCH% ^
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
-DCMAKE_INSTALL_PREFIX="%OUT_DIR%" ^
-DBUILD_SHARED_LIBS=OFF ^
-DBUILD_STATIC_LIBS=ON ^
-DWITH_JPEG=ON ^
-DWITH_LCMS2=ON ^
-DJPEG_LIBRARY="%JPEG_LIB%" ^
-DJPEG_INCLUDE_DIR="%JPEG_SRC_DIR%" ^
-DLCMS2_LIBRARY="%LCMS2_LIB%" ^
-DLCMS2_INCLUDE_DIR="%LCMS2_INCLUDE_DIR%" ^
-DZLIB_LIBRARY="%ZLIB_LIB%" ^
-DZLIB_INCLUDE_DIR="%ZLIB_DIR%" ^
-DCMAKE_C_FLAGS="/I"%JPEG_SRC_DIR%" /I"%JPEG_GEN_DIR%""

if errorlevel 1 (
echo.
echo [ERROR] Configure failed!
pause
exit /b 1
)

REM =========================
REM BUILD
REM =========================

cmake --build . --config %CONFIG%

if errorlevel 1 (
echo.
echo [ERROR] Build failed!
pause
exit /b 1
)

REM =========================
REM COPY OUTPUTS
REM =========================

echo.
echo [INFO] Copying build outputs...

if not exist "%OUT_DIR%\bin" mkdir "%OUT_DIR%\bin"
if not exist "%OUT_DIR%\include" mkdir "%OUT_DIR%\include"

for /r "%BUILD_DIR%" %%F in (*.lib) do (
copy /Y "%%F" "%OUT_DIR%" >nul
)

for /r "%BUILD_DIR%" %%F in (*.dll) do (
copy /Y "%%F" "%OUT_DIR%\bin" >nul
)

for /r "%BUILD_DIR%" %%F in (*.exe) do (
copy /Y "%%F" "%OUT_DIR%\bin" >nul
)

copy /Y "%SOURCE_DIR%*.h" "%OUT_DIR%\include" >nul

echo.
echo [OK] Build completed: %PLATFORM% %CONFIG%
echo Output: %OUT_DIR%

exit /b 0
