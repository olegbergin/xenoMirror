// Basic smoke test for XenoMirror app

import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Note: This test verifies basic app structure only
    // Unity widget tests require additional setup
    await tester.pumpWidget(const XenoApp());

    // Verify app title is present
    expect(find.text('XenoMirror: Link Test'), findsOneWidget);
  });
}
