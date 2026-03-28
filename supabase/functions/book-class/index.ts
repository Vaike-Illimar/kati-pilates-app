import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client with service role key for admin operations
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Get the requesting user from the JWT
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

    const { class_instance_id, card_id } = await req.json()

    if (!class_instance_id || !card_id) {
      return new Response(
        JSON.stringify({ error: 'class_instance_id and card_id are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    // 1. Validate the session card is active and belongs to the user
    const { data: card, error: cardError } = await supabaseAdmin
      .from('session_cards')
      .select('*')
      .eq('id', card_id)
      .eq('user_id', user.id)
      .single()

    if (cardError || !card) {
      return new Response(JSON.stringify({ error: 'Session card not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (card.status !== 'active') {
      return new Response(
        JSON.stringify({ error: `Session card is ${card.status}, not active` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    if (card.remaining_sessions <= 0) {
      return new Response(
        JSON.stringify({ error: 'No remaining sessions on this card' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    const now = new Date()
    if (new Date(card.valid_until) < now) {
      return new Response(JSON.stringify({ error: 'Session card has expired' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 2. Fetch the class instance
    const { data: classInstance, error: classError } = await supabaseAdmin
      .from('class_instances')
      .select('*')
      .eq('id', class_instance_id)
      .single()

    if (classError || !classInstance) {
      return new Response(JSON.stringify({ error: 'Class instance not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (classInstance.is_cancelled) {
      return new Response(JSON.stringify({ error: 'This class has been cancelled' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Prevent booking past classes
    const classDateTime = new Date(`${classInstance.date}T${classInstance.start_time}`)
    if (classDateTime < now) {
      return new Response(JSON.stringify({ error: 'Cannot book a past class' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 3. Check if the user already has a booking for this class
    const { data: existingBooking } = await supabaseAdmin
      .from('bookings')
      .select('id, status')
      .eq('user_id', user.id)
      .eq('class_instance_id', class_instance_id)
      .in('status', ['confirmed', 'waitlisted'])
      .maybeSingle()

    if (existingBooking) {
      return new Response(
        JSON.stringify({ error: 'You already have a booking for this class' }),
        { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    // 4. Count confirmed bookings to check capacity
    const { count: confirmedCount } = await supabaseAdmin
      .from('bookings')
      .select('*', { count: 'exact', head: true })
      .eq('class_instance_id', class_instance_id)
      .eq('status', 'confirmed')

    const isFull = (confirmedCount ?? 0) >= classInstance.max_participants

    // 5. Count waitlist position if full
    let waitlistPosition: number | null = null
    if (isFull) {
      const { count: waitlistCount } = await supabaseAdmin
        .from('bookings')
        .select('*', { count: 'exact', head: true })
        .eq('class_instance_id', class_instance_id)
        .eq('status', 'waitlisted')

      waitlistPosition = (waitlistCount ?? 0) + 1
    }

    // 6. Deduct session from card (only for confirmed bookings, not waitlisted)
    if (!isFull) {
      const { error: updateError } = await supabaseAdmin
        .from('session_cards')
        .update({
          remaining_sessions: card.remaining_sessions - 1,
          updated_at: new Date().toISOString(),
        })
        .eq('id', card_id)

      if (updateError) {
        return new Response(JSON.stringify({ error: 'Failed to deduct session' }), {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }

    // 7. Create the booking
    const { data: booking, error: bookingError } = await supabaseAdmin
      .from('bookings')
      .insert({
        user_id: user.id,
        class_instance_id: class_instance_id,
        card_id: card_id,
        status: isFull ? 'waitlisted' : 'confirmed',
        waitlist_position: waitlistPosition,
        session_deducted: !isFull,
        booked_at: new Date().toISOString(),
      })
      .select()
      .single()

    if (bookingError) {
      // Refund the session if booking failed
      if (!isFull) {
        await supabaseAdmin
          .from('session_cards')
          .update({
            remaining_sessions: card.remaining_sessions,
            updated_at: new Date().toISOString(),
          })
          .eq('id', card_id)
      }

      return new Response(JSON.stringify({ error: 'Failed to create booking' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 8. Send notification to user (fire and forget)
    const notificationTitle = isFull ? 'Olete ootenimekirjas' : 'Tund broneeritud!'
    const notificationBody = isFull
      ? `Olete ootenimekirjas kohal #${waitlistPosition}.`
      : 'Teie tund on edukalt broneeritud. Üks sessioon on teie kaardilt maha arvatud.'

    supabaseAdmin
      .from('user_notifications')
      .insert({
        user_id: user.id,
        type: isFull ? 'waitlist_joined' : 'booking_confirmed',
        title: notificationTitle,
        body: notificationBody,
        data: { booking_id: booking.id, class_instance_id },
      })
      .then(() => {})
      .catch(() => {})

    return new Response(JSON.stringify(booking), {
      status: 201,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
