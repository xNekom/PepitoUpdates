@echo off
REM Script para verificar configuración de Supabase Edge Functions
echo ========================================
echo   Verificando Supabase Functions
echo ========================================
echo.

echo Verificando archivos de configuración...
if exist "supabase\functions\pepito-proxy\index.ts" (
    echo Archivo index.ts encontrado
) else (
    echo ❌ Archivo index.ts NO encontrado
)

if exist "supabase\functions\pepito-proxy\deno.json" (
    echo Archivo deno.json encontrado
) else (
    echo ❌ Archivo deno.json NO encontrado
)

if exist "supabase\functions\pepito-proxy\import_map.json" (
    echo Archivo import_map.json encontrado
) else (
    echo ❌ Archivo import_map.json NO encontrado
)
echo.

echo Verificando configuración de VS Code...
if exist ".vscode\settings.json" (
    echo Archivo .vscode\settings.json encontrado
    findstr /C:"deno.enable" .vscode\settings.json >nul
    if %errorlevel% equ 0 (
        echo Deno habilitado en VS Code
    ) else (
        echo ❌ Deno NO habilitado en VS Code
    )
) else (
    echo ❌ Archivo .vscode\settings.json NO encontrado
)
echo.

echo Verificando CLI de Supabase...
supabase --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Supabase CLI instalado
    supabase --version
) else (
    echo ❌ Supabase CLI NO instalado
    echo Instalar desde: https://supabase.com/docs/guides/cli
)
echo.

echo Verificando proyecto de Supabase...
if exist "supabase\config.toml" (
    echo Archivo supabase\config.toml encontrado
) else (
    echo ❌ Archivo supabase\config.toml NO encontrado
)
echo.

echo ========================================
echo   Instrucciones para corregir errores
echo ========================================
echo.
echo Si hay errores:
echo 1. Instalar Supabase CLI: https://supabase.com/docs/guides/cli
echo 2. Instalar extensión Deno en VS Code: denoland.vscode-deno
echo 3. Reiniciar VS Code después de instalar la extensión
echo 4. Verificar que las variables de entorno estén configuradas
echo.
echo Para desplegar la función:
echo supabase functions deploy pepito-proxy
echo.

pause