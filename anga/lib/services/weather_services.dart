class WeatherService {
  static Future<Map<String, dynamic>> getWeather(String date, String location) async {
    // Simulated API response
    await Future.delayed(Duration(seconds: 1));  // Simulate network delay
    return {
      "temperature_prediction": 28.5,
      "rain_prediction": 5.2,
    };
  }
}
