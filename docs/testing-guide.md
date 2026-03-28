# Testing Guide

## Overview

This guide covers how to test the Kati Pilates Flutter app: unit tests, widget tests, integration tests, and manual testing with Supabase.

---

## Test Structure

```
test/
  unit/
    models/           # Freezed model serialization tests
    repositories/     # Repository logic tests (mocked Supabase)
    providers/        # Riverpod provider tests
  widget/
    schedule/         # ScheduleScreen, ClassCardWidget tests
    booking/          # BookingScreen tests
    card/             # CardScreen tests
  helpers/
    mock_supabase.dart
    test_providers.dart
```

---

## Running Tests

### All tests
```bash
flutter test
```

### Single file
```bash
flutter test test/unit/models/booking_test.dart
```

### With coverage
```bash
flutter test --coverage
# View coverage report:
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Watch mode (re-runs on file change)
```bash
flutter test --watch
```

---

## Unit Tests

### Model Serialization Test

```dart
// test/unit/models/booking_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kati_pilates/models/booking.dart';

void main() {
  group('BookingDetailed', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'abc123',
        'user_id': 'user1',
        'class_instance_id': 'class1',
        'status': 'confirmed',
        'booked_at': '2025-01-01T10:00:00.000Z',
        'waitlist_position': null,
      };

      final booking = BookingDetailed.fromJson(json);

      expect(booking.id, 'abc123');
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.waitlistPosition, isNull);
    });

    test('BookingStatus.fromJson handles unknown status', () {
      expect(
        () => BookingStatus.fromJson('invalid_status'),
        throwsArgumentError,
      );
    });
  });
}
```

### Provider Test (Riverpod)

```dart
// test/unit/providers/schedule_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kati_pilates/providers/schedule_provider.dart';
import '../helpers/test_providers.dart';

void main() {
  test('selectedDateProvider defaults to today', () {
    final container = ProviderContainer(
      overrides: testOverrides,
    );
    addTearDown(container.dispose);

    final date = container.read(selectedDateProvider);
    final today = DateTime.now();

    expect(date.year, today.year);
    expect(date.month, today.month);
    expect(date.day, today.day);
  });
}
```

### Repository Test (with mock)

```dart
// test/unit/repositories/card_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kati_pilates/repositories/card_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late CardRepository repo;
  late MockSupabaseClient mockClient;

  setUp(() {
    mockClient = MockSupabaseClient();
    repo = CardRepository(mockClient);
  });

  test('getActiveCard returns null when no cards found', () async {
    // Setup mock to return empty list
    when(() => mockClient.from('session_cards').select('*').eq('user_id', any())).thenAnswer(
      (_) async => [],
    );

    final card = await repo.getActiveCard('user123');
    expect(card, isNull);
  });
}
```

---

## Widget Tests

### Widget Test Setup

```dart
// test/helpers/test_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kati_pilates/providers/auth_provider.dart';

// Override providers with test doubles
final testOverrides = <Override>[
  currentUserProvider.overrideWithValue(null),
];

Widget wrapWithProviders(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [...testOverrides, ...overrides],
    child: MaterialApp(home: child),
  );
}
```

### ClassCardWidget Test

```dart
// test/widget/schedule/class_card_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kati_pilates/shared/widgets/class_card_widget.dart';
import 'package:kati_pilates/models/class_instance.dart';
import '../helpers/test_providers.dart';

void main() {
  testWidgets('ClassCardWidget shows class name', (tester) async {
    final classInstance = ClassInstanceWithDetails(
      id: '1',
      classDefinitionId: 'def1',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      isCancelled: false,
      confirmedCount: 3,
      maxParticipants: 10,
      name: 'Pilates Põhi',
      level: 'beginner',
      instructorName: 'Kati',
    );

    await tester.pumpWidget(
      wrapWithProviders(
        ClassCardWidget(
          classInstance: classInstance,
          bookingStatus: null,
          waitlistPosition: null,
          onBook: null,
        ),
      ),
    );

    expect(find.text('Pilates Põhi'), findsOneWidget);
    expect(find.text('Kati'), findsOneWidget);
  });

  testWidgets('ClassCardWidget shows booked badge', (tester) async {
    // ...test with BookingStatus.confirmed
  });
}
```

---

## Integration Tests

Integration tests run on a real device or emulator against the Supabase **staging** (not production) environment.

### Setup

1. Create a separate Supabase project for testing, or use a test schema.
2. Create `integration_test/` folder:

```
integration_test/
  app_test.dart
  booking_flow_test.dart
```

### Run Integration Tests

```bash
# On connected device or emulator
flutter test integration_test/app_test.dart

# On specific device
flutter test integration_test/ -d <device_id>
```

### Example Integration Test

```dart
// integration_test/booking_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kati_pilates/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking flow', () {
    testWidgets('User can view schedule', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login screen should appear
      expect(find.text('Logi sisse'), findsOneWidget);
    });
  });
}
```

Add `integration_test` to `pubspec.yaml`:
```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

---

## Manual Testing Checklist

### Authentication
- [ ] Register new account with email
- [ ] Login with correct credentials
- [ ] Login with wrong password shows error
- [ ] Logout works, redirects to login screen

### Schedule Screen
- [ ] Classes load for today on app open
- [ ] Switching days updates class list
- [ ] Pull-to-refresh reloads schedule
- [ ] Empty state shows when no classes
- [ ] Shimmer shows while loading

### Class Booking
- [ ] Tap class opens detail screen
- [ ] Book button deducts session from card
- [ ] Overbooking adds to waitlist
- [ ] Cancel booking refunds session
- [ ] Late cancel (<2h) does NOT refund
- [ ] Booking confirmation shows in "Minu tunnid"

### Waitlist
- [ ] Waitlisted user sees position number
- [ ] When confirmed booking is cancelled, waitlist user gets promoted
- [ ] Promoted user receives notification banner

### Session Card
- [ ] Card screen shows remaining sessions
- [ ] Session count decreases after booking
- [ ] Expired card shows correct status
- [ ] Depleted card shows correct status

### Notifications
- [ ] Unread count badge shows on profile icon
- [ ] Notification screen lists all notifications
- [ ] Mark as read clears badge
- [ ] Mark all as read clears all

### Profile
- [ ] Name, email, phone display correctly
- [ ] Avatar upload opens image picker
- [ ] Selected photo uploads and displays
- [ ] Logout confirmation dialog appears

### Admin Features
- [ ] Admin user sees admin tab
- [ ] Calendar shows classes for selected day
- [ ] Generate schedule creates instances for week
- [ ] Cancel class instance shows cancelled badge
- [ ] Client list shows all clients
- [ ] Admin can create session card for client
- [ ] Admin can view client booking history
- [ ] Attendance marking works (attended/no_show)

---

## Testing Against Supabase

### Test User Accounts

Create dedicated test accounts in Supabase Auth:
- `test.client@katipilates.ee` — regular client with active card
- `test.admin@katipilates.ee` — admin user
- `test.waitlist@katipilates.ee` — client without card (for waitlist testing)

Set roles in `profiles` table accordingly.

### Test Data Setup (SQL)

```sql
-- Create test class definition
insert into class_definitions (name, day_of_week, start_time, duration_minutes, max_participants, level, is_active)
values ('Test Pilates', 1, '10:00', 60, 2, 'beginner', true);

-- Create test class instance for today
insert into class_instances (class_definition_id, start_time, end_time, max_participants)
values (
  '<definition_id>',
  now() + interval '2 hours',
  now() + interval '3 hours',
  2
);

-- Give test client an active card
insert into session_cards (user_id, card_type, sessions_remaining, valid_from, valid_until, status)
values (
  '<test_client_user_id>',
  '{"type": "5_sessions"}',
  5,
  now(),
  now() + interval '90 days',
  'active'
);
```

### Edge Function Testing

Test edge functions directly with curl:

```bash
# Test book-class
curl -X POST \
  https://nrdncrebjxvciapvcfph.supabase.co/functions/v1/book-class \
  -H "Authorization: Bearer <user_jwt>" \
  -H "Content-Type: application/json" \
  -d '{"class_instance_id": "<instance_id>"}'

# Test cancel-booking
curl -X POST \
  https://nrdncrebjxvciapvcfph.supabase.co/functions/v1/cancel-booking \
  -H "Authorization: Bearer <user_jwt>" \
  -H "Content-Type: application/json" \
  -d '{"booking_id": "<booking_id>"}'

# Test generate-instances (admin only)
curl -X POST \
  https://nrdncrebjxvciapvcfph.supabase.co/functions/v1/generate-instances \
  -H "Authorization: Bearer <admin_jwt>" \
  -H "Content-Type: application/json" \
  -d '{"week_offset": 0}'
```

Get a JWT for testing:
```bash
curl -X POST \
  https://nrdncrebjxvciapvcfph.supabase.co/auth/v1/token?grant_type=password \
  -H "apikey: <anon_key>" \
  -H "Content-Type: application/json" \
  -d '{"email": "test.client@katipilates.ee", "password": "<password>"}'
# Copy "access_token" from response
```

---

## Continuous Integration (Optional)

Add a GitHub Actions workflow `.github/workflows/test.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

This runs on every PR automatically. Illimar can require tests to pass before merging.

---

## Useful Commands

```bash
# Analyze code for issues
flutter analyze

# Format all dart files
dart format lib/ test/

# Check for outdated dependencies
flutter pub outdated

# Run code generation (after model changes)
flutter pub run build_runner build --delete-conflicting-outputs
```
