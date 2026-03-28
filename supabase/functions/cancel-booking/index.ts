import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Late cancel window: 2 hours before class start
const LATE_CANCEL_HOURS = 2

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'No authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabaseUser = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } },
    )

    const { data: { user }, error: userError } = await supabaseUser.auth.getUser()
    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { booking_id, cancel_type } = await req.json()

    if (!booking_id) {
      return new Response(JSON.stringify({ error: 'booking_id is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Fetch the booking with class instance details
    const { data: booking, error: bookingError } = await supabaseAdmin
      .from('bookings')
      .select('*, class_instances(*)')
      .eq('id', booking_id)
      .single()

    if (bookingError || !booking) {
      return new Response(JSON.stringify({ error: 'Booking not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Ensure the user owns this booking (or is admin)
    if (booking.user_id !== user.id) {
      // Check if admin
      const { data: profile } = await supabaseAdmin
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single()

      if (!profile || !['admin', 'instructor'].includes(profile.role)) {
        return new Response(JSON.stringify({ error: 'Unauthorized to cancel this booking' }), {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }

    if (!['confirmed', 'waitlisted'].includes(booking.status)) {
      return new Response(
        JSON.stringify({ error: `Booking is already ${booking.status}` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    const classInstance = booking.class_instances
    const classDateTime = new Date(`${classInstance.date}T${classInstance.start_time}`)
    const now = new Date()
    const hoursUntilClass = (classDateTime.getTime() - now.getTime()) / (1000 * 60 * 60)

    // Determine cancel type if not provided
    let effectiveCancelType = cancel_type
    if (!effectiveCancelType) {
      effectiveCancelType = hoursUntilClass < LATE_CANCEL_HOURS ? 'late' : 'normal'
    }

    const isLateCancellation = effectiveCancelType === 'late'
    const isWaitlisted = booking.status === 'waitlisted'

    // Session refund logic:
    // - Normal cancel + confirmed + session was deducted → refund session
    // - Late cancel + confirmed + session was deducted → NO refund (penalty)
    // - Waitlisted → session was not deducted, nothing to refund
    const shouldRefundSession = booking.session_deducted && !isLateCancellation && !isWaitlisted

    // Update booking status
    const { error: updateError } = await supabaseAdmin
      .from('bookings')
      .update({
        status: 'cancelled',
        cancel_type: effectiveCancelType,
        cancelled_at: now.toISOString(),
      })
      .eq('id', booking_id)

    if (updateError) {
      return new Response(JSON.stringify({ error: 'Failed to cancel booking' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Refund session if applicable
    if (shouldRefundSession && booking.card_id) {
      const { data: card } = await supabaseAdmin
        .from('session_cards')
        .select('remaining_sessions')
        .eq('id', booking.card_id)
        .single()

      if (card) {
        await supabaseAdmin
          .from('session_cards')
          .update({
            remaining_sessions: card.remaining_sessions + 1,
            updated_at: now.toISOString(),
          })
          .eq('id', booking.card_id)
      }
    }

    // Trigger waitlist promotion for confirmed booking cancellations
    if (!isWaitlisted) {
      // Call promote-waitlist function (fire and forget)
      supabaseAdmin.functions
        .invoke('promote-waitlist', {
          body: { class_instance_id: booking.class_instance_id },
        })
        .then(() => {})
        .catch(() => {})
    }

    // Send notification to user
    const notificationBody = isLateCancellation
      ? 'Teie broneering on tühistatud. Kuna tühistamine toimus vähem kui 2 tundi enne tundi, sessiooni ei tagastata.'
      : 'Teie broneering on edukalt tühistatud.'

    supabaseAdmin
      .from('user_notifications')
      .insert({
        user_id: booking.user_id,
        type: 'booking_cancelled',
        title: 'Broneering tühistatud',
        body: notificationBody,
        data: { booking_id, cancel_type: effectiveCancelType, refunded: shouldRefundSession },
      })
      .then(() => {})
      .catch(() => {})

    return new Response(
      JSON.stringify({
        success: true,
        cancel_type: effectiveCancelType,
        session_refunded: shouldRefundSession,
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
