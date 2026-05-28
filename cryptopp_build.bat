@echo off
setlocal enabledelayedexpansion

echo =====================================
echo        CRYPTOPP BUILD SCRIPT
echo =====================================

REM Script location
set SCRIPT_DIR=%~dp0

REM Root project directory (repo_source)
for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\cryptopp
set BUILD_ROOT=%ROOT_DIR%\build\cryptopp

echo [INFO] Root: %ROOT_DIR%
echo [INFO] Source: %SOURCE_DIR%
echo [INFO] Build: %BUILD_ROOT%

if not exist "%SOURCE_DIR%" (
    echo [ERROR] Crypto++ source not found
    pause
    exit /b 1
)

REM Architectures
for %%A in (x86 x64) do (
    for %%B in (Debug Release) do (

        set BUILD_DIR=%BUILD_ROOT%\%%A\%%B

        echo.
        echo =====================================
        echo Building %%A - %%B
        echo =====================================

        if exist "!BUILD_DIR!" rmdir /s /q "!BUILD_DIR!"
        mkdir "!BUILD_DIR!"

        if "%%A"=="x86" (
            set ARCH=Win32
        ) else (
            set ARCH=x64
        )

        cmake -S "%SOURCE_DIR%" -B "!BUILD_DIR!" ^
            -G "Visual Studio 17 2022" ^
            -A !ARCH! ^
            -DCMAKE_BUILD_TYPE=%%B

        if errorlevel 1 (
            echo [ERROR] CMake configure failed (%%A - %%B)
            pause
            exit /b 1
        )

        cmake --build "!BUILD_DIR!" --config %%B

        if errorlevel 1 (
            echo [ERROR] Build failed (%%A - %%B)
            pause
            exit /b 1
        )

        echo [OK] %%A - %%B completed
    )
)

echo.
echo =====================================
echo ALL BUILDS COMPLETED
echo =====================================
pause