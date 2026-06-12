import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marqueeflow/main.dart';
import 'package:marqueeflow/services/api_service.dart';

void main() {
  testWidgets('MarqueeFlow app shell loads', (tester) async {
    await tester.pumpWidget(MarqueeFlowApp(api: MarqueeFlowApi()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsNothing);
    expect(find.byType(MaterialApp.router), findsOneWidget);
  });
}
