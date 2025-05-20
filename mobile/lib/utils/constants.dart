import 'package:flutter/material.dart';

/// 🌍 **API Configuration**
///
/// Use the correct URL depending on where you're running your backend:
///
/// 📱 **Android Emulator** (accesses host machine):
///   👉 http://10.0.2.2:8000
///
/// 💻 **Windows Desktop app** (use local host directly):
///   👉 http://127.0.0.1:8000
///
/// 🌐 **Production Deployment** (e.g., live server):
///   👉 Replace with your actual server IP/domain

const String API_BASE_URL = "http://10.0.2.2:8000"; // ✅ Emulator access to FastAPI on Windows

/// **🔗 API Endpoints**
const String LOGIN_API = "$API_BASE_URL/login/";
const String REGISTER_API = "$API_BASE_URL/users/";
const String WEATHER_PREDICT_API = "$API_BASE_URL/predict/";
const String SAVE_PREDICTION_API = "$API_BASE_URL/save_prediction/";

/// 🎨 **Theme Colors**
const Color primaryColor = Color(0xFF007ACC);       // 🔹 Modern blue for branding
const Color secondaryColor = Color(0xFF00A896);     // 🔹 Teal accent
const Color backgroundColor = Color(0xFFF5F5F5);    // 🔹 Light gray background

/// 🛠 **Alert Colors**
const Color alertHeatwaveColor = Colors.redAccent;     // 🔥 Heatwave
const Color alertFloodColor = Colors.blueAccent;       // 🌊 Flood
const Color alertStormColor = Colors.orangeAccent;     // ⛈️ Storm

/// 🌡️ **Default Weather Settings**
const String defaultLocation = "Machakos";
const bool defaultIsCelsius = true;
const bool defaultIsMillimeters = true;
const bool defaultEnableNotifications = true;
const bool defaultEnableExtremeAlerts = true;

/// 📢 **Alert Types**
const List<String> alertTypes = [
  "Heatwave",
  "Heavy Rainfall",
  "Storm Warning",
];

/// 🏗 **Feature Toggles**
const bool enableMLModelIntegration = true;     // 🤖 AI forecasting
const bool enableUserFeedback = true;           // 📝 Feedback form
const bool enableMultiLanguageSupport = false;  // 🌍 Future internationalization
