import 'package:flutter/material.dart';

/// **🌍 API Configuration**
/// Update this to your actual API server URL
const String API_BASE_URL = "http://127.0.0.1:8000"; // 🔹 Change this if running on a real server

/// **🎨 Theme Colors**
const Color primaryColor = Colors.blueAccent;
const Color secondaryColor = Colors.lightBlue;
const Color alertHeatwaveColor = Colors.redAccent;
const Color alertFloodColor = Colors.blueAccent;
const Color alertStormColor = Colors.orangeAccent;

/// **🛠 Default Settings**
const String defaultLocation = "Machakos";
const bool defaultIsCelsius = true;
const bool defaultIsMillimeters = true;
const bool defaultEnableNotifications = true;
const bool defaultEnableExtremeAlerts = true;

/// **📢 Alert Types**
const List<String> alertTypes = [
  "Heatwave",
  "Heavy Rainfall",
  "Storm Warning",
];

/// **🔑 Shared Preferences Keys**
const String prefKeyLocation = "location";
const String prefKeyIsCelsius = "isCelsius";
const String prefKeyIsMillimeters = "isMillimeters";
const String prefKeyEnableNotifications = "enableNotifications";
const String prefKeyEnableExtremeAlerts = "enableExtremeAlerts";
const String prefKeyIsDarkMode = "isDarkMode";
const String prefKeyStartDate = "startDate";
const String prefKeyEndDate = "endDate";
const String prefKeyEnableAlerts = "enableAlerts";

