import 'package:flutter_test/flutter_test.dart';
import 'package:digital_ai_guide/main.dart';

void main() {
  testWidgets('App should build', (WidgetTester tester) async {
    await tester.pumpWidget(const DigitalAIGuideApp());
    expect(find.text('Digital AI Guide'), findsOneWidget);
  });
}
