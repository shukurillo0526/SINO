/// SINO - Widget Tests
/// 
/// Basic widget tests for the SINO application.
/// 
/// @author SINO Team
/// @version 1.3.0

import 'package:flutter_test/flutter_test.dart';
import 'package:sino/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SinoApp());

    // Verify that the app title is present
    expect(find.text('SINO'), findsWidgets);
  });
}
