class AppState {
  static String selectedLocation = "Machakos";
  static bool isCelsius = true;
  static bool isMillimeters = true;
  static bool enableNotifications = true;
  static bool enableExtremeAlerts = true;
  static bool isDarkMode = false;

  static DateTime startDate = DateTime.now().subtract(const Duration(days: 6));
  static DateTime endDate = DateTime.now();
}
