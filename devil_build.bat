@echo off
setlocal enabledelayedexpansion

echo =====================================
echo         DEVIL BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0

for %%I in ("%SCRIPT_DIR%..") do (
set ROOT_DIR=%%~fI
)

set SOURCE_DIR=%ROOT_DIR%\DevIL\DevIL
set BUILD_ROOT=%ROOT_DIR%\build\DevIL

echo Root   : %ROOT_DIR%
echo Source : %SOURCE_DIR%
echo Build  : %BUILD_ROOT%

if not exist "%SOURCE_DIR%\CMakeLists.txt" (
echo [ERROR] DevIL source not found
pause
exit /b 1
)

call :build x64 Debug
call :build x64 Release
call :build x86 Debug
call :build x86 Release

echo.
echo =====================================
echo        DEVIL BUILD DONE
echo =====================================

pause
exit /b 0

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
echo Building DevIL %PLATFORM% - %CONFIG%
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
REM DEPENDENCIES
REM =========================

if "%CONFIG%"=="Debug" (

set ZLIB_LIB=%ROOT_DIR%\build\zlib\lib\%PLATFORM%\%CONFIG%\zd.lib
set JPEG_LIB=%ROOT_DIR%\build\libjpeg-turbo\lib\%PLATFORM%\%CONFIG%\jpeg-static.lib
set JPEG_GEN_INC=%ROOT_DIR%\build\libjpeg-turbo\build_tmp\%PLATFORM%\%CONFIG%
set TIFF_LIB=%ROOT_DIR%\build\libtiff\lib\%PLATFORM%\%CONFIG%\tiffd.lib
set GLUT_LIB=%ROOT_DIR%\build\freeglut\lib\%PLATFORM%\%CONFIG%\freeglut_staticd.lib
set PNG_LIB=%ROOT_DIR%\build\libpng\lib\%PLATFORM%\%CONFIG%\libpng18_staticd.lib
set LCMS2_LIB=%ROOT_DIR%\build\Little-CMS\lib\%PLATFORM%\%CONFIG%\lcms2d.lib
set JASPER_LIB=%ROOT_DIR%\build\jasper\lib\%PLATFORM%\%CONFIG%\jasper.lib
set MNG_LIB=%ROOT_DIR%\build\libmng\lib\%PLATFORM%\%CONFIG%\libmng.lib
set SQUISH_LIB=%ROOT_DIR%\build\libsquish\lib\%PLATFORM%\%CONFIG%\Squishd.lib
) else (
set ZLIB_LIB=%ROOT_DIR%\build\zlib\lib\%PLATFORM%\%CONFIG%\z.lib
set JPEG_LIB=%ROOT_DIR%\build\libjpeg-turbo\lib\%PLATFORM%\jpeg-static.lib
set JPEG_GEN_INC=%ROOT_DIR%\build\libjpeg-turbo\build_tmp\%PLATFORM%\%CONFIG%
set TIFF_LIB=%ROOT_DIR%\build\libtiff\lib\%PLATFORM%\%CONFIG%\tiff.lib
set GLUT_LIB=%ROOT_DIR%\build\freeglut\lib\%PLATFORM%\%CONFIG%\freeglut_static.lib
set PNG_LIB=%ROOT_DIR%\build\libpng\lib\%PLATFORM%\%CONFIG%\libpng18_static.lib
set LCMS2_LIB=%ROOT_DIR%\build\Little-CMS\lib\%PLATFORM%\%CONFIG%\lcms2.lib
set JASPER_LIB=%ROOT_DIR%\build\jasper\lib\%PLATFORM%\%CONFIG%\jasper.lib
set MNG_LIB=%ROOT_DIR%\build\libmng\lib\%PLATFORM%\%CONFIG%\libmng.lib
set SQUISH_LIB=%ROOT_DIR%\build\libsquish\lib\%PLATFORM%\%CONFIG%\Squish.lib
)





REM =========================
REM INCLUDE PATHS
REM =========================

set ZLIB_INC=%ROOT_DIR%\zlib
set JPEG_INC=%ROOT_DIR%\libjpeg-turbo\src
set TIFF_INC=%ROOT_DIR%\libtiff\libtiff
set TIFF_GEN_INC=%ROOT_DIR%\build\libtiff\build_tmp\%PLATFORM%\%CONFIG%\libtiff
set GLUT_INC=%ROOT_DIR%\freeglut\include
set PNG_INC=%ROOT_DIR%\libpng
set LCMS2_INC=%ROOT_DIR%\Little-CMS\include
set JASPER_INC=%ROOT_DIR%\jasper\src\libjasper\include
set MNG_INC=%ROOT_DIR%\libmng-2.0.3
set JAS_GEN_INC=%ROOT_DIR%\build\jasper\build_tmp\%PLATFORM%\%CONFIG%\src\libjasper\include
set SQUISH_INC=%ROOT_DIR%\libsquish\lib\include\squish
set SQUISH_GEN_INC=%ROOT_DIR%\build\libsquish\build_tmp\%PLATFORM%\%CONFIG%\lib\include
REM =========================
REM OPENEXR / IMATH
REM =========================

set OPENEXR_DIR=%ROOT_DIR%\build\OpenEXR
set IMATH_DIR=%ROOT_DIR%\build\Imath

echo GLUT LIB:
echo %GLUT_LIB%

REM =========================
REM ILU ERROR FİX
REM =========================
set ILU_SKIP_TRANSLATIONS=1


REM =========================
REM CMAKE CONFIGURE
REM =========================

cmake "%SOURCE_DIR%" ^
-G "Visual Studio 17 2022" ^
-A %ARCH% ^
-DCMAKE_BUILD_TYPE=%CONFIG% ^
-DBUILD_SHARED_LIBS=OFF ^
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
-DZLIB_LIBRARY="%ZLIB_LIB%" ^
-DZLIB_INCLUDE_DIR="%ZLIB_INC%" ^
-DPNG_LIBRARY="%PNG_LIB%" ^
-DPNG_PNG_INCLUDE_DIR="%PNG_INC%" ^
-DJPEG_LIBRARY="%JPEG_LIB%" ^
-DJPEG_INCLUDE_DIR="%JPEG_INC%" ^
-DTIFF_LIBRARY="%TIFF_LIB%" ^
-DTIFF_INCLUDE_DIR="%TIFF_INC%" ^
-DGLUT_glut_LIBRARY="%GLUT_LIB%" ^
-DGLUT_INCLUDE_DIR="%GLUT_INC%" ^
-DOPENEXR_ROOT="%OPENEXR_DIR%" ^
-DOpenEXR_DIR="%OPENEXR_DIR%" ^
-DImath_DIR="%IMATH_DIR%" ^
-DCMAKE_C_FLAGS="/I%JPEG_GEN_INC% /I%TIFF_GEN_INC% /I%JAS_GEN_INC% /I%SQUISH_GEN_INC% /I%SQUISH_INC%" ^
-DCMAKE_CXX_FLAGS="/I%JPEG_GEN_INC% /I%TIFF_GEN_INC% /I%JAS_GEN_INC% /I%SQUISH_GEN_INC% /I%SQUISH_INC%" ^
-DILU_BUILD_TRANSLATIONS=OFF ^
-DIL_NO_ERROR_TRANSLATION=ON ^
-DLCMS2_LIBRARY="%LCMS2_LIB%" ^
-DLCMS2_INCLUDE_DIR="%LCMS2_INC%" ^
-DJASPER_LIBRARIES="%JASPER_LIB%" ^
-DJASPER_INCLUDE_DIR="%JASPER_INC%" ^
-DMNG_LIBRARY="%MNG_LIB%" ^
-DMNG_INCLUDE_DIR="%MNG_INC%" ^
-DLIBSQUISH_LIBRARY="%SQUISH_LIB%" ^
-DLIBSQUISH_LIBRARIES="%SQUISH_LIB%" ^
-DLIBSQUISH_INCLUDE_DIR="%SQUISH_INC%" ^
-DCMAKE_MSVC_RUNTIME_LIBRARY="%RUNTIME%"



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

echo [OK] %PLATFORM% %CONFIG%

exit /b 0
