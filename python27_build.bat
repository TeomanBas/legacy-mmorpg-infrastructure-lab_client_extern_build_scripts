@echo off
setlocal

REM Script'in bulunduğu dizine git
cd /d "%~dp0"

REM Kaynak ve hedef dizinler
set "SRC=..\python2.7.18_lib-dll"
set "DST=..\build\python27"

REM Hedef dizin yoksa oluştur
if not exist "%DST%" (
    mkdir "%DST%"
)

echo.
echo Kaynak: %SRC%
echo Hedef : %DST%
echo.

REM .git klasorlerini haric tutarak kopyala
robocopy "%SRC%" "%DST%" /E /XD ".git" /R:1 /W:1

REM Robocopy cikis kodu kontrolu
if %ERRORLEVEL% LSS 8 (
    echo.
    echo Kopyalama basarili.
    exit /b 0
) else (
    echo.
    echo HATA! Robocopy hata kodu: %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)