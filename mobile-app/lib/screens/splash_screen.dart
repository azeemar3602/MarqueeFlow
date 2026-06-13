import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/auth_routing.dart';
import '../widgets/mf_components.dart';

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
      if (!mounted) return;
      context.go(await resolveAuthenticatedRoute(widget.api));
    } catch (_) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          Positioned(top: -40, right: -30, child: _floral(120, AppColors.goldLight.withValues(alpha: 0.45))),
          Positioned(top: 80, left: -20, child: _floral(80, AppColors.soloAccent.withValues(alpha: 0.5))),
          Positioned(bottom: 120, right: 20, child: _floral(90, AppColors.gold.withValues(alpha: 0.2))),
          Positioned(bottom: -30, left: -40, child: _floral(140, AppColors.maroon.withValues(alpha: 0.08))),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                const MfLogo(size: 96),
                const SizedBox(height: 20),
                Text('MarqueeFlow', style: AppText.brandName(size: 34)),
                const SizedBox(height: 8),
                Text('Manage. Book. Celebrate.', style: AppText.body().copyWith(fontSize: 16)),
                const Spacer(flex: 2),
                const CircularProgressIndicator(color: AppColors.maroon),
                const SizedBox(height: 24),
                const MfScreenFooter(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _floral(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35), width: 2),
      ),
    );
  }
}
