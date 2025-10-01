@echo off
echo ========================================
echo 🚀 PepitoUpdates - Desarrollo con Proxy
echo ========================================
echo.

echo 📦 Verificando Node.js...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ ERROR: Node.js no está instalado.
    echo Por favor instala Node.js desde https://nodejs.org
    pause
    exit /b 1
)

echo ✅ Node.js encontrado

echo.
echo 📦 Instalando dependencias del proxy...
call npm install
if %errorlevel% neq 0 (
    echo ❌ ERROR: Falló la instalación de dependencias
    pause
    exit /b 1
)

echo ✅ Dependencias instaladas

echo.
echo 🚀 Iniciando servidor proxy...
start "Proxy Server" cmd /c "npm start"

echo ⏳ Esperando que el proxy inicie...
timeout /t 3 /nobreak >nul

echo.
echo 🎯 Iniciando Flutter...
flutter run -d chrome

echo.
echo 👋 Proxy detenido
pause