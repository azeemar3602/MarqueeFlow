import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../utils/auth_routing.dart';
import '../widgets/mf_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _remember = true;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneCtrl.text.trim();
    final password = _passCtrl.text;
    if (phone.isEmpty || password.isEmpty) {
      setState(() => _error = 'Phone number and password are required.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.login(phone: phone, password: password, remember: _remember);
      if (!mounted) return;
      context.go(await resolveAuthenticatedRoute(widget.api));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = mapRequestError(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MfAuthShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sign In', style: AppText.display('Sign In', size: 30)),
          const SizedBox(height: 8),
          Text('Sign in with your phone number and password.', style: AppText.body()),
          const SizedBox(height: 24),
          MfTextField(
            label: 'Phone number',
            iconLetter: 'P',
            controller: _phoneCtrl,
            hint: 'Enter Pakistani mobile number',
            keyboardType: TextInputType.phone,
            enabled: !_loading,
          ),
          const SizedBox(height: 16),
          MfTextField(
            label: 'Password',
            iconLetter: 'S',
            controller: _passCtrl,
            hint: 'Enter your password',
            obscureText: _obscure,
            enabled: !_loading,
            onSubmitted: (_) => _submit(),
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: _remember,
                  onChanged: _loading ? null : (v) => setState(() => _remember = v ?? true),
                  title: Text('Remember me', style: AppText.body()),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
              ),
              TextButton(
                onPressed: _loading ? null : () => context.push('/forgot-password'),
                child: Text('Forgot password?', style: AppText.label().copyWith(color: AppColors.maroon)),
              ),
            ],
          ),
          if (_error != null) ...[MfErrorBanner(_error!), const SizedBox(height: 16)],
          MfPrimaryButton(label: 'Sign In', loading: _loading, onPressed: _submit),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loading ? null : () => context.push('/register'),
            child: const Text('Create New Account'),
          ),
        ],
      ),
    );
  }
}
