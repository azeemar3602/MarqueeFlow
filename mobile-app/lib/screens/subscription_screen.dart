import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

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
  final _customSizeCtrl = TextEditingController(text: '7');
  final _customNameCtrl = TextEditingController();
  final _customPhoneCtrl = TextEditingController();
  final _customNoteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _customSizeCtrl.dispose();
    _customNameCtrl.dispose();
    _customPhoneCtrl.dispose();
    _customNoteCtrl.dispose();
    super.dispose();
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
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectPlan(Map<String, dynamic> plan) async {
    if (plan['requestCustom'] == true) {
      _showCustomDialog();
      return;
    }
    try {
      await widget.api.startTrial(plan['id'] as String);
      await widget.api.checkoutPlan(plan['id'] as String);
      if (!mounted) return;
      context.go('/home');
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _showCustomDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Custom Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('For teams above 6 persons, submit a custom plan request.'),
              const SizedBox(height: 12),
              TextField(
                controller: _customSizeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Requested team size'),
              ),
              TextField(controller: _customNameCtrl, decoration: const InputDecoration(labelText: 'Contact name')),
              TextField(
                controller: _customPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: _customNoteCtrl,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.api.requestCustomPlan(
                  requestedTeamSize: int.parse(_customSizeCtrl.text),
                  contactName: _customNameCtrl.text.trim(),
                  phone: _customPhoneCtrl.text.trim(),
                  note: _customNoteCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Custom plan request submitted')),
                  );
                }
              } on ApiException catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.message)));
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_status != null)
                  Card(
                    child: ListTile(
                      title: Text('Current: ${_status!['plan']?['name'] ?? _status!['planId'] ?? 'None'}'),
                      subtitle: Text('Status: ${_status!['status'] ?? 'unknown'}'),
                    ),
                  ),
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                const Text('Choose a PKR plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._plans.map((plan) {
                  final custom = plan['requestCustom'] == true;
                  final recommended = plan['recommended'] == true;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(plan['name'] as String? ?? 'Plan'),
                          if (recommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Recommended', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        custom
                            ? 'Request custom plan for 6+ team members'
                            : 'PKR ${plan['pricePkr'] ?? plan['priceMonthly']} / month · ${plan['userLimit']} person(s)',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _selectPlan(plan as Map<String, dynamic>),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
