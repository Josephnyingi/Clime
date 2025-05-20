import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anga/main.dart';

void main() {
  testWidgets('App starts on LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AngaApp(),
      ),
    );

    await tester.pumpAndSettle(); // Ensure animations are done

    // 🔍 Change this to match actual Login screen content
    expect(find.textContaining('Login'), findsOneWidget);
  });
}
