@echo off
setlocal enabledelayedexpansion

echo =====================================
echo         TINYXML BUILD SCRIPT
echo =====================================

REM =========================
REM ROOT PATH
REM =========================

set SCRIPT_DIR=%~dp0

for %%I in ("%SCRIPT_DIR%..") do (
set ROOT_DIR=%%~fI
)

set SOURCE_DIR=%ROOT_DIR%\tinyxml
set BUILD_ROOT=%ROOT_DIR%\build\tinyxml

REM =========================
REM RUNTIME TYPE
REM =========================
REM MD  = Dynamic CRT
REM MT  = Static CRT

set RUNTIME=MT

echo.
echo Root     : %ROOT_DIR%
echo Source   : %SOURCE_DIR%
echo Build    : %BUILD_ROOT%
echo Runtime  : %RUNTIME%

REM =========================
REM SOLUTION
REM =========================

set SOLUTION=%SOURCE_DIR%\tinyxml.sln

if not exist "%SOLUTION%" (
echo [ERROR] TinyXML solution not found:
echo %SOLUTION%
pause
exit /b 1
)

REM =========================
REM BUILD
REM =========================

call :build Debug
call :build Release

echo.
echo =====================================
echo         TINYXML BUILD DONE
echo =====================================

pause
exit /b 0

:build

set CONFIG=%1

echo.
echo =====================================
echo Building TinyXML Win32 %CONFIG%
echo =====================================

set OUT_DIR=%BUILD_ROOT%\lib\x86\%CONFIG%

if not exist "%OUT_DIR%" (
mkdir "%OUT_DIR%"
)

REM =========================
REM RUNTIME SWITCH
REM =========================

if /I "%RUNTIME%"=="MT" (

```
if /I "%CONFIG%"=="Debug" (
    set CRT=MultiThreadedDebug
) else (
    set CRT=MultiThreaded
)
```

) else (

```
if /I "%CONFIG%"=="Debug" (
    set CRT=MultiThreadedDebugDLL
) else (
    set CRT=MultiThreadedDLL
)
```

)

echo [INFO] Runtime: !CRT!

msbuild "%SOLUTION%" ^
/m ^
/p:Configuration=%CONFIG% ^
/p:Platform=Win32 ^
/p:RuntimeLibrary=!CRT!

if errorlevel 1 (
echo [ERROR] Build failed
pause
exit /b 1
)

REM =========================
REM COPY OUTPUTS
REM =========================

echo [INFO] Copying outputs...

for /r "%SOURCE_DIR%" %%F in (*.lib) do (
copy /Y "%%F" "%OUT_DIR%" >nul 2>&1
)

echo [OK] Win32 %CONFIG%

exit /b 0
