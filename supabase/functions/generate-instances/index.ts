import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Weekly cron function: generate next week's class instances from class_definitions.
 * Typically triggered by Supabase pg_cron every Monday at 00:00 UTC.
 *
 * Can also be called manually with a body: { week_offset: 1 } where offset is
 * the number of weeks from now (default: 1 = next week).
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

    // Parse optional week_offset from body
    let weekOffset = 1
    try {
      const body = await req.json()
      if (body.week_offset !== undefined) {
        weekOffset = Number(body.week_offset)
      }
    } catch {
      // No body or invalid JSON — use default
    }

    // Calculate start and end of the target week (Monday to Sunday)
    const now = new Date()
    const currentDay = now.getDay() // 0=Sun, 1=Mon...
    const daysUntilMonday = currentDay === 0 ? 1 : 8 - currentDay
    const nextMonday = new Date(now)
    nextMonday.setDate(now.getDate() + daysUntilMonday + (weekOffset - 1) * 7)
    nextMonday.setHours(0, 0, 0, 0)

    const nextSunday = new Date(nextMonday)
    nextSunday.setDate(nextMonday.getDate() + 6)

    // Fetch all active class definitions
    const { data: definitions, error: defError } = await supabaseAdmin
      .from('class_definitions')
      .select('*')
      .eq('is_active', true)

    if (defError) {
      return new Response(JSON.stringify({ error: 'Failed to fetch class definitions' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (!definitions || definitions.length === 0) {
      return new Response(
        JSON.stringify({ created: 0, message: 'No active class definitions found' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    const instancesToCreate: Record<string, unknown>[] = []

    for (const def of definitions) {
      // day_of_week: 1=Mon, 2=Tue, ..., 7=Sun (ISO standard)
      const targetDate = new Date(nextMonday)
      targetDate.setDate(nextMonday.getDate() + (def.day_of_week - 1))

      const dateStr = targetDate.toISOString().split('T')[0]

      // Parse start_time (HH:MM or HH:MM:SS) to calculate end_time
      const [hours, minutes] = def.start_time.split(':').map(Number)
      const startMinutes = hours * 60 + minutes
      const endMinutes = startMinutes + def.duration_minutes
      const endHours = Math.floor(endMinutes / 60)
      const endMins = endMinutes % 60
      const endTime = `${String(endHours).padStart(2, '0')}:${String(endMins).padStart(2, '0')}:00`
      const startTimeFull = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:00`

      // Check if an instance already exists for this definition on this date
      const { count } = await supabaseAdmin
        .from('class_instances')
        .select('*', { count: 'exact', head: true })
        .eq('class_definition_id', def.id)
        .eq('date', dateStr)

      if ((count ?? 0) > 0) {
        // Already generated — skip
        continue
      }

      instancesToCreate.push({
        class_definition_id: def.id,
        date: dateStr,
        start_time: startTimeFull,
        end_time: endTime,
        instructor_id: def.instructor_id,
        studio_id: def.studio_id,
        max_participants: def.max_participants,
        is_cancelled: false,
      })
    }

    if (instancesToCreate.length === 0) {
      return new Response(
        JSON.stringify({
          created: 0,
          message: 'All instances for this week already exist',
          week_start: nextMonday.toISOString().split('T')[0],
          week_end: nextSunday.toISOString().split('T')[0],
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    const { data: created, error: insertError } = await supabaseAdmin
      .from('class_instances')
      .insert(instancesToCreate)
      .select()

    if (insertError) {
      return new Response(JSON.stringify({ error: 'Failed to insert instances', detail: insertError.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    return new Response(
      JSON.stringify({
        created: created?.length ?? 0,
        week_start: nextMonday.toISOString().split('T')[0],
        week_end: nextSunday.toISOString().split('T')[0],
        instances: created,
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
