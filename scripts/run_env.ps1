param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "qa", "uat", "pro")]
    [string]$Environment,

    [Parameter(Mandatory=$false)]
    [string]$Device,

    [switch]$Web,
    [switch]$Chrome,
    [switch]$Edge
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Running Pepito Updates - $Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Flutter esté instalado
if (!(Get-Command "flutter" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Flutter no está instalado o no está en el PATH" -ForegroundColor Red
    exit 1
}

# Preparar comando base
$command = "flutter run --dart-define=ENVIRONMENT=$Environment"

# Determinar dispositivo
if ($Web -or $Chrome) {
    $command += " -d chrome"
    Write-Host "Running on Chrome (Web) with environment: $Environment" -ForegroundColor Yellow
} elseif ($Edge) {
    $command += " -d edge"
    Write-Host "Running on Edge (Web) with environment: $Environment" -ForegroundColor Yellow
} elseif ($Device) {
    $command += " -d $Device"
    Write-Host "Running on device '$Device' with environment: $Environment" -ForegroundColor Yellow
} else {
    Write-Host "Running on default device with environment: $Environment" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Command: $command" -ForegroundColor Gray
Write-Host ""

# Ejecutar Flutter
Write-Host "Starting Flutter application..." -ForegroundColor Green
Write-Host ""

try {
    Invoke-Expression $command
} catch {
    Write-Host "Error running Flutter application: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}