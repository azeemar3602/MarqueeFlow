import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/api_errors.dart';
import '../widgets/mf_components.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Phone number is required.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await widget.api.requestPasswordReset(phone);
      setState(() => _success = 'If an account exists for this number, reset instructions will be sent.');
    } catch (e) {
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
          Text('Forgot Password', style: AppText.display('Forgot Password', size: 30)),
          const SizedBox(height: 8),
          Text('Enter your phone number and we will send reset instructions if the account exists.', style: AppText.body()),
          const SizedBox(height: 24),
          MfTextField(
            label: 'Phone number',
            iconLetter: 'P',
            controller: _phoneCtrl,
            hint: 'Enter Pakistani mobile number',
            keyboardType: TextInputType.phone,
            enabled: !_loading,
          ),
          if (_error != null) ...[const SizedBox(height: 16), MfErrorBanner(_error!)],
          if (_success != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.teamAccent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold),
              ),
              child: Text(_success!, style: AppText.body().copyWith(color: AppColors.text)),
            ),
          ],
          const SizedBox(height: 20),
          MfPrimaryButton(label: 'Send Reset Link', loading: _loading, onPressed: _submit),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : () => context.go('/login'),
            child: Text('Back to Sign In', style: AppText.label().copyWith(color: AppColors.maroon)),
          ),
        ],
      ),
    );
  }
}
