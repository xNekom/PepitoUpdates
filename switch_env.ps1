param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "qa", "uat", "pro")]
    [string]$Environment
)

Write-Host "Cambiando a entorno: $Environment" -ForegroundColor Green

# Cambiar a la rama correspondiente
git checkout $Environment

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: No se pudo cambiar a la rama $Environment" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Entorno cambiado exitosamente a: $Environment" -ForegroundColor Green
Write-Host "Rama actual: $Environment" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para compilar con este entorno, use:" -ForegroundColor Yellow
Write-Host "flutter run --dart-define=ENVIRONMENT=$Environment" -ForegroundColor White
Write-Host ""
Write-Host "O para web:" -ForegroundColor Yellow
Write-Host "flutter run -d chrome --dart-define=ENVIRONMENT=$Environment" -ForegroundColor White