@echo off
REM build-all.bat — Build every Maven project from the repo root (Windows).

set PROJECTS=platform\config-server platform\service-registry platform\api-gateway services\user-service services\menu-service services\order-service services\kitchen-service

for %%P in (%PROJECTS%) do (
    echo ==========================================
    echo  Building: %%P
    echo ==========================================
    pushd %%P
    call mvn clean package -DskipTests
    if errorlevel 1 (
        echo BUILD FAILED for %%P
        popd
        exit /b 1
    )
    popd
)

echo.
echo All builds completed successfully.
