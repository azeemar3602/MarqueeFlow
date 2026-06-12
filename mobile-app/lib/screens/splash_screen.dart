import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await widget.api.loadToken();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final token = await widget.api.fetchMe().then((_) => true).catchError((_) => false);
    if (!mounted) return;
    if (!token) {
      context.go('/login');
      return;
    }
    try {
      final sub = await widget.api.fetchSubscriptionStatus();
      final status = sub['status'] as String? ?? 'none';
      final active = status == 'trial' || status == 'active';
      if (!mounted) return;
      context.go(active ? '/home' : '/subscription');
    } catch (_) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientLight, AppColors.gradientDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.celebration, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'MarqueeFlow',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage. Book. Celebrate.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
