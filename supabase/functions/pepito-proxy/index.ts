import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface PepitoStatus {
  event: string
  type: string
  timestamp?: number | string
  time?: number | string
  img: string
}

interface PepitoActivity {
  id: string
  event: string
  type: string
  timestamp: string
  img: string
  confidence: number
  imageUrl?: string
  source: string
  cached: boolean
  authenticated: boolean
  createdAt: string
  updatedAt: string
}

function getEnv(name: string): string {
  const val = Deno.env.get(name)
  if (!val) throw new Error(`Missing required env var: ${name}`)
  return val
}

async function validateAuth(req: Request): Promise<{ valid: boolean; userId?: string }> {
  const authHeader = req.headers.get('authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return { valid: false }
  }
  const token = authHeader.replace('Bearer ', '')
  if (!token) return { valid: false }

  try {
    const supabase = createClient(getEnv('SUPABASE_URL'), getEnv('SUPABASE_ANON_KEY'))
    const { data: { user }, error } = await supabase.auth.getUser(token)
    if (error || !user) return { valid: false }
    return { valid: true, userId: user.id }
  } catch {
    return { valid: false }
  }
}

async function fetchPepitoStatus(): Promise<PepitoActivity> {
  const apiUrl = Deno.env.get('PEPITO_API_URL') || 'https://api.thecatdoor.com/rest/v1'

  const response = await fetch(`${apiUrl}/last-status`, {
    headers: { 'Accept': 'application/json' },
    signal: AbortSignal.timeout(10000),
  })

  if (!response.ok) {
    throw new Error(`Pepito API error: ${response.status}`)
  }

  const data: PepitoStatus = await response.json()
  const rawTs = data.time ?? data.timestamp
  let unixSeconds = Math.floor(Date.now() / 1000)

  if (typeof rawTs === 'number' && Number.isFinite(rawTs)) {
    unixSeconds = rawTs
  } else if (typeof rawTs === 'string') {
    const parsed = Number.parseInt(rawTs, 10)
    if (Number.isFinite(parsed)) unixSeconds = parsed
  }

  return {
    id: `pepito_${Date.now()}`,
    event: data.event || 'pepito',
    type: data.type || 'unknown',
    timestamp: new Date(unixSeconds * 1000).toISOString(),
    img: data.img || '',
    confidence: 1.0,
    imageUrl: data.img || '',
    source: 'edge_function',
    cached: false,
    authenticated: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  }
}

serve(async (req: Request) => {
  const acrHeaders = req.headers.get('access-control-request-headers')
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': acrHeaders || 'authorization, content-type, apikey',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
  }

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  const url = new URL(req.url)
  const path = url.pathname

  try {
    if (path === '/pepito-proxy/health' && req.method === 'GET') {
      return new Response(
        JSON.stringify({ status: 'healthy', timestamp: new Date().toISOString() }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    if (path === '/pepito-proxy/status' && req.method === 'GET') {
      const activity = await fetchPepitoStatus()
      return new Response(JSON.stringify(activity), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json', 'Cache-Control': 'public, max-age=30' },
      })
    }

    if (path === '/pepito-proxy/activities' && req.method === 'GET') {
      const auth = await validateAuth(req)
      if (!auth.valid) {
        return new Response(JSON.stringify({ error: 'Authentication required' }), {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
      const activity = await fetchPepitoStatus()
      activity.authenticated = true
      return new Response(JSON.stringify({ activities: [activity], total: 1 }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    return new Response(
      JSON.stringify({ error: 'Not found', available: ['/pepito-proxy/status', '/pepito-proxy/activities', '/pepito-proxy/health'] }),
      { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(JSON.stringify({ error: 'Internal error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
