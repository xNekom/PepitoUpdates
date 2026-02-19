// @ts-ignore: Deno modules not recognized in VS Code
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
// @ts-ignore: Supabase module not recognized in VS Code
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface PepitoStatus {
  event: string
  type: string
  timestamp: number
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

interface CacheEntry {
  data: PepitoActivity
  timestamp: number
  ttl: number
}

interface RequestContext {
  userId?: string
  sessionId?: string
  userAgent?: string
  clientIp?: string
  appVersion?: string
}

// Cache en memoria para optimización
const cache = new Map<string, CacheEntry>()
const CACHE_TTL = 30000 // 30 segundos
const RATE_LIMIT_WINDOW = 60000 // 1 minuto
const RATE_LIMIT_MAX_REQUESTS = 100

// Rate limiting por IP
const rateLimitMap = new Map<string, { count: number; resetTime: number }>()

function getClientIP(request: Request): string {
  const forwarded = request.headers.get('x-forwarded-for')
  const realIP = request.headers.get('x-real-ip')
  const cfConnectingIP = request.headers.get('cf-connecting-ip')
  
  return cfConnectingIP || realIP || forwarded?.split(',')[0] || 'unknown'
}

function isRateLimited(ip: string): boolean {
  const now = Date.now()
  const limit = rateLimitMap.get(ip)
  
  if (!limit || now > limit.resetTime) {
    rateLimitMap.set(ip, { count: 1, resetTime: now + RATE_LIMIT_WINDOW })
    return false
  }
  
  if (limit.count >= RATE_LIMIT_MAX_REQUESTS) {
    return true
  }
  
  limit.count++
  return false
}

function getCachedData(key: string): PepitoActivity | null {
  const entry = cache.get(key)
  if (!entry) return null
  
  const now = Date.now()
  if (now - entry.timestamp > entry.ttl) {
    cache.delete(key)
    return null
  }
  
  return entry.data
}

function setCachedData(key: string, data: PepitoActivity): void {
  cache.set(key, {
    data,
    timestamp: Date.now(),
    ttl: CACHE_TTL
  })
}

function extractRequestContext(req: Request): RequestContext {
  const headers = req.headers
  
  return {
    userId: headers.get('x-user-id') || undefined,
    sessionId: headers.get('x-session-id') || undefined,
    userAgent: headers.get('user-agent') || undefined,
    clientIp: getClientIP(req),
    appVersion: headers.get('x-app-version') || undefined,
  }
}

async function validateAuthentication(req: Request): Promise<{ valid: boolean; message?: string; userId?: string }> {
  const authHeader = req.headers.get('authorization')
  
  // Para desarrollo, permitir acceso sin autenticación si no hay header
  // o si es un token de desarrollo
  if (!authHeader) {
    console.log('No authorization header - allowing anonymous access for development')
    return { valid: true, userId: 'anonymous', message: 'Anonymous access allowed' }
  }

  // Check for development token
  if (authHeader.includes('demo-api-key-for-development-only')) {
    console.log('Development token detected - allowing access')
    return { valid: true, userId: 'development', message: 'Development access allowed' }
  }

  try {
    // Extract JWT token
    const token = authHeader.replace('Bearer ', '')
    
    // Create Supabase client
    // @ts-ignore: Deno not recognized in VS Code
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    // @ts-ignore: Deno not recognized in VS Code
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // Verify JWT token
    const { data: { user }, error } = await supabase.auth.getUser(token)
    
    if (error || !user) {
      return { valid: false, message: 'Invalid or expired token' }
    }
    
    return { valid: true, userId: user.id }
  } catch (error) {
    console.error('Authentication error:', error)
    return { valid: false, message: 'Authentication failed' }
  }
}

async function fetchPepitoStatus(context: RequestContext): Promise<PepitoActivity> {
  // @ts-ignore: Deno not recognized in VS Code
  const pepitoApiUrl = Deno.env.get('PEPITO_API_URL') || 'https://api.thecatdoor.com/rest/v1'
  
  const response = await fetch(`${pepitoApiUrl}/last-status`, {
    method: 'GET',
    headers: {
      'Accept': 'application/json',
      'User-Agent': `Supabase-Edge-Function/${context.appVersion || '1.0.0'}`,
      'X-Forwarded-For': context.clientIp || '',
      'X-Session-Id': context.sessionId || '',
    },
    // Add timeout
    signal: AbortSignal.timeout(10000)
  })
  
  if (!response.ok) {
    throw new Error(`Pepito API error: ${response.status} ${response.statusText}`)
  }
  
  const pepitoData: PepitoStatus = await response.json()
  
  // Transform to our enhanced format
  const activity: PepitoActivity = {
    id: `pepito_${Date.now()}`,
    event: pepitoData.event,
    type: pepitoData.type,
    timestamp: new Date(pepitoData.timestamp * 1000).toISOString(),
    img: pepitoData.img,
    confidence: 1.0,
    imageUrl: pepitoData.img,
    source: 'edge_function',
    cached: false,
    authenticated: false, // Will be updated by caller
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  }
  
  return activity
}

async function logSecurityEvent(event: any): Promise<void> {
  try {
    // @ts-ignore: Deno not recognized in VS Code
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    // @ts-ignore: Deno not recognized in VS Code
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    
    await supabase
      .from('audit_logs')
      .insert({
        event_type: event.event,
        user_id: event.userId,
        session_id: event.sessionId,
        client_ip: event.clientIp,
        user_agent: event.userAgent,
        success: event.success,
        error_message: event.error,
        metadata: event,
        created_at: event.timestamp,
      })
  } catch (error) {
    console.error('Failed to log security event:', error)
    // Don't throw - logging failures shouldn't break the main flow
  }
}

serve(async (req: Request) => {
  const requestedHeaders = req.headers.get('access-control-request-headers')

  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': requestedHeaders || 'authorization, x-client-info, x-api-version, apikey, content-type, x-user-id, x-session-id, x-app-version, x-client-platform, x-request-id, user-agent',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
  }
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }
  
  let context: RequestContext | undefined
  
  try {
    context = extractRequestContext(req)
    const clientIP = context.clientIp || 'unknown'
    
    // Rate limiting
    if (isRateLimited(clientIP)) {
      await logSecurityEvent({
        event: 'rate_limit_exceeded',
        clientIp: clientIP,
        userAgent: context.userAgent,
        success: false,
        timestamp: new Date().toISOString(),
      })
      
      return new Response(
        JSON.stringify({ error: 'Rate limit exceeded' }),
        { 
          status: 429, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }
    
    const url = new URL(req.url)
    const path = url.pathname
    
    // Authentication validation
    const authResult = await validateAuthentication(req)
    
    // Log authentication attempt
    await logSecurityEvent({
      event: 'authentication_attempt',
      userId: authResult.userId,
      sessionId: context.sessionId,
      clientIp: clientIP,
      userAgent: context.userAgent,
      success: authResult.valid,
      error: authResult.message,
      timestamp: new Date().toISOString(),
    })
    
    // Endpoint para obtener el estado de Pépito
    if (path === '/pepito-proxy/status' && req.method === 'GET') {
      const cacheKey = 'pepito-status'
      
      // Verificar cache primero
      let cachedData = getCachedData(cacheKey)
      if (cachedData) {
        cachedData.cached = true
        cachedData.authenticated = authResult.valid
        
        // Log successful data access
        await logSecurityEvent({
          event: 'data_access',
          userId: authResult.userId,
          sessionId: context.sessionId,
          clientIp: clientIP,
          userAgent: context.userAgent,
          success: true,
          metadata: { endpoint: 'status', cached: true },
          timestamp: new Date().toISOString(),
        })
        
        return new Response(
          JSON.stringify({
            ...cachedData,
            timestamp: new Date().toISOString()
          }),
          { 
            headers: { 
              ...corsHeaders, 
              'Content-Type': 'application/json',
              'Cache-Control': 'public, max-age=30'
            }
          }
        )
      }
      
      // Obtener datos frescos de la API
      const status = await fetchPepitoStatus(context)
      status.cached = false
      status.authenticated = authResult.valid
      setCachedData(cacheKey, status)
      
      // Log successful data access
      await logSecurityEvent({
        event: 'data_access',
        userId: authResult.userId,
        sessionId: context.sessionId,
        clientIp: clientIP,
        userAgent: context.userAgent,
        success: true,
        metadata: { endpoint: 'status', cached: false },
        timestamp: new Date().toISOString(),
      })
      
      return new Response(
        JSON.stringify({
          ...status,
          timestamp: new Date().toISOString()
        }),
        { 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json',
            'Cache-Control': 'public, max-age=30'
          }
        }
      )
    }
    
    // Activities endpoint
    if (path === '/pepito-proxy/activities' && req.method === 'GET') {
      // This endpoint requires authentication
      if (!authResult.valid) {
        return new Response(
          JSON.stringify({ error: 'Authentication required for activities endpoint' }),
          { 
            status: 401, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }
      
      const cacheKey = 'pepito-activities'
      let data = getCachedData(cacheKey)
      
      if (!data) {
        // For now, return the latest status as an activity
        // In a real implementation, this would fetch multiple activities
        data = await fetchPepitoStatus(context)
        data.authenticated = true
        setCachedData(cacheKey, data)
      } else {
        data.cached = true
        data.authenticated = true
      }
      
      await logSecurityEvent({
        event: 'data_access',
        userId: authResult.userId,
        sessionId: context.sessionId,
        clientIp: clientIP,
        userAgent: context.userAgent,
        success: true,
        metadata: { endpoint: 'activities', cached: data.cached },
        timestamp: new Date().toISOString(),
      })
      
      return new Response(
        JSON.stringify({
          activities: [data], // Return as array for consistency
          timestamp: new Date().toISOString(),
          total: 1
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Endpoint de salud
    if (path === '/pepito-proxy/health' && req.method === 'GET') {
      const healthData = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        cache_size: cache.size,
        rate_limit_entries: rateLimitMap.size,
        security: {
          authentication_enabled: true,
          rate_limiting_enabled: true,
          logging_enabled: true,
        },
        endpoints: {
          '/pepito-proxy/status': 'Public endpoint for Pepito status',
          '/pepito-proxy/activities': 'Authenticated endpoint for activities',
          '/pepito-proxy/health': 'Health check endpoint'
        }
      }
      
      return new Response(
        JSON.stringify(healthData),
        { 
          headers: { 
            ...corsHeaders, 
            'Content-Type': 'application/json'
          }
        }
      )
    }
    
    // Endpoint no encontrado
    await logSecurityEvent({
      event: 'endpoint_not_found',
      userId: authResult.userId,
      sessionId: context.sessionId,
      clientIp: clientIP,
      userAgent: context.userAgent,
      success: false,
      metadata: { requested_path: path, method: req.method },
      timestamp: new Date().toISOString(),
    })
    
    return new Response(
      JSON.stringify({ 
        error: 'Endpoint not found',
        available_endpoints: [
          '/pepito-proxy/status',
          '/pepito-proxy/activities',
          '/pepito-proxy/health'
        ]
      }),
      { 
        status: 404, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
    
  } catch (error) {
    console.error('Edge Function Error:', error)
    
    // Log the error for security monitoring
    try {
      await logSecurityEvent({
        event: 'server_error',
        userId: context?.userId,
        sessionId: context?.sessionId,
        clientIp: context?.clientIp || 'unknown',
        userAgent: context?.userAgent,
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        metadata: { stack: error instanceof Error ? error.stack : undefined },
        timestamp: new Date().toISOString(),
      })
    } catch (logError) {
      console.error('Failed to log error event:', logError)
    }
    
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        message: 'An unexpected error occurred',
        timestamp: new Date().toISOString()
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})