@echo off
REM Script para cambiar entre entornos
REM Uso: switch_env.bat [dev|qa|uat|pro]

if "%1"=="" (
    echo Uso: switch_env.bat [dev^|qa^|uat^|pro]
    echo.
    echo Entornos disponibles:
    echo   dev  - Desarrollo
    echo   qa   - Quality Assurance
    echo   uat  - User Acceptance Testing
    echo   pro  - Produccion
    goto :eof
)

set ENV=%1

REM Validar entorno
if "%ENV%"=="dev" goto valid
if "%ENV%"=="qa" goto valid
if "%ENV%"=="uat" goto valid
if "%ENV%"=="pro" goto valid

echo Error: Entorno '%ENV%' no valido. Use dev, qa, uat o pro.
goto :eof

:valid
echo Cambiando a entorno: %ENV%

REM Cambiar a la rama correspondiente
git checkout %ENV%

if errorlevel 1 (
    echo Error: No se pudo cambiar a la rama %ENV%
    goto :eof
)

echo.
echo Entorno cambiado exitosamente a: %ENV%
echo Rama actual: %ENV%
echo.
echo Para compilar con este entorno, use:
echo flutter run --dart-define=ENVIRONMENT=%ENV%
echo.
echo O para web:
echo flutter run -d chrome --dart-define=ENVIRONMENT=%ENV%