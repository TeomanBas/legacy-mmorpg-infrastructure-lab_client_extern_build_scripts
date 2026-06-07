@echo off
setlocal

echo =====================================
echo        CRYPTOPP BUILD SCRIPT
echo =====================================

set SCRIPT_DIR=%~dp0

for %%I in ("%SCRIPT_DIR%..") do set ROOT_DIR=%%~fI

set SOURCE_DIR=%ROOT_DIR%\cryptopp
set SOLUTION=%SOURCE_DIR%\cryptest.sln

if not exist "%SOLUTION%" (
    echo [ERROR] cryptest.sln not found
    pause
    exit /b 1
)

call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"

for %%A in (Win32 x64) do (
    for %%B in (Debug Release) do (

        echo.
        echo =====================================
        echo Building %%A - %%B
        echo =====================================

        msbuild "%SOLUTION%" ^
            /t:cryptlib ^
            /p:Configuration=%%B ^
            /p:Platform=%%A

        if errorlevel 1 (
            echo [ERROR] Build failed (%%A %%B)
            pause
            exit /b 1
        )

        echo [OK] %%A %%B completed
    )
)

echo.
echo =====================================
echo BUILD SUCCESS
echo =====================================

pause