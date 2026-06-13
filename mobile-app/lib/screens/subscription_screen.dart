import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<dynamic> _plans = [];
  Map<String, dynamic>? _status;
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
      final plans = await widget.api.fetchPlans();
      final status = await widget.api.fetchSubscriptionStatus();
      setState(() {
        _plans = plans;
        _status = status;
      });
    } catch (e) {
      setState(() => _error = mapRequestError(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startTrial() async {
    final standard = _plans.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p?['isRecommended'] == true || p?['id'] == 'standard',
          orElse: () => _plans.isNotEmpty ? _plans.first as Map<String, dynamic> : null,
        );
    if (standard == null) return;
    await _selectPlan(standard);
  }

  Future<void> _showCustomPlanForm() async {
    final sizeCtrl = TextEditingController(text: '10');
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    try {
      final me = await widget.api.fetchMe();
      nameCtrl.text = me['user']?['name'] as String? ?? '';
      phoneCtrl.text = me['user']?['phone'] as String? ?? '';
    } catch (_) {}

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: Text('Request Custom Plan', style: AppText.display('Request Custom Plan', size: 22)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('For teams above 6 persons. Our team will contact you with custom pricing.', style: AppText.body()),
              const SizedBox(height: 12),
              MfTextField(label: 'Requested team size', iconLetter: 'T', controller: sizeCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              MfTextField(label: 'Contact name', iconLetter: 'N', controller: nameCtrl),
              const SizedBox(height: 12),
              MfTextField(label: 'Phone number', iconLetter: 'P', controller: phoneCtrl, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              MfTextField(label: 'Note (optional)', iconLetter: 'T', controller: noteCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.api.requestCustomPlan(
                  requestedTeamSize: int.parse(sizeCtrl.text),
                  contactName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Custom plan request submitted. We will contact you soon.')),
                    );
                  }
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(mapRequestError(e).message)));
                }
              }
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPlan(Map<String, dynamic> plan) async {
    if (plan['requestCustom'] == true) {
      await _showCustomPlanForm();
      return;
    }
    try {
      await widget.api.startTrial(plan['id'] as String);
      await widget.api.checkoutPlan(plan['id'] as String);
      if (!mounted) return;
      context.go('/home');
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapRequestError(e).message)));
    }
  }

  Color _planAccent(Map<String, dynamic> plan) {
    final limit = plan['userLimit'] as int? ?? 1;
    if (limit <= 1) return AppColors.soloAccent;
    return AppColors.teamAccent;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return mfLoadingScreen();

    return MfScreenShell(
      title: 'Subscription Plans',
      subtitle: 'Pakistan pricing in PKR',
      endDrawer: buildMfDrawer(widget.api, '/subscription'),
      onBack: () => mfGoBack(context, fallback: '/home'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_status != null)
            MfCard(
              child: Text('Current status: ${_status!['status'] ?? 'none'}', style: AppText.body()),
            ),
          if (_error != null) ...[MfErrorBanner(_error!), const SizedBox(height: 16)],
          ..._plans.map((raw) {
            final plan = raw as Map<String, dynamic>;
            final custom = plan['requestCustom'] == true;
            final recommended = plan['isRecommended'] == true;
            final features = (plan['features'] as List<dynamic>?) ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MfCard(
                highlighted: recommended,
                badge: recommended ? 'RECOMMENDED' : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _planAccent(plan),
                          child: Text('${plan['userLimit'] ?? '∞'}', style: AppText.label()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plan['name'] as String? ?? 'Plan', style: AppText.display(plan['name'] as String? ?? 'Plan', size: 22)),
                              Text(
                                custom ? 'Request custom pricing' : 'PKR ${plan['pricePkr'] ?? plan['priceMonthly']} / month',
                                style: AppText.body(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (features.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: AppColors.maroon),
                              const SizedBox(width: 8),
                              Expanded(child: Text('$f', style: AppText.body())),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    MfPrimaryButton(
                      label: custom ? 'Request Custom Plan' : 'Choose Plan',
                      onPressed: () => _selectPlan(plan),
                    ),
                  ],
                ),
              ),
            );
          }),
          MfPrimaryButton(label: 'Start Free Trial', onPressed: _startTrial),
          const MfCaption('No credit card required • Upgrade anytime'),
        ],
      ),
    );
  }
}
