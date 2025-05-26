import 'dart:convert';
import 'dart:io'; // 👈 For platform check
import 'package:http/http.dart' as http;

class WeatherService {
  late final String baseUrl;
  WeatherService() {
    // Set base URL based on platform
 if (Platform.isAndroid) {
  baseUrl = "http://10.0.2.2:8000"; // ✅ for Android emulator
} else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
  baseUrl = "http://127.0.0.1:8000"; // ✅ for desktop testing
} else {
  baseUrl = "http://192.168.X.X:8000"; // ✅ real device
}
  }
  
  /// Fetch future forecast using /predict/ endpoint
  Future<WeatherForecast?> getForecast(String date, String location) async {
    final response = await http.post(
      Uri.parse("$baseUrl/predict/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"date": date, "location": location}),
    );

    if (response.statusCode == 200) {
      return WeatherForecast.fromJson(jsonDecode(response.body));
    } else {
      print("❌ Forecast Error: ${response.body}");
      return null;
    }
  }

  /// Fetch today's weather using /live_weather/ endpoint
  Future<WeatherForecast?> getLiveWeather(String location) async {
    final response = await http.get(
      Uri.parse("$baseUrl/live_weather/?location=$location"),
    );

    if (response.statusCode == 200) {
      return WeatherForecast.fromJson(jsonDecode(response.body));
    } else {
      print("❌ Live Weather Error: ${response.body}");
      return null;
    }
  }

  static getWeather(String date, String selectedLocation) {}
}

class WeatherForecast {
  static Future<WeatherForecast?> fromJson(jsonDecode) async {
    return null;
  }
}
