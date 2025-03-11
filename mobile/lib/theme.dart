import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF00695C),
    scaffoldBackgroundColor: Color(0xFFE0F2F1),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black), // Old: headline1
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black), // Equivalent to headline2
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black54), // Equivalent to bodyText1
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54), // Equivalent to bodyText2
    ),
    buttonTheme: const ButtonThemeData(buttonColor: Color(0xFF00695C)),
  );
}
