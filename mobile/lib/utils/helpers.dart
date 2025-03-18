import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

/// **✅ Format API Date (YYYY-MM-DD)**
String formatApiDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

/// **✅ Format Date for UI (MM/DD/YYYY)**
String formatDate(DateTime date) {
  return DateFormat('MM/dd/yyyy').format(date);
}

/// **✅ Convert Millimeters to Inches**
double mmToInches(double mm) {
  return mm / 25.4;
}

/// **✅ Safe Logging for Debug Mode**
void logMessage(String message) {
  if (kDebugMode) {
    print(message);
  }
}
