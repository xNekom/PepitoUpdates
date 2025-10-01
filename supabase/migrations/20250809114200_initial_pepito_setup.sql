-- Configuración inicial de Supabase para PepitoUpdates
-- Este archivo contiene la estructura de la base de datos y funciones necesarias

-- 1. Crear la tabla de actividades de Pépito
CREATE TABLE IF NOT EXISTS pepito_activities (
  id BIGSERIAL PRIMARY KEY,
  type VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  source VARCHAR(20) NOT NULL DEFAULT 'api',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Índices para mejorar el rendimiento
  CONSTRAINT unique_timestamp_type UNIQUE (timestamp, type)
);

-- Crear índices para optimizar las consultas
CREATE INDEX IF NOT EXISTS idx_pepito_activities_timestamp ON pepito_activities (timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_pepito_activities_type ON pepito_activities (type);
CREATE INDEX IF NOT EXISTS idx_pepito_activities_created_at ON pepito_activities (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_pepito_activities_source ON pepito_activities (source);

-- 2. Habilitar Row Level Security (RLS)
ALTER TABLE pepito_activities ENABLE ROW LEVEL SECURITY;

-- 3. Crear políticas de seguridad (permitir lectura y escritura para usuarios autenticados)
CREATE POLICY "Allow read access for all users" ON pepito_activities
  FOR SELECT USING (true);

CREATE POLICY "Allow insert for all users" ON pepito_activities
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow update for all users" ON pepito_activities
  FOR UPDATE USING (true);

CREATE POLICY "Allow delete for all users" ON pepito_activities
  FOR DELETE USING (true);

-- 4. Función para verificar el estado de Pépito (equivalente a Cloud Function)
CREATE OR REPLACE FUNCTION check_pepito_status()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  api_response jsonb;
  current_status text;
  current_description text;
  last_activity_timestamp timestamptz;
  should_insert boolean := false;
BEGIN
  -- Obtener el último estado guardado
  SELECT timestamp INTO last_activity_timestamp
  FROM pepito_activities
  ORDER BY timestamp DESC
  LIMIT 1;
  
  -- Realizar petición HTTP a la API de Pépito
  -- Nota: Esto requiere la extensión http de Supabase
  SELECT content::jsonb INTO api_response
  FROM http_get('https://pepito-api.vercel.app/api/status');
  
  -- Extraer información del response
  current_status := api_response->>'status';
  current_description := api_response->>'description';
  
  -- Verificar si necesitamos insertar una nueva actividad
  IF last_activity_timestamp IS NULL THEN
    should_insert := true;
  ELSE
    -- Verificar si ha pasado más de 1 minuto desde la última actividad
    -- o si el estado ha cambiado
    SELECT COUNT(*) = 0 INTO should_insert
    FROM pepito_activities
    WHERE timestamp > NOW() - INTERVAL '1 minute'
      AND type = current_status;
  END IF;
  
  -- Insertar nueva actividad si es necesario
  IF should_insert THEN
    INSERT INTO pepito_activities (type, description, source, timestamp)
    VALUES (current_status, current_description, 'cron', NOW())
    ON CONFLICT (timestamp, type) DO NOTHING;
    
    -- Log para debugging
    RAISE NOTICE 'Nueva actividad insertada: % - %', current_status, current_description;
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Log del error
    RAISE NOTICE 'Error en check_pepito_status: %', SQLERRM;
END;
$$;

-- 5. Función para limpiar actividades antiguas
CREATE OR REPLACE FUNCTION cleanup_old_activities()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Eliminar actividades más antiguas que 30 días
  DELETE FROM pepito_activities
  WHERE created_at < NOW() - INTERVAL '30 days';
  
  -- Log del resultado
  RAISE NOTICE 'Limpieza completada. Actividades eliminadas: %', ROW_COUNT;
END;
$$;

-- 6. Función para obtener estadísticas
CREATE OR REPLACE FUNCTION get_activity_statistics(
  start_date timestamptz DEFAULT NULL,
  end_date timestamptz DEFAULT NULL
)
RETURNS TABLE (
  activity_type text,
  count bigint,
  percentage numeric
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  total_count bigint;
BEGIN
  -- Establecer fechas por defecto si no se proporcionan
  IF start_date IS NULL THEN
    start_date := NOW() - INTERVAL '30 days';
  END IF;
  
  IF end_date IS NULL THEN
    end_date := NOW();
  END IF;
  
  -- Obtener el total de actividades en el rango
  SELECT COUNT(*) INTO total_count
  FROM pepito_activities
  WHERE timestamp BETWEEN start_date AND end_date;
  
  -- Retornar estadísticas por tipo
  RETURN QUERY
  SELECT 
    pa.type::text,
    COUNT(*)::bigint,
    CASE 
      WHEN total_count > 0 THEN ROUND((COUNT(*)::numeric / total_count::numeric) * 100, 2)
      ELSE 0::numeric
    END
  FROM pepito_activities pa
  WHERE pa.timestamp BETWEEN start_date AND end_date
  GROUP BY pa.type
  ORDER BY COUNT(*) DESC;
END;
$$;

-- 7. Configurar Realtime para la tabla
-- Esto permite suscripciones en tiempo real desde la app
ALTER PUBLICATION supabase_realtime ADD TABLE pepito_activities;

-- 8. Insertar datos de ejemplo (opcional)
-- INSERT INTO pepito_activities (type, description, source) VALUES
-- ('online', 'Pépito está en línea y funcionando correctamente', 'setup'),
-- ('offline', 'Pépito está fuera de línea', 'setup');

-- 9. Configuración de cron jobs (comentado - requiere extensión pg_cron)
-- Para habilitar los cron jobs, primero habilita la extensión pg_cron en el dashboard:
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Luego descomenta las siguientes líneas:
-- SELECT cron.schedule(
--     'check_pepito_status',
--     '*/5 * * * *',
--     $$SELECT net.http_post(
--         url := 'https://ewxarmlqoowlxdqoebcb.supabase.co/functions/v1/check-pepito-status',
--         headers := '{}'::jsonb,
--         body := '{}'::jsonb
--     );$$
-- );

-- SELECT cron.schedule(
--     'cleanup_old_activities',
--     '0 2 * * *',
--     $$SELECT cleanup_old_activities();$$
-- );

-- Comentarios finales
-- Para verificar los cron jobs (una vez habilitados):
-- SELECT * FROM cron.job;
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;