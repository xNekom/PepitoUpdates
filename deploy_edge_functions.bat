@echo off
REM Script para desplegar Edge Functions de Supabase
echo ========================================
echo   Desplegando Edge Functions
echo ========================================
echo.

echo Verificando configuración...
if not exist "supabase\config.toml" (
    echo ❌ Error: Archivo supabase\config.toml no encontrado
    echo Asegúrate de estar en el directorio raíz del proyecto
    pause
    exit /b 1
)

echo Desplegando función check-pepito-status...
supabase functions deploy check-pepito-status

if %errorlevel% equ 0 (
    echo Función desplegada exitosamente
    echo.
    echo 📋 Próximos pasos:
    echo 1. Configurar el Cron Job ejecutando setup_cron_job.sql en Supabase SQL Editor
    echo 2. La URL ya está configurada correctamente
    echo 3. Verificar que la función se ejecute cada 1 minuto
    echo.
    echo 🔗 URL de la función:
    echo https://ewxarmlqoowlxdqoebcb.supabase.co/functions/v1/check-pepito-status
) else (
    echo ❌ Error desplegando la función
    echo Verifica que tengas Supabase CLI instalado y configurado
)

echo.
pause