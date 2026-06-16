import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface PepitoStatus {
  event: string;
  type: string;
  time: number;
  img: string;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
}

function getEnv(name: string): string {
  const val = Deno.env.get(name)
  if (!val) throw new Error(`Missing env: ${name}`)
  return val
}

function isAuthorized(req: Request): boolean {
  const auth = req.headers.get('authorization') || ''
  const token = auth.replace('Bearer ', '')
  const serviceKey = getEnv('SUPABASE_SERVICE_ROLE_KEY')
  return token === serviceKey
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (!isAuthorized(req)) {
    return new Response(
      JSON.stringify({ code: 401, message: 'Unauthorized' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 401 },
    )
  }

  try {
    const supabase = createClient(getEnv('SUPABASE_URL'), getEnv('SUPABASE_SERVICE_ROLE_KEY'))

    const apiResponse = await fetch('https://api.thecatdoor.com/rest/v1/last-status', {
      headers: { 'Accept': 'application/json' },
      signal: AbortSignal.timeout(15000),
    })

    if (!apiResponse.ok) {
      throw new Error(`API error: ${apiResponse.status}`)
    }

    const pepitoStatus: PepitoStatus = await apiResponse.json()
    let apiTimestamp = pepitoStatus.time
    if (!apiTimestamp || apiTimestamp < 1000000000) {
      apiTimestamp = Math.floor(Date.now() / 1000)
    }

    const fiveMinAgo = new Date((Math.floor(Date.now() / 1000) - 300) * 1000).toISOString()
    const { data: recent } = await supabase
      .from('pepito_activities')
      .select('timestamp')
      .gte('timestamp', fiveMinAgo)
      .eq('type', pepitoStatus.type)
      .order('created_at', { ascending: false })
      .limit(1)

    let shouldInsert = false
    if (!recent || recent.length === 0) {
      shouldInsert = true
    } else {
      const lastTs = Math.floor(new Date(recent[0].timestamp).getTime() / 1000)
      if (Math.floor(Date.now() / 1000) - lastTs > 60) {
        shouldInsert = true
      }
    }

    if (shouldInsert) {
      const { error: insertError } = await supabase
        .from('pepito_activities')
        .insert({
          event: 'pepito',
          type: pepitoStatus.type,
          timestamp: new Date(apiTimestamp * 1000).toISOString(),
          created_at: new Date().toISOString(),
          description: `Pepito ${pepitoStatus.type === 'in' ? 'entró' : 'salió'}`,
          source: 'edge_function',
          metadata: { api_timestamp: apiTimestamp, automatic_check: true },
        })

      if (insertError) throw insertError
    }

    return new Response(
      JSON.stringify({ success: true, status: pepitoStatus.type, inserted: shouldInsert }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 },
    )
  } catch (error) {
    console.error('Error:', error)
    const msg = error instanceof Error ? error.message : String(error)
    return new Response(
      JSON.stringify({ success: false, error: msg }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 },
    )
  }
})
