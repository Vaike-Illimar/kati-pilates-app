import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Weekly cron function: auto-book fixed group members into next week's class instances.
 * Runs after generate-instances (e.g., Monday 01:00 UTC).
 *
 * Fixed group members are automatically booked — sessions are deducted from their cards.
 * If a member has no active card, they are skipped and notified.
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

    let weekOffset = 1
    try {
      const body = await req.json()
      if (body.week_offset !== undefined) {
        weekOffset = Number(body.week_offset)
      }
    } catch {
      // Use default
    }

    // Calculate start of target week
    const now = new Date()
    const currentDay = now.getDay()
    const daysUntilMonday = currentDay === 0 ? 1 : 8 - currentDay
    const nextMonday = new Date(now)
    nextMonday.setDate(now.getDate() + daysUntilMonday + (weekOffset - 1) * 7)
    nextMonday.setHours(0, 0, 0, 0)

    const nextSunday = new Date(nextMonday)
    nextSunday.setDate(nextMonday.getDate() + 6)

    const weekStart = nextMonday.toISOString().split('T')[0]
    const weekEnd = nextSunday.toISOString().split('T')[0]

    // Fetch all active fixed groups with their class definition
    const { data: groups, error: groupsError } = await supabaseAdmin
      .from('fixed_groups')
      .select('*, fixed_group_members(*)')
      .eq('is_active', true)

    if (groupsError) {
      return new Response(JSON.stringify({ error: 'Failed to fetch fixed groups' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (!groups || groups.length === 0) {
      return new Response(
        JSON.stringify({ booked: 0, message: 'No active fixed groups' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    let totalBooked = 0
    let totalSkipped = 0
    const results: Record<string, unknown>[] = []

    for (const group of groups) {
      const members = group.fixed_group_members ?? []
      if (members.length === 0) continue

      // Find the class instance for this group's class definition in the target week
      const { data: instances, error: instanceError } = await supabaseAdmin
        .from('class_instances')
        .select('*')
        .eq('class_definition_id', group.class_definition_id)
        .gte('date', weekStart)
        .lte('date', weekEnd)
        .eq('is_cancelled', false)

      if (instanceError || !instances || instances.length === 0) {
        results.push({
          group_id: group.id,
          skipped: members.length,
          reason: 'No instance found for this week',
        })
        totalSkipped += members.length
        continue
      }

      for (const instance of instances) {
        for (const member of members) {
          const userId = member.user_id

          // Skip if already booked
          const { count: existingCount } = await supabaseAdmin
            .from('bookings')
            .select('*', { count: 'exact', head: true })
            .eq('user_id', userId)
            .eq('class_instance_id', instance.id)
            .in('status', ['confirmed', 'waitlisted'])

          if ((existingCount ?? 0) > 0) {
            results.push({ user_id: userId, instance_id: instance.id, skipped: true, reason: 'Already booked' })
            continue
          }

          // Get active card for this member
          const { data: card } = await supabaseAdmin
            .from('session_cards')
            .select('id, remaining_sessions, valid_until, status')
            .eq('user_id', userId)
            .eq('status', 'active')
            .order('valid_until', { ascending: true })
            .limit(1)
            .maybeSingle()

          if (!card || card.remaining_sessions <= 0 || new Date(card.valid_until) < now) {
            // Notify the user they were skipped
            supabaseAdmin
              .from('user_notifications')
              .insert({
                user_id: userId,
                type: 'auto_book_failed',
                title: 'Automaatne broneering ebaõnnestus',
                body: 'Teie püsirühma tund ei saanud broneerida, kuna teil puudub aktiivne kaart piisavate sessioonidega.',
                data: { class_instance_id: instance.id, group_id: group.id },
              })
              .then(() => {})
              .catch(() => {})

            results.push({ user_id: userId, instance_id: instance.id, skipped: true, reason: 'No active card' })
            totalSkipped++
            continue
          }

          // Check capacity
          const { count: confirmedCount } = await supabaseAdmin
            .from('bookings')
            .select('*', { count: 'exact', head: true })
            .eq('class_instance_id', instance.id)
            .eq('status', 'confirmed')

          const isFull = (confirmedCount ?? 0) >= instance.max_participants

          // Deduct session (always for fixed group members, even if waitlisted)
          if (!isFull) {
            const { error: cardError } = await supabaseAdmin
              .from('session_cards')
              .update({
                remaining_sessions: card.remaining_sessions - 1,
                updated_at: now.toISOString(),
              })
              .eq('id', card.id)

            if (cardError) {
              results.push({ user_id: userId, instance_id: instance.id, skipped: true, reason: 'Card update failed' })
              totalSkipped++
              continue
            }
          }

          // Create booking
          const { data: booking, error: bookingError } = await supabaseAdmin
            .from('bookings')
            .insert({
              user_id: userId,
              class_instance_id: instance.id,
              card_id: card.id,
              status: isFull ? 'waitlisted' : 'confirmed',
              session_deducted: !isFull,
              booked_at: now.toISOString(),
              waitlist_position: isFull ? 1 : null,
            })
            .select()
            .single()

          if (bookingError) {
            // Refund session if booking failed
            if (!isFull) {
              await supabaseAdmin
                .from('session_cards')
                .update({ remaining_sessions: card.remaining_sessions, updated_at: now.toISOString() })
                .eq('id', card.id)
            }
            results.push({ user_id: userId, instance_id: instance.id, skipped: true, reason: 'Booking failed' })
            totalSkipped++
            continue
          }

          // Notify user of their auto-booking
          supabaseAdmin
            .from('user_notifications')
            .insert({
              user_id: userId,
              type: isFull ? 'waitlist_joined' : 'booking_confirmed',
              title: isFull ? 'Automaatne ootenimekiri' : 'Automaatne broneering tehtud',
              body: isFull
                ? 'Tund on täis, kuid teid on ootenimekirja pandud.'
                : 'Teie püsirühma tund on edukalt broneeritud.',
              data: { booking_id: booking.id, class_instance_id: instance.id, group_id: group.id },
            })
            .then(() => {})
            .catch(() => {})

          results.push({ user_id: userId, instance_id: instance.id, booked: true, status: isFull ? 'waitlisted' : 'confirmed' })
          totalBooked++
        }
      }
    }

    return new Response(
      JSON.stringify({
        week_start: weekStart,
        week_end: weekEnd,
        total_booked: totalBooked,
        total_skipped: totalSkipped,
        results,
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
