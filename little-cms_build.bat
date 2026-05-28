@echo off
setlocal enabledelayedexpansion

REM =====================================
REM  CONFIG
REM =====================================

set ROOT=%~dp0..
set SRC=%ROOT%\Little-CMS

set BUILD_ROOT=%ROOT%\build\Little-CMS
set BUILD_TMP=%BUILD_ROOT%\build_tmp
set LIB_OUT=%BUILD_ROOT%\lib

echo =====================================
echo  LittleCMS Build Script
echo =====================================
echo Source   : %SRC%
echo Build TMP: %BUILD_TMP%
echo Lib OUT  : %LIB_OUT%
echo =====================================

if not exist "%SRC%\CMakeLists.txt" (
    echo [ERROR] LittleCMS source not found!
    pause
    exit /b 1
)

REM =====================================
REM ARCH + CONFIG LOOP
REM =====================================

for %%A in (x86 x64) do (
    for %%C in (Debug Release) do (

        echo.
        echo =====================================
        echo Building %%A - %%C
        echo =====================================

        set "BUILD_DIR=%BUILD_TMP%\%%A\%%C"

        if exist "!BUILD_DIR!" (
            echo Cleaning old build: !BUILD_DIR!
            rmdir /s /q "!BUILD_DIR!"
        )

        mkdir "!BUILD_DIR!"

        REM =====================================
        REM CMAKE CONFIGURE
        REM =====================================

        if "%%A"=="x86" (
            set GENERATOR=Visual Studio 17 2022
            set PLATFORM=Win32
        ) else (
            set GENERATOR=Visual Studio 17 2022
            set PLATFORM=x64
        )

        cmake -S "%SRC%" ^
              -B "!BUILD_DIR!" ^
              -G "!GENERATOR!" ^
              -A "!PLATFORM!" ^
              -DCMAKE_BUILD_TYPE=%%C

        if errorlevel 1 (
            echo [ERROR] CMake configure failed: %%A %%C
            pause
            exit /b 1
        )

        REM =====================================
        REM BUILD
        REM =====================================

        cmake --build "!BUILD_DIR!" --config %%C

        if errorlevel 1 (
            echo [ERROR] Build failed: %%A %%C
            pause
            exit /b 1
        )

        REM =====================================
        REM COPY LIBS (NEW STRUCTURE)
        REM =====================================

        set "OUT_LIB=%LIB_OUT%\%%A\%%C"
        mkdir "!OUT_LIB!" 2>nul

        echo Copying libs to: !OUT_LIB!

        for /r "!BUILD_DIR!" %%F in (*.lib) do (
            copy "%%F" "!OUT_LIB!\" >nul
        )

        echo [OK] %%A %%C completed
    )
)

REM =====================================
REM POST PROCESS (FIXED NORMALIZATION)
REM =====================================

echo.
echo =====================================
echo POST PROCESS: FIXING OUTPUT STRUCTURE
echo =====================================

for %%A in (x86 x64) do (
    for %%C in (Debug Release) do (

        set "BASE_SRC=%BUILD_TMP%\%%A\%%C"
        set "DEST=%LIB_OUT%\%%A\%%C"

        echo.
        echo [INFO] Processing %%A %%C
        echo Source: !BASE_SRC!
        echo Dest  : !DEST!

        mkdir "!DEST!" 2>nul

        REM =====================================
        REM Handle double Debug/Release folders
        REM =====================================

        for /d %%D in ("!BASE_SRC!\*") do (

            echo Checking subdir: %%D

            REM Eğer alt klasör Debug/Release ise içine gir
            if /i "%%~nxD"=="Debug" (
                call :COPY_LIBS "%%D" "!DEST!"
            ) else if /i "%%~nxD"=="Release" (
                call :COPY_LIBS "%%D" "!DEST!"
            ) else (
                REM normal build output ise direkt al
                call :COPY_LIBS "%%D" "!DEST!"
            )
        )

    )
)

goto :EOF

REM =====================================
REM COPY FUNCTION
REM =====================================
:COPY_LIBS
set "SRC_DIR=%~1"
set "OUT_DIR=%~2"

echo      Copying from: %SRC_DIR%

for /r "%SRC_DIR%" %%F in (*.lib) do (
    copy "%%F" "%OUT_DIR%\" >nul
)

for /r "%SRC_DIR%" %%F in (*.dll) do (
    copy "%%F" "%OUT_DIR%\" >nul
)

exit /b

echo.
echo =====================================
echo ALL BUILDS COMPLETED
echo =====================================
pause
endlocal