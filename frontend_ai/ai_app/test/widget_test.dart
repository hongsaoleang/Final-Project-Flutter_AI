import 'package:flutter_test/flutter_test.dart';
import 'package:ai_app/main.dart';

void main() {
  testWidgets('MyAI App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyAIApp());
    expect(find.text('MyAI Multimodal Platform'), findsOneWidget);
  });
}
