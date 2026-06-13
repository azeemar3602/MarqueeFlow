import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/auth_routing.dart';
import '../widgets/mf_components.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  String _title = 'Awaiting Approval';
  String _message =
      'Your business registration is pending Super Admin approval. You will get full access once approved.';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final me = await widget.api.fetchMe();
      final business = me['business'] as Map<String, dynamic>?;
      final approval = business?['approvalStatus'] as String?;
      final status = business?['status'] as String?;
      if (!mounted) return;
      setState(() {
        if (approval == 'rejected') {
          _title = 'Registration Rejected';
          _message =
              'Your business registration was rejected. Contact MarqueeFlow support if you believe this is a mistake.';
        } else if (approval == 'suspended' || status == 'suspended') {
          _title = 'Account Suspended';
          _message = 'Your business account is suspended. Contact MarqueeFlow support for assistance.';
        } else {
          _title = 'Awaiting Approval';
          _message =
              'Your business registration is pending Super Admin approval. You will get full access once approved.';
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MfAuthShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.maroon),
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ),
          const SizedBox(height: 8),
          Text(_title, style: AppText.display(_title, size: 28)),
          const SizedBox(height: 12),
          MfCard(
            child: Text(_message, style: AppText.body()),
          ),
          const SizedBox(height: 20),
          MfPrimaryButton(
            label: 'Refresh Status',
            onPressed: () async {
              try {
                await _loadStatus();
                if (context.mounted) context.go(await resolveAuthenticatedRoute(widget.api));
              } catch (_) {}
            },
          ),
        ],
      ),
    );
  }
}
