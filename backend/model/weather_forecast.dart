class WeatherForecast {
  final String date;
  final String location;
  final double temperature;
  final double rain;
  final String source;

  WeatherForecast({
    required this.date,
    required this.location,
    required this.temperature,
    required this.rain,
    required this.source,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: json['date'],
      location: json['location'],
      temperature: (json['temperature_prediction'] ?? json['temperature_max']).toDouble(),
      rain: (json['rain_prediction'] ?? json['rain_sum']).toDouble(),
      source: json['source'] ?? "live-weather", // fallback for live data
    );
  }
}
