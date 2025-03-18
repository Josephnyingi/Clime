import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/helpers.dart'; // ✅ Import Helpers

class WeatherService {
  static const String _apiUrl = "$API_BASE_URL/predict/";

  /// **🔹 Fetch Weather Data**
  static Future<Map<String, dynamic>> getWeather(String date, String location) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "date": formatApiDate(DateTime.parse(date)), // ✅ Format API Date
          "location": location,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      logMessage("Error fetching weather data: $e"); // ✅ Use helper function for logging
      return {"temperature_prediction": -999, "rain_prediction": -999}; // ✅ Default error values
    }
  }
}
