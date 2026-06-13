import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'mf_components.dart';

class MfAppDrawer extends StatelessWidget {
  const MfAppDrawer({super.key, required this.api, this.current});

  final MarqueeFlowApi api;
  final String? current;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('Home Dashboard', '/home', Icons.home_outlined),
      _NavItem('Calendar & Slots', '/calendar', Icons.calendar_month_outlined),
      _NavItem('Bookings', '/bookings', Icons.event_note_outlined),
      _NavItem('Payments', '/payments', Icons.payments_outlined),
      _NavItem('Subscription Plans', '/subscription', Icons.workspace_premium_outlined),
      _NavItem('Customers', '/customers', Icons.people_outline),
      _NavItem('Packages', '/packages', Icons.inventory_2_outlined),
      _NavItem('Profile', '/profile', Icons.person_outline),
      _NavItem('Team Members', '/team', Icons.groups_outlined),
    ];

    return Drawer(
      backgroundColor: AppColors.cream,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const MfLogo(size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MarqueeFlow', style: AppText.brandName(size: 18)),
                        Text('Control menu', style: AppText.body()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: items.map((item) {
                  final active = current == item.route;
                  return ListTile(
                    leading: Icon(item.icon, color: active ? AppColors.maroon : AppColors.textMuted),
                    title: Text(
                      item.label,
                      style: AppText.label().copyWith(
                        color: active ? AppColors.maroon : AppColors.text,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    selected: active,
                    selectedTileColor: AppColors.goldLight.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () {
                      Navigator.pop(context);
                      if (!active) context.go(item.route);
                    },
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await api.logout();
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.route, this.icon);
  final String label;
  final String route;
  final IconData icon;
}

Widget buildMfDrawer(MarqueeFlowApi api, String route) => MfAppDrawer(api: api, current: route);

Widget mfLoadingScreen() {
  return const Scaffold(
    backgroundColor: AppColors.cream,
    body: Center(child: CircularProgressIndicator(color: AppColors.maroon)),
  );
}

void mfGoBack(BuildContext context, {String fallback = '/home'}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}
