param(
    [switch]$Detailed
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Verificando Configuración de Entorno" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Rama actual de Git
Write-Host "Rama actual de Git:" -ForegroundColor Yellow
$branch = git branch --show-current
Write-Host "  $branch" -ForegroundColor White
Write-Host ""

# Variables de entorno
Write-Host "Variables de entorno configuradas:" -ForegroundColor Yellow
$envVars = @(
    "SUPABASE_URL_DEV",
    "SUPABASE_ANON_KEY_DEV",
    "SUPABASE_URL_QA",
    "SUPABASE_ANON_KEY_QA",
    "SUPABASE_URL_UAT",
    "SUPABASE_ANON_KEY_UAT",
    "SUPABASE_URL_PRO",
    "SUPABASE_ANON_KEY_PRO"
)

foreach ($var in $envVars) {
    $value = [Environment]::GetEnvironmentVariable($var)
    if ($value) {
        if ($Detailed) {
            Write-Host "  $var = $value" -ForegroundColor Green
        } else {
            Write-Host "  $var = [CONFIGURADO]" -ForegroundColor Green
        }
    } else {
        Write-Host "  $var = [NO CONFIGURADO]" -ForegroundColor Red
    }
}
Write-Host ""

# Verificar conectividad
Write-Host "Verificando conectividad..." -ForegroundColor Yellow
try {
    $ping = Test-Connection -ComputerName google.com -Count 1 -Quiet
    if ($ping) {
        Write-Host "  Conectividad a Internet: OK" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Conectividad a Internet: FALLANDO" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Conectividad a Internet: ERROR" -ForegroundColor Red
}
Write-Host ""

# Verificar proxy local
Write-Host "Verificando proxy local..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  Proxy local: OK (puerto 3001)" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Proxy local: NO RESPONDE (asegúrate de que esté ejecutándose)" -ForegroundColor Red
    Write-Host "    Ejecuta: npm start" -ForegroundColor Gray
}
Write-Host ""

# Verificar Supabase
Write-Host "Verificando Supabase..." -ForegroundColor Yellow
try {
    $headers = @{ "apikey" = "sb_publishable_WCTtQYWmWqCeF1uaXZMmnA__Os_dv2i" }
    $response = Invoke-WebRequest -Uri "https://ewxarmlqoowlxdqoebcb.supabase.co/rest/v1/" -Headers $headers -TimeoutSec 10 -ErrorAction Stop
    Write-Host "  Supabase producción: OK" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Supabase producción: NO RESPONDE" -ForegroundColor Red
}
Write-Host ""

# Verificar API de thecatdoor
Write-Host "Verificando API de thecatdoor..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://api.thecatdoor.com/rest/v1/last-status" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "  API thecatdoor: OK" -ForegroundColor Green
} catch {
    Write-Host "  ❌ API thecatdoor: NO RESPONDE" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Configuración verificada" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si hay errores, verifica:" -ForegroundColor Yellow
Write-Host "1. Que el proxy esté ejecutándose: npm start" -ForegroundColor White
Write-Host "2. Que las variables de entorno estén configuradas" -ForegroundColor White
Write-Host "3. Que tengas conexión a Internet" -ForegroundColor White
Write-Host ""

if ($Detailed) {
    Write-Host "Modo detallado activado - se muestran valores reales" -ForegroundColor Gray
} else {
    Write-Host "Usa -Detailed para ver los valores reales de las variables" -ForegroundColor Gray
}
Write-Host ""

Read-Host "Presiona Enter para continuar"