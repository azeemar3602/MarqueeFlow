import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../utils/auth_routing.dart';
import '../widgets/mf_components.dart';

enum AccountRole { owner, manager, staff }

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, required this.api, this.inviteToken});

  final MarqueeFlowApi api;
  final String? inviteToken;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  AccountRole? _role;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  Map<String, dynamic>? _invite;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.inviteToken != null) {
      _tokenCtrl.text = widget.inviteToken!;
      _role = AccountRole.manager;
      _loadInvite(widget.inviteToken!);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _businessCtrl.dispose();
    _addressCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInvite(String token) async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.fetchInviteByToken(token);
      final invite = res['invite'] as Map<String, dynamic>;
      setState(() {
        _invite = invite;
        _nameCtrl.text = invite['name'] as String? ?? '';
        _phoneCtrl.text = invite['phone'] as String? ?? '';
        _role = invite['role'] == 'head_waiter' ? AccountRole.staff : AccountRole.manager;
      });
    } catch (e) {
      setState(() => _error = mapRequestError(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitOwner() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.registerOwner(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passCtrl.text,
        businessName: _businessCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      );
      if (!mounted) return;
      context.go(await resolveAuthenticatedRoute(widget.api));
    } catch (e) {
      setState(() => _error = mapRequestError(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitInvite() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Invite token is required.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.acceptInvite(token: token, password: _passCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please sign in.')),
      );
      context.go('/login');
    } catch (e) {
      setState(() => _error = mapRequestError(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _roleCard(AccountRole role, String title, String subtitle, IconData icon) {
    final selected = _role == role;
    return MfCard(
      child: InkWell(
        onTap: _loading
            ? null
            : () => setState(() {
                  _role = role;
                  _error = null;
                }),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected ? AppColors.maroon : AppColors.goldLight,
              child: Icon(icon, color: selected ? Colors.white : AppColors.maroon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.label()),
                  Text(subtitle, style: AppText.body()),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: AppColors.maroon),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MfAuthShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Account', style: AppText.display('Create Account', size: 30)),
          const SizedBox(height: 8),
          Text('Choose your role to continue registration.', style: AppText.body()),
          const SizedBox(height: 20),
          _roleCard(AccountRole.owner, 'Owner', 'Register a new business account', Icons.storefront_outlined),
          const SizedBox(height: 12),
          _roleCard(AccountRole.manager, 'Manager', 'Join via owner invitation', Icons.manage_accounts_outlined),
          const SizedBox(height: 12),
          _roleCard(AccountRole.staff, 'Waiter Head', 'Join via owner invitation', Icons.groups_outlined),
          if (_role == AccountRole.owner) ...[
            const SizedBox(height: 20),
            Text('Owner registration', style: AppText.display('Owner registration', size: 20)),
            const SizedBox(height: 12),
            MfTextField(label: 'Full name', iconLetter: 'N', controller: _nameCtrl, enabled: !_loading),
            const SizedBox(height: 12),
            MfTextField(label: 'Phone number', iconLetter: 'P', controller: _phoneCtrl, keyboardType: TextInputType.phone, enabled: !_loading),
            const SizedBox(height: 12),
            MfTextField(label: 'Password', iconLetter: 'S', controller: _passCtrl, obscureText: true, enabled: !_loading),
            const SizedBox(height: 12),
            MfTextField(label: 'Business name', iconLetter: 'B', controller: _businessCtrl, enabled: !_loading),
            const SizedBox(height: 12),
            MfTextField(label: 'Address (optional)', iconLetter: 'A', controller: _addressCtrl, enabled: !_loading),
            const SizedBox(height: 16),
            MfPrimaryButton(label: 'Create Owner Account', loading: _loading, onPressed: _submitOwner),
          ],
          if (_role == AccountRole.manager || _role == AccountRole.staff) ...[
            const SizedBox(height: 20),
            MfCard(
              child: Text(
                'Manager and Waiter Head accounts require an owner invitation. Enter your invite token below.',
                style: AppText.body(),
              ),
            ),
            const SizedBox(height: 12),
            MfTextField(label: 'Invite token', iconLetter: 'T', controller: _tokenCtrl, enabled: !_loading),
            const SizedBox(height: 12),
            if (_invite != null) ...[
              MfTextField(label: 'Full name', iconLetter: 'N', controller: _nameCtrl, enabled: false),
              const SizedBox(height: 12),
              MfTextField(label: 'Phone number', iconLetter: 'P', controller: _phoneCtrl, enabled: false),
            ],
            const SizedBox(height: 12),
            MfTextField(label: 'Create password', iconLetter: 'S', controller: _passCtrl, obscureText: true, enabled: !_loading),
            const SizedBox(height: 16),
            MfPrimaryButton(
              label: 'Accept Invite',
              loading: _loading,
              onPressed: () {
                if (_tokenCtrl.text.trim().isEmpty) {
                  setState(() => _error = 'Please ask your owner to invite you.');
                  return;
                }
                if (_invite == null) {
                  _loadInvite(_tokenCtrl.text.trim()).then((_) {
                    if (_invite != null) _submitInvite();
                  });
                } else {
                  _submitInvite();
                }
              },
            ),
          ],
          if (_error != null) ...[const SizedBox(height: 16), MfErrorBanner(_error!)],
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : () => context.go('/login'),
            child: Text('Already have an account? Sign in', style: AppText.label().copyWith(color: AppColors.maroon)),
          ),
        ],
      ),
    );
  }
}
