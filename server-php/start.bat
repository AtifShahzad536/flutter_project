@echo off
echo Starting Export Trix PHP Backend...
echo.

REM Try to find PHP executable
if exist "C:\xampp\php\php.exe" (
    set PHP_PATH=C:\xampp\php\php.exe
    echo Found PHP at: C:\xampp\php\php.exe
) else if exist "C:\wamp64\bin\php\php.exe" (
    set PHP_PATH=C:\wamp64\bin\php\php.exe
    echo Found PHP at: C:\wamp64\bin\php\php.exe
) else (
    echo PHP not found in common locations.
    echo Please install PHP or XAMPP/WAMP.
    echo.
    pause
    exit /b 1
)

echo.
echo Starting PHP server on http://localhost:8000
echo Press Ctrl+C to stop the server
echo.

cd /d "%~dp0"
%PHP_PATH% -S localhost:8000 index.php

pause
