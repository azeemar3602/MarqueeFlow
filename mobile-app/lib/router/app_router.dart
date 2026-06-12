import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../screens/add_booking_screen.dart';
import '../screens/booking_details_screen.dart';
import '../screens/booking_list_screen.dart';
import '../screens/calendar_slots_screen.dart';
import '../screens/create_account_screen.dart';
import '../screens/home_screen.dart';
import '../screens/invite_team_screen.dart';
import '../screens/login_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/team_members_screen.dart';

GoRouter createAppRouter(MarqueeFlowApi api) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => SplashScreen(api: api)),
      GoRoute(path: '/login', builder: (_, __) => LoginScreen(api: api)),
      GoRoute(path: '/register', builder: (_, __) => CreateAccountScreen(api: api)),
      GoRoute(path: '/subscription', builder: (_, __) => SubscriptionScreen(api: api)),
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
      ),
      GoRoute(path: '/payments', builder: (_, __) => PaymentsScreen(api: api)),
      GoRoute(path: '/team', builder: (_, __) => TeamMembersScreen(api: api)),
      GoRoute(path: '/team/invite', builder: (_, __) => InviteTeamScreen(api: api)),
    ],
  );
}
