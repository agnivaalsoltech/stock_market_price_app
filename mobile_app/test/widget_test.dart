import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('MarketPulse smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MarketPulseApp());
    expect(find.text('MarketPulse'), findsWidgets);
  });
}
