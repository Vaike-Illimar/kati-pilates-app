# Deploying Supabase Edge Functions

## Prerequisites

- [Supabase CLI](https://supabase.com/docs/guides/cli) installed (`npm install -g supabase`)
- Logged in: `supabase login`
- Project linked: `supabase link --project-ref nrdncrebjxvciapvcfph`

## Deploy All Functions

Run from the repo root:

```bash
supabase functions deploy book-class --project-ref nrdncrebjxvciapvcfph
supabase functions deploy cancel-booking --project-ref nrdncrebjxvciapvcfph
supabase functions deploy promote-waitlist --project-ref nrdncrebjxvciapvcfph
supabase functions deploy generate-instances --project-ref nrdncrebjxvciapvcfph
supabase functions deploy auto-book-fixed --project-ref nrdncrebjxvciapvcfph
supabase functions deploy check-card-expiry --project-ref nrdncrebjxvciapvcfph
```

## Environment Variables

The functions use these env vars (auto-provided by Supabase runtime):
- `SUPABASE_URL` — project URL
- `SUPABASE_ANON_KEY` — public anon key
- `SUPABASE_SERVICE_ROLE_KEY` — service role key (for admin operations)

No manual secrets needed; Supabase injects these automatically for deployed functions.

## Setting Up Cron Jobs

Go to **Supabase Dashboard → Database → Extensions** and enable `pg_cron`.

Then in the SQL editor:

```sql
-- Generate next week's class instances every Monday at 00:00 UTC
select cron.schedule(
  'generate-weekly-instances',
  '0 0 * * 1',
  $$
  select net.http_post(
    url := 'https://nrdncrebjxvciapvcfph.supabase.co/functions/v1/generate-instances',
    headers := '{"Authorization": "Bearer <SERVICE_ROLE_KEY>", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- Auto-book fixed group members every Monday at 01:00 UTC (after instance generation)
select cron.schedule(
  'auto-book-fixed-groups',
  '0 1 * * 1',
  $$
  select net.http_post(
    url := 'https://nrdncrebjxvciapvcfph.supabase.co/functions/v1/auto-book-fixed',
    headers := '{"Authorization": "Bearer <SERVICE_ROLE_KEY>", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);

-- Check card expiry daily at 06:00 UTC
select cron.schedule(
  'check-card-expiry',
  '0 6 * * *',
  $$
  select net.http_post(
    url := 'https://nrdncrebjxvciapvcfph.supabase.co/functions/v1/check-card-expiry',
    headers := '{"Authorization": "Bearer <SERVICE_ROLE_KEY>", "Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);
```

Replace `<SERVICE_ROLE_KEY>` with your actual service role key from **Settings → API**.

## Function Descriptions

| Function | Trigger | Description |
|----------|---------|-------------|
| `book-class` | Client call | Validates card, deducts session, checks capacity, handles waitlist |
| `cancel-booking` | Client call | Normal cancel (refund) or late cancel (<2h, no refund), triggers waitlist promotion |
| `promote-waitlist` | Called by cancel-booking | Auto-promotes next waitlisted user when a spot opens |
| `generate-instances` | Weekly cron Mon 00:00 | Creates next week's class_instances from class_definitions |
| `auto-book-fixed` | Weekly cron Mon 01:00 | Auto-books fixed group members into their weekly classes |
| `check-card-expiry` | Daily cron 06:00 | Marks expired cards, sends 14-day warning notifications |

## Testing Functions Locally

```bash
supabase start
supabase functions serve --env-file .env.local
```

Example test call:
```bash
curl -X POST http://localhost:54321/functions/v1/book-class \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "Content-Type: application/json" \
  -d '{"class_instance_id": "<uuid>", "card_id": "<uuid>"}'
```

## Manual Trigger (Admin)

To manually generate instances for next week from the Flutter app, the admin calls:
```
POST /functions/v1/generate-instances
Body: {}
```

This is wired to the "Generate schedule" button in the admin calendar screen.
