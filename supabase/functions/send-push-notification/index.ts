// @ts-nocheck: This file runs in the Deno runtime (Supabase Edge Functions).
// Deno globals (Deno.env, etc.) and bare specifiers are resolved at runtime.
// @ts-ignore: Deno std module resolved at runtime
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// @ts-ignore: npm module resolved at runtime via esm.sh
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface NotificationPayload {
  type: string
  title: string
  body: string
  data?: Record<string, string>
  token?: string
  tokens?: string[]
  userIds?: string[]
  role?: 'client' | 'technician' | 'all'
  topic?: string
  deepLink?: string
  priority?: 'high' | 'normal'
  sound?: string
  badge?: number
}

interface SendResult {
  success: boolean
  successCount: number
  failureCount: number
  errors?: string[]
  messageIds?: string[]
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed. Use POST.' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const payload: NotificationPayload = await req.json()

    const validationError = validatePayload(payload)
    if (validationError) {
      return new Response(
        JSON.stringify({ error: validationError }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    let tokens: string[] = []

    if (payload.token) {
      tokens = [payload.token]
    } else if (payload.tokens && payload.tokens.length > 0) {
      tokens = payload.tokens
    } else if (payload.userIds && payload.userIds.length > 0) {
      tokens = await resolveUserTokens(supabaseClient, payload.userIds)
    } else if (payload.role) {
      tokens = await resolveUserTokensByRole(supabaseClient, payload.role)
    } else if (payload.topic) {
      return await sendToTopic(payload)
    } else {
      return new Response(
        JSON.stringify({ error: 'No targeting specified. Provide token, tokens, userIds, role, or topic.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: 'No valid tokens found', sent: 0, failed: 0 }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const result = await sendToTokens(tokens, payload)

    return new Response(
      JSON.stringify({
        success: result.failureCount === 0,
        sent: result.successCount,
        failed: result.failureCount,
        errors: result.errors,
        messageIds: result.messageIds
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error: unknown) {
    console.error('Error in send-push-notification:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error instanceof Error ? error.message : String(error) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

function validatePayload(payload: NotificationPayload): string | null {
  if (!payload.type || !payload.title || !payload.body) {
    return 'Missing required fields: type, title, body'
  }

  const validTypes = [
    'technician_accepted',
    'technician_arrived',
    'technician_working',
    'payment_confirmed',
    'order_completed',
    'new_nearby_order',
    'rating_reminder',
    'customer_cancelled',
    'payment_received'
  ]

  if (!validTypes.includes(payload.type)) {
    return `Invalid notification type. Must be one of: ${validTypes.join(', ')}`
  }

  return null
}

async function resolveUserTokens(supabaseClient: ReturnType<typeof createClient>, userIds: string[]): Promise<string[]> {
  const { data: profiles, error } = await supabaseClient
    .from('profiles')
    .select('fcm_token')
    .in('id', userIds)
    .not('fcm_token', 'is', null)

  if (error) {
    console.error('Error resolving user tokens:', error)
    throw new Error('Failed to resolve user tokens')
  }

  return profiles.map((p: { fcm_token: string | null }) => p.fcm_token).filter(Boolean) as string[]
}

async function resolveUserTokensByRole(supabaseClient: ReturnType<typeof createClient>, role: 'client' | 'technician' | 'all'): Promise<string[]> {
  let query = supabaseClient
    .from('profiles')
    .select('fcm_token')
    .not('fcm_token', 'is', null)

  if (role !== 'all') {
    query = query.eq('role', role)
  }

  const { data: profiles, error } = await query

  if (error) {
    console.error('Error resolving tokens by role:', error)
    throw new Error('Failed to resolve tokens by role')
  }

  return profiles.map((p: { fcm_token: string | null }) => p.fcm_token).filter(Boolean) as string[]
}

async function sendToTokens(tokens: string[], payload: NotificationPayload): Promise<SendResult> {
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${Deno.env.get('FIREBASE_PROJECT_ID')}/messages:send`
  const accessToken = await getAccessToken()

  const messages = tokens.map(token => buildMessage(token, payload))

  const batchSize = 500
  let successCount = 0
  let failureCount = 0
  const errors: string[] = []
  const messageIds: string[] = []

  for (let i = 0; i < messages.length; i += batchSize) {
    const batch = messages.slice(i, i + batchSize)
    const responses = await Promise.allSettled(
      batch.map(msg => sendWithRetry(fcmUrl, accessToken, msg, 3))
    )

    responses.forEach((response, index) => {
      if (response.status === 'fulfilled') {
        successCount++
        if (response.value.messageId) {
          messageIds.push(response.value.messageId)
        }
      } else {
        failureCount++
        const errorMsg = `Token ${tokens[i + index]}: ${response.reason?.message || 'Unknown error'}`
        errors.push(errorMsg)
        console.error('FCM send failed:', errorMsg)
      }
    })
  }

  return { success: failureCount === 0, successCount, failureCount, errors, messageIds }
}

async function sendWithRetry(url: string, accessToken: string, message: object, maxRetries: number): Promise<{ messageId?: string }> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(message),
      })

      const data = await response.json()

      if (response.ok) {
        return { messageId: data.name }
      }

      if (response.status === 429 || response.status >= 500) {
        const delay = Math.pow(2, attempt) * 1000
        await new Promise(resolve => setTimeout(resolve, delay))
        continue
      }

      throw new Error(data.error?.message || `FCM error: ${response.status}`)
    } catch (error) {
      if (attempt === maxRetries - 1) throw error
      const delay = Math.pow(2, attempt) * 1000
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }
  throw new Error('Max retries exceeded')
}

function buildMessage(token: string, payload: NotificationPayload): object {
  const channelId = getChannelId(payload.type)
  const priority = payload.priority || 'high'
  const sound = payload.sound || 'default'
  const badge = payload.badge ?? 1

  const message: Record<string, unknown> = {
    message: {
      token,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: {
        ...payload.data,
        type: payload.type,
        ...(payload.deepLink ? { deep_link: payload.deepLink } : {}),
      },
      android: {
        priority: priority,
        notification: {
          channelId,
          priority: priority,
          defaultSound: true,
          defaultVibrateTimings: true,
          sound,
        },
      },
      apns: {
        payload: {
          aps: {
            sound,
            badge,
            'content-available': 1,
            'mutable-content': 1,
          },
        },
      },
      webpush: {
        headers: {
          Urgency: priority === 'high' ? 'high' : 'normal',
        },
        notification: {
          title: payload.title,
          body: payload.body,
          icon: '/icon-192.png',
          badge: '/badge-72.png',
          data: {
            ...payload.data,
            type: payload.type,
            ...(payload.deepLink ? { deep_link: payload.deepLink } : {}),
          },
        },
      },
    },
  }

  return message
}

async function sendToTopic(payload: NotificationPayload): Promise<Response> {
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${Deno.env.get('FIREBASE_PROJECT_ID')}/messages:send`
  const accessToken = await getAccessToken()

  const channelId = getChannelId(payload.type)
  const priority = payload.priority || 'high'
  const sound = payload.sound || 'default'
  const badge = payload.badge ?? 1

  const message = {
    message: {
      topic: payload.topic,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: {
        ...payload.data,
        type: payload.type,
        ...(payload.deepLink ? { deep_link: payload.deepLink } : {}),
      },
      android: {
        priority: priority,
        notification: {
          channelId,
          priority: priority,
          defaultSound: true,
          defaultVibrateTimings: true,
          sound,
        },
      },
      apns: {
        payload: {
          aps: {
            sound,
            badge,
            'content-available': 1,
            'mutable-content': 1,
          },
        },
      },
      webpush: {
        headers: {
          Urgency: priority === 'high' ? 'high' : 'normal',
        },
      },
    },
  }

  const response = await fetch(fcmUrl, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(message),
  })

  const data = await response.json()

  if (!response.ok) {
    throw new Error(`FCM topic send failed: ${data.error?.message || await response.text()}`)
  }

  return new Response(
    JSON.stringify({ success: true, sent: 1, failed: 0, messageId: data.name }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}

async function getAccessToken(): Promise<string> {
  const clientEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL');
  const privateKey = Deno.env.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n');
  const projectId = Deno.env.get('FIREBASE_PROJECT_ID');

  if (!clientEmail || !privateKey || !projectId) {
    throw new Error('Missing Firebase service account configuration');
  }

  const serviceAccount = { client_email: clientEmail, private_key: privateKey, project_id: projectId };

  const jwt = await createJWT(serviceAccount);
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  })

  const data = await response.json()
  if (!response.ok) {
    throw new Error(`Failed to get access token: ${data.error_description || data.error}`)
  }

  return data.access_token
}

async function createJWT(serviceAccount: { client_email: string; private_key: string; project_id: string }): Promise<string> {
  const header = { alg: 'RS256', typ: 'JWT' }
  const now = Math.floor(Date.now() / 1000)
  const payload = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }

  const encoder = new TextEncoder()
  const headerB64 = base64UrlEncode(JSON.stringify(header))
  const payloadB64 = base64UrlEncode(JSON.stringify(payload))
  const unsignedToken = `${headerB64}.${payloadB64}`

  const privateKeyPem = serviceAccount.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\n/g, '')
    .trim()

  const binaryKey = base64Decode(privateKeyPem)
  const key = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  const signature = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, encoder.encode(unsignedToken))
  const signatureB64 = base64UrlEncode(signature)

  return `${unsignedToken}.${signatureB64}`
}

function base64UrlEncode(input: string | ArrayBuffer): string {
  let binary: string
  if (typeof input === 'string') {
    binary = btoa(input)
  } else {
    const bytes = new Uint8Array(input)
    binary = String.fromCharCode(...bytes)
  }
  return btoa(binary).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
}

function base64Decode(input: string): ArrayBuffer {
  const binary = atob(input)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return bytes.buffer
}

function getChannelId(type: string): string {
  const criticalTypes = [
    'technician_accepted',
    'technician_arrived',
    'technician_working',
    'payment_confirmed',
    'payment_received',
    'new_nearby_order',
  ]
  return criticalTypes.includes(type) ? 'high_importance_channel' : 'default_channel'
}