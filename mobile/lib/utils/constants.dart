// lib/utils/constants.dart

/// **API Base URL** - Update this with your actual FastAPI server URL
const String API_BASE_URL = "http://127.0.0.1:8000"; // ✅ Change this if using a remote server

/// **Default values in case of API failure**
const double DEFAULT_TEMPERATURE = -999; // ✅ Use this when API fails
const double DEFAULT_RAINFALL = -999;    // ✅ Use this when API fails

/// **Timeout Duration**
const Duration API_TIMEOUT = Duration(seconds: 10); // ✅ Avoid long waits
