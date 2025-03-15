import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // ✅ Import the constants

class WeatherService {
  static const String _apiUrl = "$API_BASE_URL/predict/"; // ✅ Use API_BASE_URL

  static Future<Map<String, dynamic>> getWeather(String date, String location) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"date": date, "location": location}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error fetching weather data: $e");
      return {"temperature_prediction": -999, "rain_prediction": -999}; // Return error values
    }
  }
}
