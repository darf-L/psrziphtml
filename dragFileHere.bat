@echo off
setlocal EnableDelayedExpansion

REM PSR to HTML Converter - Drag & Drop Wrapper
REM Ziehe eine .zip oder .mht Datei auf diese .bat Datei

if "%~1"=="" (
    echo.
    echo ========================================
    echo  PSR to HTML Converter
    echo ========================================
    echo.
    echo Verwendung: Ziehe eine .zip oder .mht Datei
    echo auf diese Batch-Datei!
    echo.
    echo Unterstuetzte Formate:
    echo   - .zip ^(PSR Download^)
    echo   - .mht ^(PSR Datei^)
    echo.
    pause
    exit /b 1
)

REM Prüfe ob Datei existiert
if not exist "%~1" (
    echo FEHLER: Datei nicht gefunden: %~1
    pause
    exit /b 1
)

REM Prüfe Dateiendung
set "extension=%~x1"
if /i not "%extension%"==".zip" if /i not "%extension%"==".mht" (
    echo FEHLER: Ungueltige Datei!
    echo Nur .zip oder .mht Dateien werden unterstuetzt.
    echo.
    echo Ihre Datei: %~nx1
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Starte Konvertierung...
echo ========================================
echo.
echo Datei: %~nx1
echo.

REM PowerShell Script im gleichen Verzeichnis finden
set "scriptPath=%~dp0Convert-to-HTML.ps1"

if not exist "%scriptPath%" (
    echo FEHLER: Convert-to-HTML.ps1 nicht gefunden!
    echo Erwartet in: %scriptPath%
    echo.
    pause
    exit /b 1
)

REM PowerShell Script ausführen
PowerShell.exe -ExecutionPolicy Bypass -File "%scriptPath%" -InputFile "%~1"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  Erfolgreich abgeschlossen!
    echo ========================================
    echo.
) else (
    echo.
    echo ========================================
    echo  FEHLER bei der Konvertierung!
    echo ========================================
    echo.
)

pause
