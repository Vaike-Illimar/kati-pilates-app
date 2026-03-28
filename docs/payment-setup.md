# Payment Integration Setup (Estonian Market)

## Overview

The Kati Pilates app sells session cards (4, 5, or 10 sessions) to clients. This guide covers integrating Estonian-market payment providers.

## Recommended Providers

| Provider | Notes | Estonia support |
|----------|-------|-----------------|
| **Montonio** | Estonian startup, supports all Estonian banks, cards, BNPL | Yes, native |
| **EveryPay** | Estonian provider, widely used, supports LHV/SEB/Swedbank | Yes, native |
| **Stripe** | Global, card payments only (no Estonian bank links) | Partial |
| **MaksekeskUS** | Estonian aggregator, all local payment methods | Yes |

**Recommendation: Montonio or EveryPay** — both support Estonian bank links (pangalink) which is essential for the Estonian market.

---

## Montonio Integration

### 1. Create Montonio Account

1. Go to [Montonio Partner Portal](https://partner.montonio.com)
2. Register as a merchant
3. Complete KYC/KYB verification
4. Get API keys from **Settings → API Keys**:
   - `ACCESS_KEY` (public)
   - `SECRET_KEY` (private)

### 2. How Montonio Works

Montonio uses a JWT-based order flow:
1. Your backend creates a payment order (signed JWT)
2. User is redirected to Montonio payment page
3. User completes payment via bank/card
4. Montonio sends webhook to your backend
5. Your backend activates the session card

### 3. Supabase Edge Function: Create Payment Order

```typescript
// supabase/functions/create-payment/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
// For JWT: import { create } from 'https://deno.land/x/djwt@v2.8/mod.ts'

const MONTONIO_ACCESS_KEY = Deno.env.get('MONTONIO_ACCESS_KEY') ?? ''
const MONTONIO_SECRET_KEY = Deno.env.get('MONTONIO_SECRET_KEY') ?? ''
const MONTONIO_API_URL = 'https://stargate.montonio.com' // sandbox: https://sandbox-stargate.montonio.com

serve(async (req) => {
  const { card_type, user_id } = await req.json()

  const prices: Record<string, number> = {
    '4_sessions': 6000,   // 60 EUR in cents
    '5_sessions': 7500,   // 75 EUR
    '10_sessions': 14000, // 140 EUR
  }

  const amount = prices[card_type]
  if (!amount) return new Response(JSON.stringify({ error: 'Invalid card type' }), { status: 400 })

  // Create JWT payload for Montonio
  const payload = {
    access_key: MONTONIO_ACCESS_KEY,
    merchant_reference: `card_${user_id}_${Date.now()}`,
    return_url: 'https://your-app.com/payment/return',
    notification_url: `https://nrdncrebjxvciapvcfph.supabase.co/functions/v1/payment-webhook`,
    currency: 'EUR',
    grand_total: amount / 100,
    locale: 'et',
    payment: {
      amount: amount / 100,
      currency: 'EUR',
    },
    line_items: [{
      name: `Sessioonkaart (${card_type.replace('_sessions', ' sessiooni')})`,
      quantity: 1,
      final_price: amount / 100,
    }],
    exp: Math.floor(Date.now() / 1000) + 600, // 10 min expiry
  }

  // Sign JWT with secret key
  // const token = await create({ alg: 'HS256', typ: 'JWT' }, payload, MONTONIO_SECRET_KEY)

  return new Response(JSON.stringify({
    payment_url: `${MONTONIO_API_URL}/orders?payment_token=<token>`,
  }), { headers: { 'Content-Type': 'application/json' } })
})
```

### 4. Webhook Handler: Activate Card After Payment

```typescript
// supabase/functions/payment-webhook/index.ts
serve(async (req) => {
  const body = await req.json()
  // Verify webhook signature
  // Activate session card for the user
  // Create user_notification
})
```

### 5. Supabase Secrets

```bash
supabase secrets set MONTONIO_ACCESS_KEY="your_access_key"
supabase secrets set MONTONIO_SECRET_KEY="your_secret_key"
```

---

## EveryPay Integration

### 1. Create EveryPay Account

1. Apply at [EveryPay](https://every-pay.com/et/)
2. Get credentials: `account_name`, `api_secret`
3. Test environment: `https://igw-demo.every-pay.com`
4. Production: `https://igw.every-pay.com`

### 2. Payment Flow

```
POST /api/v4/payments/oneclick/charge → get payment_link
Redirect user to payment_link
User pays
EveryPay sends callback to your webhook
Webhook activates session card
```

---

## Flutter App: Launching Payment

Since payments happen in a web browser (redirect flow), use `url_launcher`:

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> buySessionCard(CardType cardType) async {
  // Call your Supabase edge function to create payment order
  final response = await Supabase.instance.client.functions.invoke(
    'create-payment',
    body: {'card_type': cardType.name, 'user_id': currentUserId},
  );

  final paymentUrl = response.data['payment_url'] as String;

  if (await canLaunchUrl(Uri.parse(paymentUrl))) {
    await launchUrl(
      Uri.parse(paymentUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}
```

For a better UX, consider using `webview_flutter` or `flutter_inappwebview` to keep users in-app.

---

## Return URL Handling

After payment, the user returns to the app. Set up deep links:

### Android `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="katipilates" android:host="payment"/>
</intent-filter>
```

### iOS `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>katipilates</string>
    </array>
  </dict>
</array>
```

**Return URL**: `katipilates://payment/return`

Handle in Flutter with `app_links` or `uni_links` package.

---

## Card Screen Integration

Update `lib/features/card/screens/card_screen.dart` to call `buySessionCard()` when user taps a card option. Show a loading state while waiting for webhook confirmation.

---

## Testing

- Montonio sandbox: use test credentials from partner portal, test bank returns
- EveryPay demo: use demo environment, test card numbers provided in their docs
- Always test full flow: payment → webhook → card activation → notification
