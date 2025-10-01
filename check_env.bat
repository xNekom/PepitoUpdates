@echo off
REM Script para verificar configuración de entorno
echo ========================================
echo   Verificando Configuración de Entorno
echo ========================================
echo.

echo Rama actual de Git:
git branch --show-current
echo.

echo Variables de entorno configuradas:
echo SUPABASE_URL_DEV: %SUPABASE_URL_DEV%
echo SUPABASE_ANON_KEY_DEV: %SUPABASE_ANON_KEY_DEV%
echo SUPABASE_URL_QA: %SUPABASE_URL_QA%
echo SUPABASE_ANON_KEY_QA: %SUPABASE_ANON_KEY_QA%
echo SUPABASE_URL_UAT: %SUPABASE_URL_UAT%
echo SUPABASE_ANON_KEY_UAT: %SUPABASE_ANON_KEY_UAT%
echo SUPABASE_URL_PRO: %SUPABASE_URL_PRO%
echo SUPABASE_ANON_KEY_PRO: %SUPABASE_ANON_KEY_PRO%
echo.

echo Verificando conectividad de red...
ping -n 1 google.com >nul 2>&1
if %errorlevel% equ 0 (
    echo Conectividad a Internet: OK
) else (
    echo ❌ Conectividad a Internet: FALLANDO
)
echo.

echo Verificando proxy local...
curl -s http://localhost:3001 >nul 2>&1
if %errorlevel% equ 0 (
    echo Proxy local: OK
) else (
    echo ❌ Proxy local: NO RESPONDE (asegúrate de que esté ejecutándose)
)
echo.

echo Verificando Supabase (producción)...
curl -s -H "apikey: sb_publishable_WCTtQYWmWqCeF1uaXZMmnA__Os_dv2i" https://ewxarmlqoowlxdqoebcb.supabase.co/rest/v1/ >nul 2>&1
if %errorlevel% equ 0 (
    echo Supabase producción: OK
) else (
    echo ❌ Supabase producción: NO RESPONDE
)
echo.

echo Verificando API de thecatdoor...
curl -s https://api.thecatdoor.com/rest/v1/last-status >nul 2>&1
if %errorlevel% equ 0 (
    echo API thecatdoor: OK
) else (
    echo ❌ API thecatdoor: NO RESPONDE
)
echo.

echo ========================================
echo   Configuración verificada
echo ========================================
echo.
echo Si hay errores, verifica:
echo 1. Que el proxy esté ejecutándose: npm start
echo 2. Que las variables de entorno estén configuradas
echo 3. Que tengas conexión a Internet
echo.

pause