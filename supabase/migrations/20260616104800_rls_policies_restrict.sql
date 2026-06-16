-- Migración: Restringir RLS policies para pepito_activities
-- Reemplaza las políticas abiertas USING (true) por políticas
-- que requieren auth.role() = 'service_role' para operaciones
-- destructivas (UPDATE, DELETE).
--
-- La app Flutter usa SUPABASE_ANON_KEY para SELECT e INSERT.
-- Las edge functions usan SUPABASE_SERVICE_ROLE_KEY y bypass RLS.
--
-- Fecha: 2026-06-16

-- 1. Eliminar políticas existentes (abiertas)
DROP POLICY IF EXISTS "Allow read access for all users" ON pepito_activities;
DROP POLICY IF EXISTS "Allow insert for all users" ON pepito_activities;
DROP POLICY IF EXISTS "Allow update for all users" ON pepito_activities;
DROP POLICY IF EXISTS "Allow delete for all users" ON pepito_activities;

-- 2. Crear políticas restringidas

-- SELECT: permitido para anon (lectura de datos en la app)
CREATE POLICY "Allow anon read" ON pepito_activities
  FOR SELECT USING (true);

-- INSERT: permitido para anon (la app guarda actividades)
CREATE POLICY "Allow anon insert" ON pepito_activities
  FOR INSERT WITH CHECK (true);

-- UPDATE: solo service_role (evita modificaciones desde anon)
CREATE POLICY "Allow service_role update" ON pepito_activities
  FOR UPDATE USING (auth.role() = 'service_role');

-- DELETE: solo service_role (evita eliminaciones desde anon)
CREATE POLICY "Allow service_role delete" ON pepito_activities
  FOR DELETE USING (auth.role() = 'service_role');

-- 3. Verificar que RLS sigue habilitado
ALTER TABLE pepito_activities ENABLE ROW LEVEL SECURITY;

-- 4. (Opcional) Política para usar JWT personalizado en edge functions
-- Si las edge functions usan un service_role_key, ya bypass RLS.
-- No se necesita configuración adicional.
