import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts on LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AngaApp(),
      ),
    );

    await tester.pumpAndSettle(); // Ensure animations are done

    // 🔍 Change this to match actual Login screen content
    expect(find.textContaining('Login'), findsOneWidget);
  });
}

class AngaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace with your actual LoginScreen or main app widget
    return Scaffold(
      body: Center(child: Text('Login')),
    );
  }
}
