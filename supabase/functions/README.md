# Supabase Edge Functions

Este directorio contiene las funciones de Supabase Edge que se ejecutan en el entorno de Deno.

## Configuración de VS Code

Para trabajar con las funciones de Supabase Edge en VS Code, necesitas:

### 1. Instalar la Extensión de Deno
```bash
# En VS Code: Ctrl+Shift+P -> Extensions: Install Extension -> Deno
code --install-extension denoland.vscode-deno
```

### 2. Configuración del Proyecto
El archivo `.vscode/settings.json` ya está configurado para habilitar Deno en las funciones:

```json
{
  "deno.enable": true,
  "deno.enablePaths": ["./supabase/functions"],
  "deno.config": "./supabase/functions/pepito-proxy/deno.json"
}
```

### 3. Archivos de Configuración
- `deno.json`: Configuración de Deno para la función
- `import_map.json`: Mapeo de importaciones

## Desarrollo Local

### Prerrequisitos
- Deno instalado: https://deno.com/manual/getting_started/installation
- Node.js y npm (para el proxy local)

### Ejecutar la Función Localmente
```bash
# Desde el directorio de la función
cd supabase/functions/pepito-proxy
deno run --allow-net --allow-env --allow-read index.ts
```

### Ejecutar con el Proxy Local
```bash
# Terminal 1: Proxy local
npm start

# Terminal 2: Función de Supabase (opcional para testing)
cd supabase/functions/pepito-proxy
deno run --allow-net --allow-env --allow-read index.ts
```

## Despliegue

### Variables de Entorno Requeridas
```bash
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
SUPABASE_SERVICE_ROLE_KEY=tu-service-role-key
PEPITO_API_URL=https://api.thecatdoor.com/rest/v1
```

### Desplegar la Función
```bash
supabase functions deploy pepito-proxy
```

## Endpoints

### GET /pepito-proxy/status
Obtiene el estado actual de Pépito desde la API de thecatdoor.

**Respuesta:**
```json
{
  "id": "pepito_1234567890",
  "event": "pepito",
  "type": "in",
  "timestamp": "2025-10-01T03:55:06.000Z",
  "img": "https://storage.thecatdoor.com/assets/1759283706-in-1100978010.jpg",
  "confidence": 1.0,
  "imageUrl": "https://storage.thecatdoor.com/assets/1759283706-in-1100978010.jpg",
  "source": "edge_function",
  "cached": false,
  "authenticated": true,
  "createdAt": "2025-10-01T03:55:06.000Z",
  "updatedAt": "2025-10-01T03:55:06.000Z"
}
```

### GET /pepito-proxy/activities
Obtiene las actividades de Pépito (requiere autenticación).

### GET /pepito-proxy/health
Verifica el estado de la función.

## Notas sobre TypeScript

Los errores de TypeScript que aparecen en VS Code son normales porque VS Code no siempre reconoce correctamente el entorno de Deno. El código funciona correctamente en el entorno de Supabase Edge Functions.

Si los errores persisten:
1. Reinicia VS Code
2. Asegúrate de que la extensión de Deno esté instalada y habilitada
3. Verifica que la configuración en `.vscode/settings.json` sea correcta