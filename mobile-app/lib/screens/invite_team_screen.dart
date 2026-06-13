import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_components.dart';
import '../widgets/mf_navigation.dart';

class InviteTeamScreen extends StatefulWidget {
  const InviteTeamScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<InviteTeamScreen> createState() => _InviteTeamScreenState();
}

class _InviteTeamScreenState extends State<InviteTeamScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _role = 'manager';
  final Map<String, bool> _permissions = {
    'Manage bookings': true,
    'Record payments': false,
    'Package management': false,
    'View reports': false,
    'Assign waiter heads': false,
  };
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final permissions = {
        'manageBookings': _permissions['Manage bookings'] ?? false,
        'managePayments': _permissions['Record payments'] ?? false,
        'managePackages': _permissions['Package management'] ?? false,
        'manageReports': _permissions['View reports'] ?? false,
        'assignWaiterHeads': _permissions['Assign waiter heads'] ?? false,
      };
      await widget.api.inviteTeamMember(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _role,
        permissions: permissions,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite sent')));
      context.pop();
    } catch (e) {
      setState(() => _error = mapRequestError(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MfScreenShell(
      title: 'Invite Team Member',
      endDrawer: buildMfDrawer(widget.api, '/team'),
      onBack: () => mfGoBack(context, fallback: '/team'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MfTextField(label: 'Full Name', iconLetter: 'N', controller: _nameCtrl, hint: 'Enter manager / waiter head name', enabled: !_loading),
          const SizedBox(height: 16),
          MfTextField(label: 'Phone Number', iconLetter: 'P', controller: _phoneCtrl, hint: 'Enter Pakistani mobile number', keyboardType: TextInputType.phone, enabled: !_loading),
          const SizedBox(height: 16),
          Text('Role', style: AppText.label()),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(
              prefixIcon: MfFieldIcon('R'),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            items: const [
              DropdownMenuItem(value: 'manager', child: Text('Manager')),
              DropdownMenuItem(value: 'head_waiter', child: Text('Waiter Head')),
            ],
            onChanged: _loading ? null : (v) => setState(() => _role = v ?? 'manager'),
          ),
          const SizedBox(height: 20),
          Text('Permissions', style: AppText.display('Permissions', size: 20)),
          const SizedBox(height: 8),
          ..._permissions.keys.map(
            (label) => CheckboxListTile(
              value: _permissions[label],
              onChanged: _loading ? null : (v) => setState(() => _permissions[label] = v ?? false),
              title: Text(label, style: AppText.body()),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 12), MfErrorBanner(_error!)],
          const SizedBox(height: 16),
          MfPrimaryButton(label: 'Send Invite', loading: _loading, onPressed: _submit),
          const MfCaption('Invite is blocked if plan member limit is reached'),
        ],
      ),
    );
  }
}
