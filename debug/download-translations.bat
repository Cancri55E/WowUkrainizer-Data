@echo off
setlocal

cd /d "%~dp0"

set "PROJECT_ROOT=%~dp0.."
set "ROOT_UK_BACKED_UP=0"

if exist "uk-approved" (
    echo Removing old debug\uk-approved folder...
    rmdir /s /q "uk-approved"
)

if exist "uk" (
    echo Removing old debug\uk folder...
    rmdir /s /q "uk"
)

if exist "%PROJECT_ROOT%\uk" (
    if exist "%PROJECT_ROOT%\uk-legacy" (
        echo ERROR: %PROJECT_ROOT%\uk-legacy already exists. Resolve manually before running.
        exit /b 1
    )
    echo Backing up existing root uk -^> uk-legacy...
    ren "%PROJECT_ROOT%\uk" "uk-legacy"
    set "ROOT_UK_BACKED_UP=1"
)

echo ============================================
echo [1/2] Downloading APPROVED translations...
echo ============================================

call crowdin download translations --export-only-approved
if errorlevel 1 (
    echo.
    echo ERROR: Failed to download approved translations.
    goto :restore
)

if exist "%PROJECT_ROOT%\uk" (
    echo Moving uk -^> debug\uk-approved...
    move "%PROJECT_ROOT%\uk" "uk-approved" >nul
) else (
    echo WARNING: uk folder not found in project root after approved download.
)

echo.
echo ============================================
echo [2/2] Downloading ALL translations...
echo ============================================

call crowdin download translations
if errorlevel 1 (
    echo.
    echo ERROR: Failed to download all translations.
    goto :restore
)

if exist "%PROJECT_ROOT%\uk" (
    echo Moving uk -^> debug\uk...
    move "%PROJECT_ROOT%\uk" "uk" >nul
) else (
    echo WARNING: uk folder not found in project root after all-translations download.
)

echo.
echo ============================================
echo Done!
echo   Approved: debug\uk-approved\
echo   All:      debug\uk\
echo ============================================

:restore
if "%ROOT_UK_BACKED_UP%"=="1" (
    if exist "%PROJECT_ROOT%\uk-legacy" (
        echo Restoring root uk-legacy -^> uk...
        ren "%PROJECT_ROOT%\uk-legacy" "uk"
    )
)

endlocal
