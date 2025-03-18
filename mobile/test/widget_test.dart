import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anga/main.dart';
import 'package:anga/screens/login_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'isLoggedIn': false,
      'isDarkMode': false,
    });
  });

  testWidgets('App starts on LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AngaApp(isLoggedIn: false, initialTheme: false),
      ),
    );

    await tester.pumpAndSettle(); // ✅ Ensure all animations settle

    // ✅ Find only the main Login text instead of multiple 'Login'
    expect(find.textContaining('Welcome Back'), findsOneWidget);
  });
}
