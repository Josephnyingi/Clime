
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  final Future<void> Function(bool) setTheme;

  const SettingsScreen({super.key, required this.setTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLocation = defaultLocation;
  bool isCelsius = defaultIsCelsius;
  bool isMillimeters = defaultIsMillimeters;
  bool enableNotifications = defaultEnableNotifications;
  bool enableExtremeAlerts = defaultEnableExtremeAlerts;
  bool isDarkMode = false;

  final TextEditingController _searchController = TextEditingController();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));

  final List<String> locations = [
    "Machakos",
    "Vhembe", // ✅ Added new location
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String storedLocation = prefs.getString(prefKeyLocation) ?? defaultLocation;

    setState(() {
      selectedLocation = locations.contains(storedLocation) ? storedLocation : defaultLocation;
      isCelsius = prefs.getBool(prefKeyIsCelsius) ?? defaultIsCelsius;
      isMillimeters = prefs.getBool(prefKeyIsMillimeters) ?? defaultIsMillimeters;
      enableNotifications = prefs.getBool(prefKeyEnableNotifications) ?? defaultEnableNotifications;
      enableExtremeAlerts = prefs.getBool(prefKeyEnableExtremeAlerts) ?? defaultEnableExtremeAlerts;
      isDarkMode = prefs.getBool(prefKeyIsDarkMode) ?? false;
      startDate = DateTime.tryParse(prefs.getString(prefKeyStartDate) ?? '') ?? DateTime.now();
      endDate = DateTime.tryParse(prefs.getString(prefKeyEndDate) ?? '') ?? DateTime.now().add(const Duration(days: 7));
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKeyLocation, selectedLocation);
    await prefs.setBool(prefKeyIsCelsius, isCelsius);
    await prefs.setBool(prefKeyIsMillimeters, isMillimeters);
    await prefs.setBool(prefKeyEnableNotifications, enableNotifications);
    await prefs.setBool(prefKeyEnableExtremeAlerts, enableExtremeAlerts);
    await prefs.setBool(prefKeyIsDarkMode, isDarkMode);
    await prefs.setString(prefKeyStartDate, startDate.toIso8601String());
    await prefs.setString(prefKeyEndDate, endDate.toIso8601String());
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _savePreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle("Preferred Location"),
            DropdownButton<String>(
              value: selectedLocation,
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  selectedLocation = newValue!;
                });
                _savePreferences();
              },
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            _buildSectionTitle("Select Forecast Date Range"),
            ListTile(
              title: Text("From: ${DateFormat('yyyy-MM-dd').format(startDate)}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateRange,
            ),
            ListTile(
              title: Text("To: ${DateFormat('yyyy-MM-dd').format(endDate)}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateRange,
            ),

            const SizedBox(height: 20),

            _buildSwitchTile("Use Celsius (°C)", isCelsius, (value) {
              setState(() => isCelsius = value);
              _savePreferences();
            }),

            const SizedBox(height: 20),

            _buildSwitchTile("Use Millimeters (mm)", isMillimeters, (value) {
              setState(() => isMillimeters = value);
              _savePreferences();
            }),

            const SizedBox(height: 20),

            _buildSwitchTile("Enable Dark Mode", isDarkMode, (value) {
              setState(() => isDarkMode = value);
              widget.setTheme(value);
              _savePreferences();
            }),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Save Settings"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
