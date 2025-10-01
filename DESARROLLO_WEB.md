# Desarrollo Web - So### 5. **Servidor Proxy Local (Recomendado)**
Ejecuta un proxy Node.js que maneja CORS automáticamente.

**Estado**: Implementado
**Archivo**: `run_with_proxy.bat`
**Requisitos**: Node.js instalado
**Uso**: `.\run_with_proxy.bat`
**Ventajas**:
- ✅ Evita completamente problemas CORS
- ✅ No requiere configuración del navegador
- ✅ Funciona con cualquier navegador
- ✅ Logging detallado de peticiones
- ✅ Simula comportamiento de producción

**Configuración automática**:
- Proxy para thecatdoor: `/api/thecatdoor/*` → `https://api.thecatdoor.com/*`
- Proxy para Supabase: `/api/supabase/*` → `https://ewxarmlqoowlxdqoebcb.supabase.co/*`s CORS

## Problema
La aplicación Flutter web tiene problemas de CORS cuando intenta acceder directamente a APIs externas desde el navegador.

## Soluciones Disponibles

### 1. Edge Functions (Recomendado)
Las Edge Functions de Supabase actúan como proxy y evitan problemas CORS.

**Estado**: ✅ Implementado
**Uso**: Automático en producción
**Configuración**: Asegurar que estén desplegadas en Supabase

### 2. Modo Debug con Fallback
En modo debug, la aplicación permite fallback a API directa.

**Estado**: ✅ Implementado
**Uso**: Automático cuando Edge Functions fallan en debug
**Limitación**: Solo funciona en modo debug

### 3. **Servidor Proxy Local (Recomendado)**
Ejecuta un proxy Node.js que maneja CORS automáticamente.

**Estado**: ✅ Implementado
**Archivo**: `run_with_proxy.bat`
**Requisitos**: Node.js instalado
**Uso**: `.\run_with_proxy.bat`
**Ventajas**:
- ✅ Evita completamente problemas CORS
- ✅ No requiere configuración del navegador
- ✅ Funciona con cualquier navegador
- ✅ Logging detallado de peticiones
- ✅ Simula comportamiento de producción

**Configuración automática**:
- Proxy para thecatdoor: `/api/thecatdoor/*` → `https://api.thecatdoor.com/*`
- Proxy para Supabase: `/api/supabase/*` → `https://ewxarmlqoowlxdqoebcb.supabase.co/*`

## Verificación

Para verificar que las Edge Functions funcionan:

```bash
# Ver estado de Supabase
supabase status

# Ver Edge Functions desplegadas
supabase functions list

# Desplegar si es necesario
supabase functions deploy pepito-proxy
```

## Recomendación

1. **Desarrollo web**: Usar `run_with_proxy.bat` (recomendado - sin problemas CORS)
2. **Desarrollo móvil/desktop**: Funciona automáticamente
3. **Debug rápido**: Usar modo debug con fallback automático
4. **Producción**: Usar Edge Functions (sin problemas CORS)</content>
<parameter name="filePath">c:\Users\Pedro\Documents\GitHub\PepitoUpdates\DESARROLLO_WEB.md