import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kati_pilates/features/auth/screens/login_screen.dart';
import 'package:kati_pilates/features/auth/screens/registration_screen.dart';
import 'package:kati_pilates/features/schedule/screens/schedule_screen.dart';
import 'package:kati_pilates/features/class_detail/screens/class_detail_screen.dart';
import 'package:kati_pilates/features/bookings/screens/bookings_screen.dart';
import 'package:kati_pilates/features/bookings/screens/booking_confirmed_screen.dart';
import 'package:kati_pilates/models/booking.dart';
import 'package:kati_pilates/models/admin_notification.dart';
import 'package:kati_pilates/features/fixed_group/screens/fixed_group_invitation_screen.dart';
import 'package:kati_pilates/features/fixed_group/screens/my_fixed_group_screen.dart';
import 'package:kati_pilates/features/card/screens/card_screen.dart';
import 'package:kati_pilates/features/profile/screens/profile_screen.dart';
import 'package:kati_pilates/features/notifications/screens/notifications_screen.dart';
import 'package:kati_pilates/features/admin/groups/screens/groups_list_screen.dart';
import 'package:kati_pilates/features/admin/groups/screens/group_detail_screen.dart';
import 'package:kati_pilates/features/admin/groups/screens/add_member_screen.dart';
import 'package:kati_pilates/features/admin/clients/screens/clients_list_screen.dart';
import 'package:kati_pilates/features/admin/clients/screens/client_card_screen.dart';
import 'package:kati_pilates/features/admin/clients/screens/pause_card_screen.dart';
import 'package:kati_pilates/features/admin/notifications/screens/admin_notifications_screen.dart';
import 'package:kati_pilates/features/admin/notifications/screens/create_notification_screen.dart';
import 'package:kati_pilates/features/admin/notifications/screens/select_recipients_screen.dart';
import 'package:kati_pilates/features/admin/notifications/screens/notification_sent_screen.dart';
import 'package:kati_pilates/shared/widgets/bottom_nav_bar.dart';
import 'package:kati_pilates/shared/widgets/admin_bottom_nav_bar.dart';

// ---------------------------------------------------------------------------
// Route path constants
// ---------------------------------------------------------------------------
class RoutePaths {
  RoutePaths._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Client tabs
  static const String schedule = '/schedule';
  static const String bookings = '/bookings';
  static const String card = '/card';
  static const String profile = '/profile';

  // Client nested
  static const String classDetail = '/schedule/:classId';
  static const String bookingConfirmed = '/bookings/confirmed';
  static const String notifications = '/profile/notifications';
  static const String fixedGroup = '/schedule/fixed-group/:groupId';
  static const String fixedGroupInvitation = '/schedule/fixed-group-invitation/:groupId';

  // Admin tabs
  static const String adminCalendar = '/admin/calendar';
  static const String adminGroups = '/admin/groups';
  static const String adminClients = '/admin/clients';
  static const String adminSettings = '/admin/settings';
}

// ---------------------------------------------------------------------------
// Navigator keys
// ---------------------------------------------------------------------------
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _clientShellKey = GlobalKey<NavigatorState>();
final _adminShellKey = GlobalKey<NavigatorState>();

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePaths.schedule,
  debugLogDiagnostics: true,
  redirect: _authGuard,
  routes: [
    // ---- Auth routes ----
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.register,
      builder: (context, state) => const RegistrationScreen(),
    ),

    // ---- Client shell (4 tabs) ----
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _ClientShell(navigationShell: navigationShell),
      branches: [
        // Tab 0 – Tunniplaan (Schedule)
        StatefulShellBranch(
          navigatorKey: _clientShellKey,
          routes: [
            GoRoute(
              path: RoutePaths.schedule,
              builder: (context, state) => const ScheduleScreen(),
              routes: [
                GoRoute(
                  path: ':classId',
                  builder: (context, state) => ClassDetailScreen(
                    classId: state.pathParameters['classId']!,
                  ),
                ),
                GoRoute(
                  path: 'fixed-group/:groupId',
                  builder: (context, state) => MyFixedGroupScreen(
                    groupId: state.pathParameters['groupId']!,
                  ),
                ),
                GoRoute(
                  path: 'fixed-group-invitation/:groupId',
                  builder: (context, state) => FixedGroupInvitationScreen(
                    groupId: state.pathParameters['groupId']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Tab 1 – Broneeringud (Bookings)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.bookings,
              builder: (context, state) => const BookingsScreen(),
              routes: [
                GoRoute(
                  path: 'confirmed',
                  builder: (context, state) => BookingConfirmedScreen(
                    booking: state.extra as BookingDetailed?,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Tab 2 – Kaart (Card)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.card,
              builder: (context, state) => const CardScreen(),
            ),
          ],
        ),

        // Tab 3 – Profiil (Profile)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.profile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ---- Admin shell (4 tabs) ----
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _AdminShell(navigationShell: navigationShell),
      branches: [
        // Tab 0 – Kalender (placeholder — schedule management TBD)
        StatefulShellBranch(
          navigatorKey: _adminShellKey,
          routes: [
            GoRoute(
              path: RoutePaths.adminCalendar,
              builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Kalender'),
            ),
          ],
        ),

        // Tab 1 – Rühmad (Groups)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.adminGroups,
              builder: (context, state) => const GroupsListScreen(),
              routes: [
                GoRoute(
                  path: ':groupId',
                  builder: (context, state) => GroupDetailScreen(
                    groupId: state.pathParameters['groupId']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'add-member',
                      builder: (context, state) => AddMemberScreen(
                        groupId: state.pathParameters['groupId']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Tab 2 – Kliendid (Clients)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.adminClients,
              builder: (context, state) => const ClientsListScreen(),
              routes: [
                GoRoute(
                  path: ':userId',
                  builder: (context, state) => ClientCardScreen(
                    userId: state.pathParameters['userId']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'pause/:cardId',
                      builder: (context, state) => PauseCardScreen(
                        userId: state.pathParameters['userId']!,
                        cardId: state.pathParameters['cardId']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Tab 3 – Seaded (Settings) — contains notifications + settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.adminSettings,
              builder: (context, state) => const AdminNotificationsScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const CreateNotificationScreen(),
                  routes: [
                    GoRoute(
                      path: 'recipients',
                      builder: (context, state) => const SelectRecipientsScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'sent',
                  builder: (context, state) => NotificationSentScreen(
                    notification: state.extra as AdminNotification?,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

// ---------------------------------------------------------------------------
// Auth redirect guard
// ---------------------------------------------------------------------------
String? _authGuard(BuildContext context, GoRouterState state) {
  final session = Supabase.instance.client.auth.currentSession;
  final isLoggedIn = session != null;
  final isAuthRoute = state.matchedLocation.startsWith('/auth');

  // Not logged in and not on auth page → redirect to login
  if (!isLoggedIn && !isAuthRoute) {
    return RoutePaths.login;
  }

  // Logged in but on auth page → redirect to schedule
  if (isLoggedIn && isAuthRoute) {
    return RoutePaths.schedule;
  }

  return null; // no redirect
}

// ---------------------------------------------------------------------------
// Client shell with bottom nav
// ---------------------------------------------------------------------------
class _ClientShell extends StatelessWidget {
  const _ClientShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Admin shell with bottom nav
// ---------------------------------------------------------------------------
class _AdminShell extends StatelessWidget {
  const _AdminShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder screen used for all routes until real screens are built
// ---------------------------------------------------------------------------
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
