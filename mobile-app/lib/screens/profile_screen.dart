import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _me;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final me = await widget.api.fetchMe();
      setState(() => _me = me);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return mfLoadingScreen();
    final user = _me?['user'] as Map<String, dynamic>?;
    final business = _me?['business'] as Map<String, dynamic>?;
    final sub = _me?['subscription'] as Map<String, dynamic>?;
    return MfScreenShell(
      title: 'Profile & Settings',
      subtitle: 'Account and business details.',
      endDrawer: buildMfDrawer(widget.api, '/profile'),
      onBack: () => mfGoBack(context, fallback: '/home'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: AppText.display('Account', size: 20)),
                MfDetailRow('Name', user?['name']?.toString()),
                MfDetailRow('Phone', user?['phone']?.toString()),
                MfDetailRow('Role', user?['role']?.toString()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business', style: AppText.display('Business', size: 20)),
                MfDetailRow('Name', business?['businessName']?.toString()),
                MfDetailRow('Phone', business?['phone']?.toString()),
                MfDetailRow('Address', business?['address']?.toString()),
                MfDetailRow('Approval', business?['approvalStatus']?.toString()),
                MfDetailRow('Plan', sub?['plan']?['name']?.toString() ?? sub?['planId']?.toString()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MfPrimaryButton(label: 'Subscription Plans', onPressed: () => context.push('/subscription')),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              await widget.api.logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
