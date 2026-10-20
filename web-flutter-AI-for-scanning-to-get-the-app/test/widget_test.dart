import 'package:flutter_test/flutter_test.dart';
import 'package:scan_get_app/main.dart';

void main() {
  testWidgets('App renders download landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const ScanGetApp());
    expect(find.text('DER LENG AI'), findsWidgets);
  });
}
