import 'package:flutter_test/flutter_test.dart';
import 'package:export_trix/app.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExportTrixApp());

    // Simple smoke test to ensure the app widget builds without crashing
    expect(find.byType(ExportTrixApp), findsOneWidget);
  });
}
