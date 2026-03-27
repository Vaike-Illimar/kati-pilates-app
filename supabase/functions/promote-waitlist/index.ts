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
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const { class_instance_id } = await req.json()

    if (!class_instance_id) {
      return new Response(JSON.stringify({ error: 'class_instance_id is required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Fetch the class instance to get max_participants
    const { data: classInstance, error: classError } = await supabaseAdmin
      .from('class_instances')
      .select('max_participants, date, start_time')
      .eq('id', class_instance_id)
      .single()

    if (classError || !classInstance) {
      return new Response(JSON.stringify({ error: 'Class instance not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Count current confirmed bookings
    const { count: confirmedCount } = await supabaseAdmin
      .from('bookings')
      .select('*', { count: 'exact', head: true })
      .eq('class_instance_id', class_instance_id)
      .eq('status', 'confirmed')

    const availableSpots = classInstance.max_participants - (confirmedCount ?? 0)

    if (availableSpots <= 0) {
      return new Response(
        JSON.stringify({ promoted: false, reason: 'No available spots' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    // Get the next person on the waitlist (lowest waitlist_position)
    const { data: nextWaitlisted, error: waitlistError } = await supabaseAdmin
      .from('bookings')
      .select('*')
      .eq('class_instance_id', class_instance_id)
      .eq('status', 'waitlisted')
      .order('waitlist_position', { ascending: true })
      .order('booked_at', { ascending: true })
      .limit(1)
      .maybeSingle()

    if (waitlistError || !nextWaitlisted) {
      return new Response(
        JSON.stringify({ promoted: false, reason: 'No one on waitlist' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    // Verify the user still has an active card with remaining sessions
    const { data: card } = await supabaseAdmin
      .from('session_cards')
      .select('id, remaining_sessions, status, valid_until')
      .eq('id', nextWaitlisted.card_id)
      .single()

    const now = new Date()
    const cardValid = card &&
      card.status === 'active' &&
      card.remaining_sessions > 0 &&
      new Date(card.valid_until) > now

    if (!cardValid) {
      // Skip this user — they can no longer attend
      await supabaseAdmin
        .from('bookings')
        .update({ status: 'cancelled', cancelled_at: now.toISOString() })
        .eq('id', nextWaitlisted.id)

      // Send notification that they were skipped
      supabaseAdmin
        .from('user_notifications')
        .insert({
          user_id: nextWaitlisted.user_id,
          type: 'waitlist_skipped',
          title: 'Koht läks mööda',
          body: 'Koht vabanesid, kuid teie kaart ei ole enam kehtiv.',
          data: { class_instance_id },
        })
        .then(() => {})
        .catch(() => {})

      // Recursively try the next person
      return supabaseAdmin.functions.invoke('promote-waitlist', {
        body: { class_instance_id },
      }).then((result) => {
        return new Response(
          JSON.stringify({ promoted: false, skipped: nextWaitlisted.user_id }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
        )
      })
    }

    // Promote: deduct session, update booking to confirmed
    const { error: cardUpdateError } = await supabaseAdmin
      .from('session_cards')
      .update({
        remaining_sessions: card.remaining_sessions - 1,
        updated_at: now.toISOString(),
      })
      .eq('id', card.id)

    if (cardUpdateError) {
      return new Response(JSON.stringify({ error: 'Failed to deduct session for promotion' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { error: bookingUpdateError } = await supabaseAdmin
      .from('bookings')
      .update({
        status: 'confirmed',
        waitlist_position: null,
        session_deducted: true,
      })
      .eq('id', nextWaitlisted.id)

    if (bookingUpdateError) {
      // Refund the session
      await supabaseAdmin
        .from('session_cards')
        .update({
          remaining_sessions: card.remaining_sessions,
          updated_at: now.toISOString(),
        })
        .eq('id', card.id)

      return new Response(JSON.stringify({ error: 'Failed to promote waitlist booking' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Update remaining waitlist positions
    const { data: remainingWaitlist } = await supabaseAdmin
      .from('bookings')
      .select('id, waitlist_position')
      .eq('class_instance_id', class_instance_id)
      .eq('status', 'waitlisted')
      .order('waitlist_position', { ascending: true })

    if (remainingWaitlist && remainingWaitlist.length > 0) {
      for (let i = 0; i < remainingWaitlist.length; i++) {
        await supabaseAdmin
          .from('bookings')
          .update({ waitlist_position: i + 1 })
          .eq('id', remainingWaitlist[i].id)
      }
    }

    // Notify the promoted user
    supabaseAdmin
      .from('user_notifications')
      .insert({
        user_id: nextWaitlisted.user_id,
        type: 'waitlist_promoted',
        title: 'Koht vabanenud!',
        body: 'Teile on eraldatud koht. Teie broneering on kinnitatud ja sessioon on maha arvatud.',
        data: { booking_id: nextWaitlisted.id, class_instance_id },
      })
      .then(() => {})
      .catch(() => {})

    return new Response(
      JSON.stringify({
        promoted: true,
        user_id: nextWaitlisted.user_id,
        booking_id: nextWaitlisted.id,
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
