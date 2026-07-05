import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../screens/edit_booking_screen.dart';
import '../screens/add_booking_screen.dart';
import '../screens/booking_details_screen.dart';
import '../screens/booking_list_screen.dart';
import '../screens/calendar_slots_screen.dart';
import '../screens/create_account_screen.dart';
import '../screens/home_screen.dart';
import '../screens/invite_team_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/login_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/pending_approval_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/packages_screen.dart';
import '../screens/record_payment_screen.dart';
import '../screens/team_members_screen.dart';

GoRouter createAppRouter(MarqueeFlowApi api) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => SplashScreen(api: api)),
      GoRoute(path: '/login', builder: (_, __) => LoginScreen(api: api)),
      GoRoute(path: '/forgot-password', builder: (_, __) => ForgotPasswordScreen(api: api)),
      GoRoute(path: '/register', builder: (_, __) => CreateAccountScreen(api: api)),
      GoRoute(path: '/subscription', builder: (_, __) => SubscriptionScreen(api: api)),
      GoRoute(path: '/pending-approval', builder: (_, __) => PendingApprovalScreen(api: api)),
      GoRoute(path: '/customers', builder: (_, __) => CustomersScreen(api: api)),
      GoRoute(path: '/packages', builder: (_, __) => PackagesScreen(api: api)),
      GoRoute(path: '/profile', builder: (_, __) => ProfileScreen(api: api)),
      GoRoute(path: '/home', builder: (_, __) => HomeScreen(api: api)),
      GoRoute(path: '/calendar', builder: (_, __) => CalendarSlotsScreen(api: api)),
      GoRoute(
        path: '/bookings/new',
        builder: (_, state) => AddBookingScreen(
          api: api,
          prefill: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(path: '/bookings', builder: (_, __) => BookingListScreen(api: api)),
      GoRoute(
        path: '/bookings/:id',
        builder: (_, state) => BookingDetailsScreen(
          api: api,
          bookingId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => EditBookingScreen(
              api: api,
              bookingId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'record-payment',
            builder: (_, state) => RecordPaymentScreen(
              api: api,
              bookingId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(path: '/payments', builder: (_, __) => PaymentsScreen(api: api)),
      GoRoute(path: '/team', builder: (_, __) => TeamMembersScreen(api: api)),
      GoRoute(path: '/team/invite', builder: (_, __) => InviteTeamScreen(api: api)),
    ],
  );
}
