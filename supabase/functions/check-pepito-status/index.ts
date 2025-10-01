import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface PepitoStatus {
  event: string;
  type: string;
  time: number;
  img: string;
}

serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Verificar si la petición viene de GitHub Actions
    const userAgent = req.headers.get('user-agent') || ''
    const githubDelivery = req.headers.get('x-github-delivery')
    const fromGitHubActions = req.headers.get('x-from-github-actions') === 'true'
    const isFromGitHub = userAgent.includes('GitHub') || githubDelivery !== null || fromGitHubActions

    console.log('🔍 User-Agent:', userAgent)
    console.log('🔍 GitHub Delivery:', githubDelivery)
    console.log('🔍 From GitHub Actions:', fromGitHubActions)
    console.log('🔍 Is from GitHub:', isFromGitHub)

    // Si no viene de GitHub, verificar autenticación JWT
    if (!isFromGitHub) {
      const authHeader = req.headers.get('authorization')
      if (!authHeader) {
        return new Response(
          JSON.stringify({ code: 401, message: 'Missing authorization header' }),
          { 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 401
          }
        )
      }

      // Aquí iría la validación JWT si fuera necesaria
      // Por ahora, solo permitimos si viene de GitHub
    }

    // Crear cliente de Supabase
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    console.log('🔄 Iniciando verificación del estado de Pépito...')

    // Consultar la API de Pépito
    const apiResponse = await fetch('https://api.thecatdoor.com/rest/v1/last-status', {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      signal: AbortSignal.timeout(10000) // 10 segundos timeout
    })

    if (!apiResponse.ok) {
      throw new Error(`API response not ok: ${apiResponse.status}`)
    }

    const pepitoStatus: PepitoStatus = await apiResponse.json()
    console.log('📡 Estado obtenido de la API:', pepitoStatus)

    // Obtener el último estado guardado
    const { data: lastActivity, error: queryError } = await supabaseClient
      .from('pepito_activities')
      .select('timestamp, type')
      .order('timestamp', { ascending: false })
      .limit(1)
      .single()

    if (queryError && queryError.code !== 'PGRST116') { // PGRST116 = no rows found
      console.error('❌ Error consultando última actividad:', queryError)
      throw queryError
    }

    let shouldInsert = false
    const now = Math.floor(Date.now() / 1000)

    if (!lastActivity) {
      // No hay actividades previas, insertar
      shouldInsert = true
      console.log('📝 No hay actividades previas, insertando primera actividad')
    } else {
      // Verificar si ha pasado más de 1 minuto o si el estado cambió
      const timeDiff = now - lastActivity.timestamp
      const statusChanged = lastActivity.type !== pepitoStatus.type
      
      if (timeDiff > 60 || statusChanged) {
        shouldInsert = true
        console.log(`📝 Insertando nueva actividad: tiempo=${timeDiff}s, cambio=${statusChanged}`)
      } else {
        console.log('⏭️ No es necesario insertar, estado reciente y sin cambios')
      }
    }

    if (shouldInsert) {
      // Insertar nueva actividad con la estructura correcta
      const { data: insertData, error: insertError } = await supabaseClient
        .from('pepito_activities')
        .insert({
          event: 'pepito', // Campo requerido
          type: pepitoStatus.type, // 'in' o 'out'
          timestamp: new Date(pepitoStatus.time * 1000).toISOString(), // Formato ISO para Supabase
          created_at: new Date().toISOString(),
          description: `Pepito ${pepitoStatus.type === 'in' ? 'entró' : 'salió'}`, // Campo requerido
          source: 'edge_function', // Campo requerido
          metadata: {
            api_timestamp: pepitoStatus.time,
            processed_at: new Date().toISOString(),
            automatic_check: true
          }
        })
        .select()

      if (insertError) {
        console.error('❌ Error insertando actividad:', insertError)
        throw insertError
      }

      console.log('Nueva actividad insertada:', insertData)
    }

    return new Response(
      JSON.stringify({
        success: true,
        status: pepitoStatus.type,
        description: `Pepito ${pepitoStatus.type === 'in' ? 'entró' : 'salió'}`,
        inserted: shouldInsert,
        timestamp: now
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )

  } catch (error) {
    console.error('❌ Error en Edge Function:', error)

    const errorMessage = error instanceof Error ? error.message : String(error)

    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
        timestamp: Math.floor(Date.now() / 1000)
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  }
})