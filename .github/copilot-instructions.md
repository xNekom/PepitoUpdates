# 🐱 Pépito Updates - Copilot Instructions

## Architecture Overview

**Pépito Updates** es una app Flutter multiplataforma que monitorea un gato en tiempo real via IoT. La arquitectura combina:

```
[Flutter App Android/iOS/Web] → [Supabase + Edge Functions] → [External API: thecatdoor.com]
                                        ↓
                                  [PostgreSQL DB]
                                        ↓
                                [GitHub Actions] ← [Real-time polling]
```

### Core Stack
- **Frontend**: Flutter 3.8+ (Dart) - multiplataforma (Android, iOS, Web, Windows, macOS, Linux)
- **Backend**: Supabase (PostgreSQL, Edge Functions en Deno)
- **State Management**: Riverpod
- **Data Source**: API externa `thecatdoor.com` + Supabase real-time
- **CI/CD**: GitHub Actions + Vercel deployment

## Project Structure

| Ruta | Propósito |
|------|-----------|
| `lib/` | Código Dart principal (UI, servicios, modelos) |
| `lib/services/` | Lógica de negocio: `pepito_api_service.dart`, `supabase_service.dart`, etc. |
| `lib/providers/` | Riverpod state managers (`pepito_providers.dart`, `hybrid_pepito_provider.dart`) |
| `lib/screens/` | Pantallas UI: `home_screen.dart`, `statistics_screen.dart`, etc. |
| `lib/middleware/` | Middleware de seguridad y validación |
| `lib/models/` | DTOs: `pepito_activity.dart`, `user.dart`, `auth_token.dart` |
| `supabase/functions/` | Edge Functions (Deno): `check-pepito-status/` ejecuta polling |
| `.github/workflows/` | GitHub Actions: `check-pepito-status.yml` dispara el cron cada 2 min |
| `vercel.json` | Configuración de despliegue en Vercel para web |

## Data Flow: Rastrear posición de Pépito

1. **GitHub Actions (cada 2 min)** → Llama Supabase Edge Function
2. **Edge Function `check-pepito-status`** → Consulta `api.thecatdoor.com/rest/v1/last-status`
3. **Comparación**: Si estado cambió o pasaron >60s, inserta en `pepito_activities` (Supabase)
4. **App Flutter** → Suscrita a cambios real-time en Supabase vía WebSocket
5. **UI actualiza** → Muestra estado actual + historial

**Clave**: El polling NO ocurre en la app; ocurre en GitHub Actions. La app solo se suscribe a eventos.

## Development Workflows

### Web Local (desarrollo)
```bash
flutter run -d chrome --web-port=5000
# Con proxy CORS (recomendado):
run_with_proxy.bat  # Windows
./run_with_proxy.sh  # Linux/Mac
```

### Construcción
```bash
flutter build web --release              # Web (Vercel deployment)
flutter build apk --release              # Android
flutter build ios --release              # iOS (M1/M2 requiere extra config)
flutter build windows --release          # Windows
```

### Testing
```bash
flutter test                             # Unit tests
flutter test --coverage test_driver/    # Con coverage
```

### Supabase Functions (Edge)
```bash
supabase functions deploy check-pepito-status  # Deploy function
supabase functions serve                        # Local testing
```

## Critical Implementation Patterns

### 1. API Fallback Strategy
[PepitoApiService](lib/services/pepito_api_service.dart) implementa fallback multi-capa:
- **Primary**: Supabase Edge Function (recomendado)
- **Secondary**: API directa `api.thecatdoor.com` (debug mode)
- **Middleware**: Validación, rate-limiting, caching

**Usar**: Siempre delega a `PepitoApiService` en lugar de acceder directamente a APIs.

### 2. Real-time Subscriptions (Riverpod + Supabase)
[HybridPepitoProvider](lib/providers/hybrid_pepito_provider.dart) combina:
- Polling local (completa cuando Edge Function falla)
- Supabase WebSocket real-time (cuando funciona)

No use subscripciones directas; use providers Riverpod para estado reactivo.

### 3. Security Middleware
[security_middleware.dart](lib/middleware/security_middleware.dart) valida:
- JWT tokens (OAuth con Supabase)
- Rate limits (protege APIs externas)
- Input sanitization (previene inyecciones)

**Aplique** a todo endpoint expuesto.

### 4. Localization (i18n)
- Strings en [l10n/{app_en.arb, app_es.arb}](lib/l10n/)
- Generados automáticamente en [generated/app_localizations_*.dart](lib/generated/)
- Acceso vía `AppLocalizations.of(context)!.myString`

### 5. Caching Strategy
[cache_service.dart](lib/services/cache_service.dart) + middleware:
- Cache local SQLite para datos históricos
- TTL configurable por tipo de dato
- Invalidación automática en cambios

## Common Tasks

### ✅ Agregar nueva métrica/estadística
1. Crear modelo en `lib/models/`
2. Extender query en Edge Function `check-pepito-status/index.ts`
3. Insertar dato en `pepito_activities` metadatos
4. Crear Provider en `lib/providers/` con Riverpod
5. UI en `lib/screens/statistics_screen.dart`

### ✅ Cambiar horario polling (Editor Functions)
- Editar `cron:` en [.github/workflows/check-pepito-status.yml](.github/workflows/check-pepito-status.yml)
- Formato cron: `*/X * * * *` (X = minutos; min 2 para Hobby Vercel = solo daily)
- **Nota**: GitHub Actions soporta cualquier frecuencia; Vercel (Hobby) solo daily.

### ✅ Desplegar
- **Web** (Vercel): Git push → auto-deploy vía [vercel.json](vercel.json)
- **Mobile** (TestFlight/Play Store): Manual via Flutter/Xcode/Android Studio
- **Edge Functions**: `supabase functions deploy` (auth requerida)

### ✅ Debuggear CORS en web
Si CORS falla:
1. Local: Ejecute `run_with_proxy.bat` (proxy CORS local)
2. Producción: Verifique que Edge Functions estén activas
3. Fallback: [hybrid_pepito_provider.dart](lib/providers/hybrid_pepito_provider.dart) intenta API directa en debug

## Secrets & Environment

**Requeridos** en Supabase + GitHub Actions + Vercel:
- `SUPABASE_URL`: URL del proyecto
- `SUPABASE_ANON_KEY`: Public key (safe for client)
- `SUPABASE_SERVICE_ROLE_KEY`: Admin key (Edge Functions solo)
- `SUPABASE_EDGE_FUNCTION_URL`: Endpoint de Edge Function

**Configuración local** [lib/config/](lib/config/):
- [environment_config.dart](lib/config/environment_config.dart): Variables por ambiente (dev/prod)
- [supabase_config.dart](lib/config/supabase_config.dart): Credenciales (git-ignored)

## Testing Guidelines

- **Unit tests**: `test/` - DTOs, servicios, lógica de negocio
- **Widget tests**: Minimal (UI heavy cambia frecuentemente)
- **Coverage meta**: 60%+ en servicios; UI opcional
- **Mock Supabase**: Usar `MockSupabaseClient` para tests

---

**Última actualización**: 19 feb 2026 | Mentenedor: @ptalayajimenez
