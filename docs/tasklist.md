# Kati Pilates App — Remaining Tasks

## Status Legend
- [ ] Not started
- [x] Completed

---

## 1. Supabase Edge Functions (Critical — booking doesn't work without these)

- [ ] `book-class` — Validate active card, deduct session, check capacity, handle waitlist
- [ ] `cancel-booking` — Normal cancel (refund session) vs late cancel (<2h, penalty)
- [ ] `promote-waitlist` — Auto-promote next waitlisted user when a spot opens
- [ ] `generate-instances` — Weekly cron: create next week's class_instances from class_definitions
- [ ] `auto-book-fixed` — Weekly cron: auto-book fixed group members into next week's classes
- [ ] `check-card-expiry` — Daily cron: mark expired cards, send 14-day warning notifications

---

## 2. Admin — Calendar & Class Management (Can't set up studio without these)

- [ ] **Admin Calendar screen** — Replace placeholder with daily/weekly view of all class instances
- [ ] **Class Definitions CRUD** — Create, edit, delete class definitions (name, level, day, time, instructor, studio, capacity)
- [ ] **Studios CRUD** — Create, edit studios (name, address, capacity)
- [ ] **Instructor management** — List instructors, assign instructor role to users
- [ ] **Class Instance management** — View instances, cancel individual instances, add notes
- [ ] **Generate schedule** — Admin action to generate next week's class instances from definitions

---

## 3. Admin — Client & Attendance

- [ ] **Create card for client** — Admin can create a new session card for a client (select type, set validity)
- [ ] **Attendance marking** — After class: mark clients as attended or no-show
- [ ] **Client booking history** — Full view of a client's past bookings and attendance

---

## 4. Real-Time Features

- [ ] **Class availability** — Supabase Realtime on bookings table for live "Vabad kohad: X" updates
- [ ] **Waitlist promotion** — Real-time listener: notify client when promoted from waitlist
- [ ] **Notification feed** — Real-time listener for new user_notifications

---

## 5. Push Notifications (Firebase Cloud Messaging)

- [ ] **FCM setup** — Firebase project, add google-services.json / GoogleService-Info.plist
- [ ] **Device token registration** — Save FCM token to device_tokens table on app launch
- [ ] **Morning reminder** — Push notification on class day morning
- [ ] **Waitlist promotion** — Push when user gets promoted from waitlist
- [ ] **Card expiry warning** — Push at 14 days before expiry
- [ ] **Admin broadcast** — Push for admin-sent notifications

---

## 6. Polish & Quality

- [ ] **Image upload** — Profile photo upload to Supabase Storage
- [ ] **Loading shimmer** — Replace spinners with shimmer placeholders on all screens
- [ ] **Offline handling** — Show cached data when offline, queue actions
- [ ] **Error states** — Review all screens for consistent error handling
- [ ] **Empty states** — Review all lists for consistent empty state messaging
- [ ] **Pull to refresh** — Ensure all list screens support pull-to-refresh
- [ ] **Animations** — Page transitions, booking confirmation animation

---

## 7. Payment Integration (Future)

- [ ] **Payment provider** — Integrate Montonio/EveryPay or Stripe for Estonian market
- [ ] **In-app card purchase** — Replace "Osta" placeholder with real payment flow
- [ ] **Payment history** — Receipt/invoice view for purchased cards

---

## 8. Testing & Launch

- [ ] **Unit tests** — Repository and provider tests
- [ ] **Widget tests** — Key screen tests
- [ ] **Integration tests** — Full booking flow end-to-end
- [ ] **App icon** — Custom Kati Pilates icon for iOS and Android
- [ ] **Splash screen** — Branded splash screen
- [ ] **App Store metadata** — Screenshots, description, keywords (Estonian)
- [ ] **Google Play submission** — Build, sign, submit
- [ ] **Apple App Store submission** — Build, sign, submit (already in progress)

---

## Completed

- [x] Flutter project setup with folder structure
- [x] Supabase database schema (13 tables, 10 enums, 31 RLS policies, 2 views)
- [x] Supabase config with project URL and anon key
- [x] Theme with design colors, typography, shapes
- [x] 11 Freezed data models
- [x] 7 repositories (auth, class, booking, card, fixed_group, notification, profile)
- [x] 6 Riverpod providers
- [x] GoRouter with auth guard and role-based routing
- [x] Login screen
- [x] Registration screen
- [x] Client bottom nav (Tunniplaan, Broneeringud, Kaart, Profiil)
- [x] Admin bottom nav (Kalender, Ruhmad, Kliendid, Seaded)
- [x] Schedule screen with weekday selector and class list
- [x] Class detail screen (available/full/waitlist states)
- [x] Bookings screen (Tulevad/Moodunud tabs)
- [x] Booking confirmed screen with fixed group upsell
- [x] Cancel confirmation bottom sheet
- [x] Late cancel warning dialog
- [x] Cancellation success banner
- [x] My Card screen (active/paused/empty states)
- [x] Session card gradient visual
- [x] Buy card options (placeholder)
- [x] Fixed group invitation screen
- [x] My fixed group screen (auto-bookings, pause, leave)
- [x] Notifications screen with Estonian timeago
- [x] Profile screen with logout
- [x] Admin: Fixed groups list
- [x] Admin: Group detail with members
- [x] Admin: Add member search
- [x] Admin: Member actions sheet
- [x] Admin: Client card view (view, add sessions, pause)
- [x] Admin: Pause card form
- [x] Admin: Notifications list (sent/scheduled)
- [x] Admin: Create notification form
- [x] Admin: Select recipients
- [x] Admin: Notification sent confirmation
- [x] Shared widgets (weekday_selector, class_card, status_badge, booking_list_item, avatar_circle, empty_state)
- [x] Estonian date formatting utilities
- [x] Greeting helper (hommikust/paevast/ohtust)
- [x] Seed data (studios, instructors, classes, instances)
- [x] Test users (admin + client with session card)
- [x] iOS App Store prep
