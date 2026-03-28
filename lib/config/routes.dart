import 'dart:async';
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
import 'package:kati_pilates/models/class_definition.dart';
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
import 'package:kati_pilates/features/admin/calendar/screens/admin_calendar_screen.dart';
import 'package:kati_pilates/features/admin/calendar/screens/admin_instance_screen.dart';
import 'package:kati_pilates/features/admin/classes/screens/class_definitions_screen.dart';
import 'package:kati_pilates/features/admin/classes/screens/edit_class_definition_screen.dart';
import 'package:kati_pilates/features/admin/studios/screens/studios_screen.dart';
import 'package:kati_pilates/features/admin/instructors/screens/instructors_screen.dart';
import 'package:kati_pilates/features/admin/clients/screens/create_card_screen.dart';
import 'package:kati_pilates/features/admin/clients/screens/client_booking_history_screen.dart';
import 'package:kati_pilates/shared/widgets/bottom_nav_bar.dart';
import 'package:kati_pilates/shared/widgets/admin_bottom_nav_bar.dart';
import 'package:kati_pilates/shared/widgets/waitlist_promotion_banner.dart';

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

  // Admin calendar nested
  static const String adminClassDefinitions = '/admin/calendar/class-definitions';
  static const String adminStudios = '/admin/calendar/studios';
  static const String adminInstructors = '/admin/calendar/instructors';
}

// ---------------------------------------------------------------------------
// Navigator keys
// ---------------------------------------------------------------------------
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _clientShellKey = GlobalKey<NavigatorState>();
final _adminShellKey = GlobalKey<NavigatorState>();

// ---------------------------------------------------------------------------
// Listenable that notifies GoRouter when auth state changes
// ---------------------------------------------------------------------------
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((authState) async {
      // Fetch user role before notifying the router
      if (authState.event == AuthChangeEvent.signedIn ||
          authState.event == AuthChangeEvent.tokenRefreshed) {
        await checkUserRole();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        _isAdminUser = null;
      }
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePaths.schedule,
  debugLogDiagnostics: true,
  refreshListenable: _GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
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
        // Tab 0 – Kalender
        StatefulShellBranch(
          navigatorKey: _adminShellKey,
          routes: [
            GoRoute(
              path: RoutePaths.adminCalendar,
              builder: (context, state) => const AdminCalendarScreen(),
              routes: [
                GoRoute(
                  path: 'instance/:instanceId',
                  builder: (context, state) => AdminInstanceScreen(
                    instanceId: state.pathParameters['instanceId']!,
                  ),
                ),
                GoRoute(
                  path: 'class-definitions',
                  builder: (context, state) => const ClassDefinitionsScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, state) =>
                          const EditClassDefinitionScreen(),
                    ),
                    GoRoute(
                      path: ':defId',
                      builder: (context, state) => EditClassDefinitionScreen(
                        existing: state.extra as ClassDefinition?,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'studios',
                  builder: (context, state) => const StudiosScreen(),
                ),
                GoRoute(
                  path: 'instructors',
                  builder: (context, state) => const InstructorsScreen(),
                ),
              ],
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
                    GoRoute(
                      path: 'create-card',
                      builder: (context, state) => CreateCardScreen(
                        userId: state.pathParameters['userId']!,
                      ),
                    ),
                    GoRoute(
                      path: 'history',
                      builder: (context, state) => ClientBookingHistoryScreen(
                        userId: state.pathParameters['userId']!,
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
// Cached admin role for the current user (avoids DB call on every redirect)
// ---------------------------------------------------------------------------
bool? _isAdminUser;

/// Fetches user role from profiles table and caches it.
Future<void> checkUserRole() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    _isAdminUser = null;
    return;
  }
  try {
    final data = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();
    final role = data['role'] as String?;
    _isAdminUser = (role == 'admin' || role == 'instructor');
  } catch (_) {
    _isAdminUser = false;
  }
}

// ---------------------------------------------------------------------------
// Auth redirect guard
// ---------------------------------------------------------------------------
String? _authGuard(BuildContext context, GoRouterState state) {
  final session = Supabase.instance.client.auth.currentSession;
  final isLoggedIn = session != null;
  final isAuthRoute = state.matchedLocation.startsWith('/auth');
  final isAdminRoute = state.matchedLocation.startsWith('/admin');

  // Not logged in and not on auth page → redirect to login
  if (!isLoggedIn && !isAuthRoute) {
    _isAdminUser = null;
    return RoutePaths.login;
  }

  // Logged in but on auth page → redirect based on role
  if (isLoggedIn && isAuthRoute) {
    if (_isAdminUser == true) {
      return RoutePaths.adminCalendar;
    }
    return RoutePaths.schedule;
  }

  // Logged in admin on client route → redirect to admin
  if (isLoggedIn && _isAdminUser == true && !isAdminRoute && !isAuthRoute) {
    return RoutePaths.adminCalendar;
  }

  // Logged in non-admin on admin route → redirect to client
  if (isLoggedIn && _isAdminUser != true && isAdminRoute) {
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
    return WaitlistPromotionListener(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: BottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) =>
              navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        ),
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
