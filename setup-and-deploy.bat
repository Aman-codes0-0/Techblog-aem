@echo off
setlocal enabledelayedexpansion
title TechBlog AEM - Setup and Deploy

:: ============================================================
::  TechBlog AEM - One-Click Setup and Deploy Script
::  Run this from the techblog-aem\ folder.
::  It will:
::    1. Check Java and Maven are installed
::    2. Check AEM is running on localhost:4502
::    3. Generate the AEM archetype project (first run only)
::    4. Merge your core/ and ui.apps/ source files into it
::    5. Build and deploy to AEM
:: ============================================================

echo.
echo ============================================================
echo   TechBlog AEM - Setup and Deploy
echo ============================================================
echo.

:: -------------------------------------------------------
:: STEP 1 - Check Java
:: -------------------------------------------------------
echo [1/5] Checking Java...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   ERROR: Java is not installed or not on PATH.
    echo   Install JDK 11 or higher and add it to your PATH.
    echo   Download: https://adoptium.net/
    echo.
    pause
    exit /b 1
)
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    echo   Java found: %%v
)

echo.

:: -------------------------------------------------------
:: STEP 2 - Check Maven
:: -------------------------------------------------------
echo [2/5] Checking Maven...
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   ERROR: Maven is not installed or not on PATH.
    echo   Install Maven 3.6+ and add it to your PATH.
    echo   Download: https://maven.apache.org/download.cgi
    echo.
    pause
    exit /b 1
)
for /f "tokens=1,2,3" %%a in ('mvn -version 2^>^&1 ^| findstr /i "apache maven"') do (
    echo   %%a %%b %%c found.
)

echo.

:: -------------------------------------------------------
:: STEP 3 - Check AEM is running
:: -------------------------------------------------------
echo [3/5] Checking AEM on localhost:4502...

:: Use curl.exe explicitly to avoid PowerShell's Invoke-WebRequest alias
where curl.exe >nul 2>&1
if %errorlevel% equ 0 (
    curl.exe -s -o nul -w "%%{http_code}" http://localhost:4502/libs/granite/core/content/login.html > "%TEMP%\aem_check.txt" 2>nul
    set /p HTTP_CODE=<"%TEMP%\aem_check.txt"
    del "%TEMP%\aem_check.txt" >nul 2>&1
) else (
    :: curl.exe not found - try PowerShell fallback
    powershell -NoProfile -Command "try { $r=(Invoke-WebRequest -Uri 'http://localhost:4502/libs/granite/core/content/login.html' -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop).StatusCode; Write-Output $r } catch { Write-Output '000' }" > "%TEMP%\aem_check.txt" 2>nul
    set /p HTTP_CODE=<"%TEMP%\aem_check.txt"
    del "%TEMP%\aem_check.txt" >nul 2>&1
)

if "%HTTP_CODE%"=="200" (
    echo   AEM is running. HTTP 200 OK.
) else (
    echo.
    echo   WARNING: AEM localhost:4502 pe nahi chal raha.
    echo   Response code: [%HTTP_CODE%]
    echo.
    echo   AEM start karne ke liye yeh command run karein:
    echo     java -jar aem-sdk-quickstart-*.jar -r author,localDev -gui -nointeractive
    echo.
    echo   Options:
    echo     [Y] - AEM ke bina sirf build karein (deploy nahi hoga)
    echo     [N] - Script band karein, pehle AEM start karein
    echo.
    set /p CONTINUE="Continue without AEM? (y/n): "
    if /i "!CONTINUE!" neq "y" (
        echo.
        echo   Script band ho rahi hai. Pehle AEM start karein, phir dobara run karein.
        pause
        exit /b 1
    )
    echo   Theek hai - sirf build karungi, deploy skip hoga.
)

echo.

:: -------------------------------------------------------
:: STEP 4 - Generate archetype project (first run only)
:: -------------------------------------------------------
set GENERATED_DIR=%~dp0techblog

echo [4/5] Checking if archetype project already exists...

if exist "%GENERATED_DIR%\pom.xml" (
    echo   Found existing generated project at: techblog\
    echo   Skipping archetype generation.
    echo   Re-merging source files to pick up any changes...
) else (
    echo   No generated project found. Running Maven archetype...
    echo.
    pushd "%~dp0"
    mvn -B archetype:generate ^
        -DarchetypeGroupId=com.adobe.aem ^
        -DarchetypeArtifactId=aem-project-archetype ^
        -DarchetypeVersion=LATEST ^
        -DappTitle="Tech Blog" ^
        -DappId="techblog" ^
        -DgroupId="com.techblog" ^
        -DaemVersion=cloud ^
        -DincludeExamples=n
    if %errorlevel% neq 0 (
        echo.
        echo   ERROR: Archetype generation failed. Check Maven output above.
        popd
        pause
        exit /b 1
    )
    popd
    echo.
    echo   Archetype project generated successfully.
)

echo.

:: ---- Merge: copy Sling Model Java source ----
echo   Merging core sources...
set JAVA_SRC=%~dp0core\src\main\java\com\techblog\core\models
set JAVA_DST=%GENERATED_DIR%\core\src\main\java\com\techblog\core\models
if not exist "%JAVA_DST%" mkdir "%JAVA_DST%"
xcopy /Y /Q "%JAVA_SRC%\*.java" "%JAVA_DST%\" >nul
if %errorlevel% neq 0 (
    echo   ERROR: Failed to copy Java sources.
    pause
    exit /b 1
)
echo   ArticleHeader.java merged.

:: ---- Merge: copy ui.apps content (components + clientlibs) ----
echo   Merging ui.apps content...
set UIAPPS_SRC=%~dp0ui.apps\src\main\content\jcr_root\apps\techblog
set UIAPPS_DST=%GENERATED_DIR%\ui.apps\src\main\content\jcr_root\apps\techblog
if not exist "%UIAPPS_DST%" mkdir "%UIAPPS_DST%"
xcopy /Y /E /Q "%UIAPPS_SRC%\*" "%UIAPPS_DST%\" >nul
if %errorlevel% neq 0 (
    echo   ERROR: Failed to copy ui.apps content.
    pause
    exit /b 1
)
echo   Components and clientlibs merged.

echo.

:: -------------------------------------------------------
:: STEP 5 - Build and Deploy
:: -------------------------------------------------------
echo [5/5] Building and deploying to AEM (this may take a few minutes)...
echo.
pushd "%GENERATED_DIR%"
if "%HTTP_CODE%"=="200" (
    echo   AEM chal raha hai - build + deploy kar raha hai...
    mvn clean install -PautoInstallSinglePackage
) else (
    echo   AEM nahi mila - sirf build kar raha hai (no deploy)...
    mvn clean install -DskipTests
)
set BUILD_CODE=%errorlevel%
popd

echo.
echo ============================================================
if %BUILD_CODE% equ 0 (
    echo   BUILD SUCCESS
    echo.
    echo   Your TechBlog components are now deployed to AEM.
    echo.
    echo   Next steps:
    echo     1. Open: http://localhost:4502/system/console/bundles
    echo        Confirm "Tech Blog - Core" bundle is ACTIVE.
    echo     2. Go to Sites, create a page using the Tech Blog template.
    echo     3. Allow group "Tech Blog" in Layout Container policy.
    echo     4. Drag and drop components: Article Header, Author Bio,
    echo        Code Snippet, Tags List.
) else (
    echo   BUILD FAILED  (exit code: %BUILD_CODE%^)
    echo.
    echo   Check the Maven output above for errors.
    echo   Common causes:
    echo     - AEM not running on localhost:4502
    echo     - Wrong credentials (default: admin/admin^)
    echo     - Java/Maven version mismatch
)
echo ============================================================
echo.
pause
endlocal
