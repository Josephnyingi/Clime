import 'package:flutter/material.dart';

/// 🌍 **API Configuration**
/// Update this to your actual API server URL
/// Replace `127.0.0.1` with your public server address if deployed
const String API_BASE_URL = "http://10.0.2.2:8000"; // 🔹 Emulator access to local server

/// **🔗 API Endpoints**
const String LOGIN_API = "$API_BASE_URL/login/";                 // ✅ Login Endpoint
const String REGISTER_API = "$API_BASE_URL/users/";              // ✅ User Registration
const String WEATHER_PREDICT_API = "$API_BASE_URL/predict/";     // ✅ Weather Prediction
const String SAVE_PREDICTION_API = "$API_BASE_URL/save_prediction/"; // ✅ Save Predictions


/// 🎨 **Theme Colors**
const Color primaryColor = Color(0xFF007ACC); // 🔹 Modern blue for primary branding
const Color secondaryColor = Color(0xFF00A896); // 🔹 Light teal for accents
const Color backgroundColor = Color(0xFFF5F5F5); // 🔹 Light gray background for a clean UI

/// 🛠 **Alert Colors**
const Color alertHeatwaveColor = Colors.redAccent; // 🔥 Heatwave alert
const Color alertFloodColor = Colors.blueAccent; // 🌊 Flood alert
const Color alertStormColor = Colors.orangeAccent; // ⛈ Storm alert

/// 🌡 **Default Weather Settings**
const String defaultLocation = "Machakos"; // 📍 Default weather location
const bool defaultIsCelsius = true; // 🌡 Default temperature unit
const bool defaultIsMillimeters = true; // ☔ Default rainfall unit
const bool defaultEnableNotifications = true; // 🔔 Enable general notifications
const bool defaultEnableExtremeAlerts = true; // 🚨 Enable extreme weather alerts

/// 📢 **Alert Types**
const List<String> alertTypes = [
  "Heatwave",
  "Heavy Rainfall",
  "Storm Warning",
];

/// 🔑 **Shared Preferences Keys** (for saving user settings locally)
const String prefKeyLocation = "location"; // 📍 User's selected location
const String prefKeyIsCelsius = "isCelsius"; // 🌡 Preferred temperature unit
const String prefKeyIsMillimeters = "isMillimeters"; // ☔ Preferred rainfall unit
const String prefKeyEnableNotifications = "enableNotifications"; // 🔔 Notifications toggle
const String prefKeyEnableExtremeAlerts = "enableExtremeAlerts"; // 🚨 Extreme alerts toggle
const String prefKeyIsDarkMode = "isDarkMode"; // 🌙 Dark mode setting
const String prefKeyStartDate = "startDate"; // 📅 Start date for weather data
const String prefKeyEndDate = "endDate"; // 📅 End date for weather data
const String prefKeyEnableAlerts = "enableAlerts"; // 🚨 General alert toggle

/// 🏗 **App Feature Toggles** (Enable/Disable Features)
const bool enableMLModelIntegration = true; // 🤖 Enable AI weather forecasting
const bool enableUserFeedback = true; // 📝 Enable user feedback collection
const bool enableMultiLanguageSupport = false; // 🌍 Enable multi-language UI (Future feature)
