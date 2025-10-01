param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "qa", "uat", "pro")]
    [string]$Environment,

    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "android", "windows", "web")]
    [string]$Target = "all"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Building Pepito Updates for $Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Flutter esté instalado
if (!(Get-Command "flutter" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Flutter no está instalado o no está en el PATH" -ForegroundColor Red
    exit 1
}

# Limpiar builds anteriores
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Generar código
Write-Host "Generating code..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs

# Función para verificar el resultado del build
function Check-BuildResult {
    param($ExitCode, $BuildType)
    if ($ExitCode -eq 0) {
        Write-Host "$BuildType build completed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ $BuildType build failed" -ForegroundColor Red
    }
}

# Build para Android
if ($Target -eq "all" -or $Target -eq "android") {
    Write-Host ""
    Write-Host "Building Android Release APK for $Environment..." -ForegroundColor Yellow
    flutter build apk --release --dart-define=ENVIRONMENT=$Environment
    Check-BuildResult $LASTEXITCODE "Android APK ($Environment)"

    Write-Host ""
    Write-Host "Building Android App Bundle for $Environment..." -ForegroundColor Yellow
    flutter build appbundle --release --dart-define=ENVIRONMENT=$Environment
    Check-BuildResult $LASTEXITCODE "Android App Bundle ($Environment)"
}

# Build para Windows
if ($Target -eq "all" -or $Target -eq "windows") {
    Write-Host ""
    Write-Host "Building Windows Release for $Environment..." -ForegroundColor Yellow
    flutter build windows --release --dart-define=ENVIRONMENT=$Environment
    Check-BuildResult $LASTEXITCODE "Windows ($Environment)"
}

# Build para Web
if ($Target -eq "all" -or $Target -eq "web") {
    Write-Host ""
    Write-Host "Building Web Release for $Environment..." -ForegroundColor Yellow
    flutter build web --release --dart-define=ENVIRONMENT=$Environment --web-renderer html
    Check-BuildResult $LASTEXITCODE "Web ($Environment)"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   $Environment builds completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Build artifacts location:" -ForegroundColor Green
if ($Target -eq "all" -or $Target -eq "android") {
    Write-Host "- Android APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
    Write-Host "- Android Bundle: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor White
}
if ($Target -eq "all" -or $Target -eq "windows") {
    Write-Host "- Windows: build\windows\x64\runner\Release" -ForegroundColor White
}
if ($Target -eq "all" -or $Target -eq "web") {
    Write-Host "- Web: build\web" -ForegroundColor White
}
Write-Host ""

# Mostrar tamaños de archivos si existen
if (($Target -eq "all" -or $Target -eq "android") -and (Test-Path "build\app\outputs\flutter-apk\app-release.apk")) {
    $apkSize = (Get-Item "build\app\outputs\flutter-apk\app-release.apk").Length / 1MB
    Write-Host "APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Environment: $Environment" -ForegroundColor Cyan
Write-Host "Target: $Target" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to continue..."