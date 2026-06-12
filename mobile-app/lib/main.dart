import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  final api = MarqueeFlowApi();
  runApp(MarqueeFlowApp(api: api));
}

class MarqueeFlowApp extends StatelessWidget {
  const MarqueeFlowApp({super.key, required this.api});

  final MarqueeFlowApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MarqueeFlow',
      theme: buildMarqueeFlowTheme(),
      routerConfig: createAppRouter(api),
    );
  }
}
