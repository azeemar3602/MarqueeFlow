import 'package:flutter_test/flutter_test.dart';
import 'package:marqueeflow/main.dart';

void main() {
  testWidgets('MarqueeFlow app renders booking title', (tester) async {
    await tester.pumpWidget(const MarqueeFlowApp());
    expect(find.text('MarqueeFlow Booking'), findsOneWidget);
  });
}
