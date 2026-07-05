import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mf_components.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_navigation.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _summary;
  String? _userName;
  int _notificationCount = 0;
  bool _loading = true;

  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await widget.api.fetchDashboard();
      final me = await widget.api.fetchMe();
      final notifications = await widget.api.fetchNotifications();
      setState(() {
        _summary = summary;
        _userName = me['user']?['name'] as String? ?? summary['greetingName'] as String?;
        _notificationCount = notifications.length;
      });
    } catch (e) {
      if (mounted) setState(() => _error = mapRequestError(e).message);
    }
    if (mounted) setState(() => _loading = false);
  }

  Widget _statCard(String title, String value) {
    return Expanded(
      child: MfCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.body().copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: AppText.display(value, size: 24)),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.label())),
          Text(value, style: AppText.body().copyWith(color: AppColors.maroon, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = (_summary?['upcoming'] as List<dynamic>?) ?? [];
    final today = _summary?['date'] as String? ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(DateTime.parse(today));

    if (_loading) return mfLoadingScreen();

    final totalBookings = _summary?['totalBookings'] as int? ?? 0;
    final hasBookings = totalBookings > 0 || upcoming.isNotEmpty;

    final content = PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exit MarqueeFlow?'),
            content: const Text('Do you want to close the app?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Exit')),
            ],
          ),
        );
        if (exit == true) SystemNavigator.pop();
      },
      child: MfScreenShell(
      title: 'Home Dashboard',
      subtitle: 'Today, upcoming events, and quick actions.',
      notificationCount: _notificationCount,
      endDrawer: buildMfDrawer(widget.api, '/home'),
      child: RefreshIndicator(
        color: AppColors.maroon,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (_error != null) ...[
              MfErrorBanner(_error!),
              const SizedBox(height: 12),
            ],
          MfCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${_userName ?? 'there'}', style: AppText.display('Hello', size: 24)),
                      const SizedBox(height: 4),
                      Text(formattedDate, style: AppText.body()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.gold),
                  ),
                  child: Text('Today', style: AppText.label().copyWith(color: AppColors.maroon)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard('Today', '${_summary?['todayCount'] ?? _summary?['todayBookings'] ?? 0}'),
              const SizedBox(width: 12),
              _statCard('Upcoming', '${_summary?['upcomingCount'] ?? _summary?['upcomingEvents'] ?? 0}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard('Slots today', '${_summary?['availableSlotsToday'] ?? _summary?['availableSlots'] ?? 0}'),
              const SizedBox(width: 12),
              _statCard('Payment pending', '${_summary?['pendingPayments'] ?? _summary?['paymentPending'] ?? 0}'),
            ],
          ),
          const SizedBox(height: 16),
          MfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking overview', style: AppText.display('Booking overview', size: 20)),
                _statRow('Total bookings', '${_summary?['totalBookings'] ?? 0}'),
                _statRow('Pending bookings', '${_summary?['pendingBookings'] ?? 0}'),
                _statRow('Confirmed bookings', '${_summary?['confirmedBookings'] ?? 0}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MfQuickActions(
            actions: [
              (label: 'Add Booking', icon: Icons.add, onTap: () => context.push('/calendar')),
              (label: 'View Bookings', icon: Icons.list_alt, onTap: () => context.push('/bookings')),
              (label: 'Packages', icon: Icons.inventory_2_outlined, onTap: () => context.push('/packages')),
              (label: 'Payments', icon: Icons.payments_outlined, onTap: () => context.push('/payments')),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasBookings)
            MfEmptyState(
              title: 'No bookings yet',
              message: 'Start by creating your first booking.',
              actionLabel: 'Add New Booking',
              onAction: () => context.push('/calendar'),
            )
          else
            MfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming events', style: AppText.display('Upcoming events', size: 22)),
                  const SizedBox(height: 12),
                  if (upcoming.isEmpty)
                    Text('No upcoming events scheduled', style: AppText.body())
                  else
                    ...upcoming.map((raw) {
                      final b = raw as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => context.push('/bookings/${b['id']}'),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${b['customerName']} · ${b['eventDate']}', style: AppText.label()),
                              ),
                              StatusBadge(label: b['status'] as String? ?? 'pending'),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          const SizedBox(height: 16),
          MfPrimaryButton(label: 'Add New Booking', icon: Icons.add, onPressed: () => context.push('/calendar')),
          const SizedBox(height: 24),
        ],
        ),
      ),
      ),
    );

    return content;
  }
}
