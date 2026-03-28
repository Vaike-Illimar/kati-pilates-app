import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const WARNING_DAYS = 14

/**
 * Daily cron function: mark expired cards, send 14-day warning notifications.
 * Schedule: daily at 06:00 UTC.
 */
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const now = new Date()
    const today = now.toISOString().split('T')[0]

    // --- 1. Mark expired cards ---
    const { data: expiredCards, error: expiredError } = await supabaseAdmin
      .from('session_cards')
      .update({
        status: 'expired',
        updated_at: now.toISOString(),
      })
      .in('status', ['active', 'paused'])
      .lt('valid_until', today)
      .select('id, user_id, remaining_sessions')

    if (expiredError) {
      console.error('Error marking expired cards:', expiredError)
    }

    let expiredCount = expiredCards?.length ?? 0

    // Notify users whose cards just expired
    if (expiredCards && expiredCards.length > 0) {
      const expiryNotifications = expiredCards.map((card) => ({
        user_id: card.user_id,
        type: 'card_expired',
        title: 'Teie kaart on aegunud',
        body: `Teie sessioonkaart on aegunud. ${card.remaining_sessions > 0 ? `Teil oli jäänud ${card.remaining_sessions} sessiooni.` : ''} Ostke uus kaart, et jätkata tundides osalemist.`,
        data: { card_id: card.id },
      }))

      await supabaseAdmin.from('user_notifications').insert(expiryNotifications)
    }

    // --- 2. Mark depleted cards (no sessions remaining, still active) ---
    const { data: depletedCards, error: depletedError } = await supabaseAdmin
      .from('session_cards')
      .update({
        status: 'depleted',
        updated_at: now.toISOString(),
      })
      .eq('status', 'active')
      .eq('remaining_sessions', 0)
      .gte('valid_until', today)
      .select('id, user_id')

    if (depletedError) {
      console.error('Error marking depleted cards:', depletedError)
    }

    const depletedCount = depletedCards?.length ?? 0

    // --- 3. Send 14-day expiry warnings ---
    const warningDate = new Date(now)
    warningDate.setDate(now.getDate() + WARNING_DAYS)
    const warningDateStr = warningDate.toISOString().split('T')[0]
    // Only send warnings for cards expiring in exactly WARNING_DAYS days (to avoid duplicate warnings)
    const warningDayStart = `${warningDateStr}T00:00:00.000Z`
    const warningDayEnd = `${warningDateStr}T23:59:59.999Z`

    const { data: expiringCards, error: expiringError } = await supabaseAdmin
      .from('session_cards')
      .select('id, user_id, valid_until, remaining_sessions')
      .eq('status', 'active')
      .gte('valid_until', warningDayStart)
      .lte('valid_until', warningDayEnd)

    if (expiringError) {
      console.error('Error fetching expiring cards:', expiringError)
    }

    let warningCount = 0
    if (expiringCards && expiringCards.length > 0) {
      const warningNotifications = expiringCards.map((card) => ({
        user_id: card.user_id,
        type: 'card_expiry_warning',
        title: 'Teie kaart aegub ${WARNING_DAYS} päeva pärast',
        body: `Teie sessioonkaart aegub ${WARNING_DAYS} päeva pärast (${card.valid_until.split('T')[0]}). Teil on jäänud ${card.remaining_sessions} sessiooni. Uuendage oma kaarti aegsasti.`,
        data: { card_id: card.id, valid_until: card.valid_until },
      }))

      await supabaseAdmin.from('user_notifications').insert(warningNotifications)
      warningCount = expiringCards.length
    }

    return new Response(
      JSON.stringify({
        success: true,
        date: today,
        expired_cards_marked: expiredCount,
        depleted_cards_marked: depletedCount,
        expiry_warnings_sent: warningCount,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
