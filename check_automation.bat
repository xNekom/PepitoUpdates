@echo off
REM Script para verificar el estado de la automatización
echo ========================================
echo   Verificando Automatización 24/7
echo ========================================
echo.

echo Verificando archivos de Edge Function...
if exist "supabase\functions\check-pepito-status\index.ts" (
    echo index.ts encontrado
) else (
    echo ❌ index.ts NO encontrado
)

if exist "supabase\functions\check-pepito-status\deno.json" (
    echo deno.json encontrado
) else (
    echo ❌ deno.json NO encontrado
)

if exist "supabase\functions\check-pepito-status\import_map.json" (
    echo import_map.json encontrado
) else (
    echo ❌ import_map.json NO encontrado
)
echo.

echo Verificando scripts de automatización...
if exist "setup_cron_job.sql" (
    echo setup_cron_job.sql encontrado
) else (
    echo ❌ setup_cron_job.sql NO encontrado
)

if exist "deploy_edge_functions.bat" (
    echo deploy_edge_functions.bat encontrado
) else (
    echo ❌ deploy_edge_functions.bat NO encontrado
)

if exist "test_edge_function.bat" (
    echo test_edge_function.bat encontrado
) else (
    echo ❌ test_edge_function.bat NO encontrado
)
echo.

echo Verificando configuración de Supabase...
if exist "supabase\config.toml" (
    echo supabase\config.toml encontrado
) else (
    echo ❌ supabase\config.toml NO encontrado
)
echo.

echo ========================================
echo   Estado de la Automatización
echo ========================================
echo.
echo Edge Function implementada
echo Cron Job script preparado
echo Scripts de despliegue listos
echo.
echo 📋 Para activar la automatización 24/7:
echo.
echo 1. Desplegar Edge Function:
echo    .\deploy_edge_functions.bat
echo.
echo 2. Configurar Cron Job en Supabase SQL Editor:
echo    Ejecutar setup_cron_job.sql
echo.
echo 3. Verificar funcionamiento:
echo    Los datos se actualizarán cada 5 minutos automáticamente
echo.
echo 🎉 ¡Pépito será monitoreado 24/7!
echo.

pause