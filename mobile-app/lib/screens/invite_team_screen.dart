import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

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
  bool _manageBookings = true;
  bool _managePayments = true;
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
      final permissions = _role == 'manager'
          ? {
              'manageBookings': _manageBookings,
              'managePayments': _managePayments,
              'manageCustomers': true,
              'manageReports': true,
              'manageTeam': false,
            }
          : {
              'viewAssignedEvents': true,
              'updateOperationalStatus': true,
              'managePayments': false,
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
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Team Member')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Invite Manager or Waiter Head using phone number only.'),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(value: 'manager', child: Text('Manager')),
              DropdownMenuItem(value: 'head_waiter', child: Text('Waiter Head')),
            ],
            onChanged: (v) => setState(() => _role = v ?? 'manager'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Pakistani mobile number'),
          ),
          if (_role == 'manager') ...[
            const SizedBox(height: 16),
            const Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              value: _manageBookings,
              onChanged: (v) => setState(() => _manageBookings = v ?? true),
              title: const Text('Manage bookings'),
            ),
            CheckboxListTile(
              value: _managePayments,
              onChanged: (v) => setState(() => _managePayments = v ?? true),
              title: const Text('Manage payments'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: Text(_loading ? 'Sending...' : 'Send Invite'),
          ),
        ],
      ),
    );
  }
}
