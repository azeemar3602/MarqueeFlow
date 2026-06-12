import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _role;
  bool _remember = true;
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  List<dynamic> _roles = [];

  @override
  void initState() {
    super.initState();
    widget.api.fetchRoles().then((r) => setState(() => _roles = r)).catchError((_) {});
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.login(
        phone: _phoneCtrl.text.trim(),
        password: _passCtrl.text,
        role: _role,
        remember: _remember,
      );
      final sub = await widget.api.fetchSubscriptionStatus();
      final status = sub['status'] as String? ?? 'none';
      final active = status == 'trial' || status == 'active';
      context.go(active ? '/home' : '/subscription');
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
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Welcome back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Sign in to manage bookings and events.'),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Any role')),
              ..._roles.map((r) => DropdownMenuItem(
                    value: r['id'] as String,
                    child: Text(r['label'] as String? ?? r['id'] as String),
                  )),
            ],
            onChanged: (v) => setState(() => _role = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone number'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          CheckboxListTile(
            value: _remember,
            onChanged: (v) => setState(() => _remember = v ?? true),
            title: const Text('Remember me'),
            contentPadding: EdgeInsets.zero,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () {}, child: const Text('Forgot password?')),
          ),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
          ],
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: Text(_loading ? 'Signing in...' : 'Sign In'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.push('/register'),
            child: const Text('Create New Account'),
          ),
        ],
      ),
    );
  }
}
