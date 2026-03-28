# Firebase Cloud Messaging (FCM) Setup for Push Notifications

## Overview

This app uses Supabase for the backend. Push notifications can be delivered via:
1. **FCM** (Firebase Cloud Messaging) for Android and iOS
2. **APNs** (Apple Push Notification service) directly for iOS

This guide covers FCM setup with a Supabase edge function as the sender.

## Prerequisites

- Google account with access to [Firebase Console](https://console.firebase.google.com)
- Xcode (for iOS setup)
- Android Studio (for Android setup)
- Supabase project: `nrdncrebjxvciapvcfph`

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project**
3. Name: `kati-pilates-app`
4. Disable Google Analytics (not needed for push only)
5. Click **Create project**

---

## Step 2: Add Android App

1. In Firebase Console → **Project settings** → **Add app** → Android
2. **Android package name**: `ee.katipilates.app` (match `android/app/build.gradle`)
3. Download `google-services.json`
4. Place at: `android/app/google-services.json`

### Android build.gradle changes

`android/build.gradle` (project level):
```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
  }
}
```

`android/app/build.gradle` (app level):
```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## Step 3: Add iOS App

1. In Firebase Console → **Add app** → iOS
2. **iOS bundle ID**: `ee.katipilates.app` (match Xcode bundle ID)
3. Download `GoogleService-Info.plist`
4. Add to Xcode project: drag into `ios/Runner/` folder (check "Copy items if needed")

### iOS Capabilities (Xcode)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select `Runner` target → **Signing & Capabilities**
3. Click `+` and add:
   - **Push Notifications**
   - **Background Modes** → check **Remote notifications**

### APNs Key (for iOS)

1. Go to [Apple Developer portal](https://developer.apple.com)
2. **Certificates, IDs & Profiles** → **Keys** → Create key
3. Enable **Apple Push Notifications service (APNs)**
4. Download the `.p8` key file

5. In Firebase Console → **Project settings** → **Cloud Messaging** → iOS app
6. Upload the `.p8` key file with your Key ID and Team ID

---

## Step 4: Add Flutter Firebase Packages

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: any
  firebase_messaging: any
```

Initialize in `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // ... rest of initialization
}
```

---

## Step 5: Register FCM Token in Supabase

After user login, save their FCM token to Supabase:

```dart
// In auth_repository.dart or a dedicated service:
Future<void> saveFcmToken(String userId) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) return;

  await Supabase.instance.client.from('user_push_tokens').upsert({
    'user_id': userId,
    'token': token,
    'platform': Platform.isIOS ? 'ios' : 'android',
    'updated_at': DateTime.now().toISOString(),
  }, onConflict: 'user_id,platform');
}
```

You need a `user_push_tokens` table in Supabase:
```sql
create table user_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  token text not null,
  platform text not null, -- 'ios' | 'android'
  updated_at timestamptz default now(),
  unique(user_id, platform)
);
```

---

## Step 6: Send Notifications from Edge Function

In a Supabase edge function, send push notifications via FCM HTTP v1 API:

```typescript
// supabase/functions/send-push-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const FCM_PROJECT_ID = 'kati-pilates-app'

async function sendFcmMessage(token: string, title: string, body: string, data?: Record<string, string>) {
  const accessToken = await getAccessToken()

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: data ?? {},
        },
      }),
    }
  )
  return response.json()
}

async function getAccessToken(): Promise<string> {
  // Use Google service account key stored as Supabase secret
  // See: https://firebase.google.com/docs/cloud-messaging/auth-server
  const serviceAccountKey = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT_KEY') ?? '{}')
  // ... implement JWT signing for service account
  // Use a library like https://esm.sh/google-auth-library for Deno
  throw new Error('Implement getAccessToken with service account JWT')
}
```

Store Firebase service account key as a Supabase secret:
```bash
supabase secrets set FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account",...}'
```

---

## Step 7: Handle Foreground Notifications in Flutter

```dart
// In main.dart or a notification service:
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // App is in foreground — show local notification or in-app banner
  final notification = message.notification;
  if (notification != null) {
    // Use flutter_local_notifications to show while app is open
    // Or use the existing WaitlistPromotionListener/in-app UI
  }
});

// Handle notification tap (app in background)
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Navigate to relevant screen based on message.data
  final type = message.data['type'];
  if (type == 'waitlist_promoted') {
    // Navigate to bookings screen
  }
});
```

---

## Supabase + FCM Integration Flow

```
User action (booking cancelled)
  → cancel-booking edge function
  → inserts user_notification in Supabase
  → triggers send-push-notification function
  → fetches FCM token from user_push_tokens
  → sends FCM message to device
  → Flutter app receives and shows notification
```

---

## Testing

- **Android**: Use Firebase Console → **Cloud Messaging** → **Send test message** with device token
- **iOS**: Same approach, ensure APNs key is configured
- **Supabase function**: Call `send-push-notification` function directly with a test token
