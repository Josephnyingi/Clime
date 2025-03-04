import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anga/main.dart';

void main() {
  testWidgets('App starts on LoginScreen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const AngaApp());

    // Verify that the login screen is shown
    expect(find.text('Login'), findsOneWidget);
  });
}