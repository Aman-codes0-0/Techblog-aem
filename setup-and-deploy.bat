@echo off
setlocal enabledelayedexpansion
title TechBlog AEM - Setup, Build ^& Deploy (Aman Kumar)

:: ============================================================
::  TechBlog AEM — Control & Deployment Suite
::  Author: Aman Kumar
::  Repository: https://github.com/Aman-codes0-0/Techblog-aem
:: ============================================================

cls
echo.
echo ============================================================
echo   TechBlog AEM - Control ^& Build Suite
echo   Author: Aman Kumar
echo ============================================================
echo.

:: -------------------------------------------------------
:: STEP 1 - Check Java
:: -------------------------------------------------------
echo [1/3] Checking Java Runtime...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   [ERROR] Java is not installed or not found on PATH.
    echo   Please install JDK 11 (or higher) and set JAVA_HOME.
    echo   Download: https://adoptium.net/
    echo.
    pause
    exit /b 1
)
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    echo   - Java Found: %%v
)

:: -------------------------------------------------------
:: STEP 2 - Check Maven
:: -------------------------------------------------------
echo [2/3] Checking Apache Maven...
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   [ERROR] Maven is not installed or not on PATH.
    echo   Please install Maven 3.6+ and add bin to PATH.
    echo   Download: https://maven.apache.org/download.cgi
    echo.
    pause
    exit /b 1
)
for /f "tokens=1,2,3" %%a in ('mvn -version 2^>^&1 ^| findstr /i "apache maven"') do (
    echo   - Maven Found: %%a %%b %%c
)

:: -------------------------------------------------------
:: STEP 3 - Check AEM Instance
:: -------------------------------------------------------
echo [3/3] Probing AEM Instance on localhost:4502...
set AEM_RUNNING=0
where curl.exe >nul 2>&1
if %errorlevel% equ 0 (
    curl.exe -s -o nul -w "%%{http_code}" http://localhost:4502/libs/granite/core/content/login.html > "%TEMP%\aem_probe.txt" 2>nul
    set /p PROBE_CODE=<"%TEMP%\aem_probe.txt"
    del "%TEMP%\aem_probe.txt" >nul 2>&1
) else (
    powershell -NoProfile -Command "try { $r=(Invoke-WebRequest -Uri 'http://localhost:4502/libs/granite/core/content/login.html' -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop).StatusCode; Write-Output $r } catch { Write-Output '000' }" > "%TEMP%\aem_probe.txt" 2>nul
    set /p PROBE_CODE=<"%TEMP%\aem_probe.txt"
    del "%TEMP%\aem_probe.txt" >nul 2>&1
)

if "%PROBE_CODE%"=="200" (
    echo   - AEM Status: ONLINE (HTTP 200 OK)
    set AEM_RUNNING=1
) else (
    echo   - AEM Status: OFFLINE (localhost:4502 not detected)
)

echo.
echo ============================================================
echo   SELECT AN OPTION:
echo ============================================================
echo.
echo   [1] Build Maven Packages (compile core bundle ^& ui.apps package)
echo   [2] Deploy to AEM (mvn clean install -PautoInstallSinglePackage)
echo   [3] Open Web Showroom in Browser (index.html)
echo   [4] Exit
echo.
set /p CHOICE="Enter choice [1-4] (default: 1): "
if "%CHOICE%"=="" set CHOICE=1

if "%CHOICE%"=="1" goto BUILD_ONLY
if "%CHOICE%"=="2" goto DEPLOY_AEM
if "%CHOICE%"=="3" goto OPEN_BROWSER
if "%CHOICE%"=="4" goto QUIT
goto BUILD_ONLY

:: -------------------------------------------------------
:: MODE 1: BUILD ONLY
:: -------------------------------------------------------
:BUILD_ONLY
echo.
echo ============================================================
echo   Building TechBlog Reactor (Core + UI.Apps)...
echo ============================================================
echo.
pushd "%~dp0"
call mvn clean install -DskipTests
set BUILD_STATUS=%errorlevel%
popd

echo.
echo ============================================================
if %BUILD_STATUS% equ 0 (
    echo   BUILD SUCCESSFUL!
    echo.
    echo   Generated Artifacts:
    echo   - OSGi Bundle:  core\target\techblog.core-1.0.0-SNAPSHOT.jar
    echo   - Content Pkg:  ui.apps\target\techblog.ui.apps-1.0.0-SNAPSHOT.zip
) else (
    echo   BUILD FAILED (Exit Code: %BUILD_STATUS%)
)
echo ============================================================
echo.
pause
goto MENU_AFTER

:: -------------------------------------------------------
:: MODE 2: DEPLOY TO AEM
:: -------------------------------------------------------
:DEPLOY_AEM
if "%AEM_RUNNING%"=="0" (
    echo.
    echo   [WARNING] AEM does not seem to be running on localhost:4502.
    echo   Start AEM with:
    echo     java -jar aem-sdk-quickstart-*.jar -r author,localDev -gui
    echo.
    set /p PROCEED="Attempt deployment anyway? (y/n): "
    if /i "!PROCEED!" neq "y" goto MENU_AFTER
)

echo.
echo ============================================================
echo   Deploying to AEM (localhost:4502)...
echo ============================================================
echo.
pushd "%~dp0"
call mvn clean install -PautoInstallSinglePackage
set DEPLOY_STATUS=%errorlevel%
popd

echo.
echo ============================================================
if %DEPLOY_STATUS% equ 0 (
    echo   DEPLOYMENT SUCCESSFUL!
    echo.
    echo   Next Steps:
    echo   1. Verify OSGi Bundle: http://localhost:4502/system/console/bundles
    echo   2. Create Page in Sites Editor with Tech Blog templates
    echo   3. Enable "Tech Blog" component group in Layout Container policy
) else (
    echo   DEPLOYMENT FAILED (Exit Code: %DEPLOY_STATUS%)
)
echo ============================================================
echo.
pause
goto MENU_AFTER

:: -------------------------------------------------------
:: MODE 3: OPEN WEB SHOWROOM
:: -------------------------------------------------------
:OPEN_BROWSER
echo.
echo   Launching interactive web showroom in default browser...
start "" "%~dp0index.html"
goto MENU_AFTER

:MENU_AFTER
echo.
set /p REPEAT="Return to menu? (y/n): "
if /i "%REPEAT%"=="y" goto :START
goto QUIT

:QUIT
echo.
echo Exiting TechBlog AEM Suite. Goodbye!
endlocal
exit /b 0
