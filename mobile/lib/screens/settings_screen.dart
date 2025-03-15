import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required Future<void> Function(bool value) setTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLocation = "Machakos";
  bool isCelsius = true;
  bool isMillimeters = true;
  bool enableNotifications = true;
  bool enableExtremeAlerts = true;
  bool isDarkMode = false;
  final TextEditingController _searchController = TextEditingController();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));

  final List<String> locations = [
    "Machakos", "Nairobi", "Mombasa", "Kisumu", "Eldoret", "Nakuru",
    "Thika", "Nyeri", "Meru", "Kericho", "Embu", "Kakamega", "Kitale",
    "Johannesburg", "Pretoria", "Durban", "Cape Town", "Pietermaritzburg",
    "Nelspruit", "Bloemfontein", "Polokwane", "Mthatha", "Kimberley",
    "Upington", "George", "East London", "Queenstown", "Stellenbosch",
    "Vryburg", "Grahamstown", "Ladysmith", "Middelburg", "Newcastle"
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// **✅ Load user preferences**
  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLocation = prefs.getString('location') ?? "Machakos";
      isCelsius = prefs.getBool('isCelsius') ?? true;
      isMillimeters = prefs.getBool('isMillimeters') ?? true;
      enableNotifications = prefs.getBool('enableNotifications') ?? true;
      enableExtremeAlerts = prefs.getBool('enableExtremeAlerts') ?? true;
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      startDate = DateTime.tryParse(prefs.getString('startDate') ?? '') ?? DateTime.now();
      endDate = DateTime.tryParse(prefs.getString('endDate') ?? '') ?? DateTime.now().add(const Duration(days: 7));
    });
  }

  /// **✅ Save user preferences**
  Future<void> _savePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('location', selectedLocation);
    await prefs.setBool('isCelsius', isCelsius);
    await prefs.setBool('isMillimeters', isMillimeters);
    await prefs.setBool('enableNotifications', enableNotifications);
    await prefs.setBool('enableExtremeAlerts', enableExtremeAlerts);
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setString('startDate', startDate.toIso8601String());
    await prefs.setString('endDate', endDate.toIso8601String());
  }

  /// **✅ Select date range for forecast**
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
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // **Location Search & Selection**
            _buildSectionTitle("Preferred Location"),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search location...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedLocation,
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  selectedLocation = newValue!;
                });
                _savePreferences();
              },
              items: locations
                  .where((loc) => loc.toLowerCase().contains(_searchController.text.toLowerCase()))
                  .map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // **Date Range Picker**
            _buildSectionTitle("Select Forecast Date Range"),
            ListTile(
              title: Text(
                "From: ${DateFormat('yyyy-MM-dd').format(startDate)}",
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateRange,
            ),
            ListTile(
              title: Text(
                "To: ${DateFormat('yyyy-MM-dd').format(endDate)}",
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateRange,
            ),

            const SizedBox(height: 20),

            // **Temperature Unit Toggle**
            _buildSectionTitle("Temperature Unit"),
            SwitchListTile(
              title: const Text("Use Celsius (°C)"),
              value: isCelsius,
              onChanged: (value) {
                setState(() => isCelsius = value);
                _savePreferences();
              },
            ),

            const SizedBox(height: 20),

            // **Rainfall Unit Toggle**
            _buildSectionTitle("Rainfall Unit"),
            SwitchListTile(
              title: const Text("Use Millimeters (mm)"),
              value: isMillimeters,
              onChanged: (value) {
                setState(() => isMillimeters = value);
                _savePreferences();
              },
            ),

            const SizedBox(height: 20),

            // **Notifications Toggle**
            _buildSectionTitle("Notifications"),
            SwitchListTile(
              title: const Text("Enable Weather Updates"),
              value: enableNotifications,
              onChanged: (value) {
                setState(() => enableNotifications = value);
                _savePreferences();
              },
            ),
            SwitchListTile(
              title: const Text("Enable Extreme Weather Alerts"),
              value: enableExtremeAlerts,
              onChanged: (value) {
                setState(() => enableExtremeAlerts = value);
                _savePreferences();
              },
            ),

            const SizedBox(height: 20),

            // **Dark Mode Toggle**
            _buildSectionTitle("Appearance"),
            SwitchListTile(
              title: const Text("Enable Dark Mode"),
              value: isDarkMode,
              onChanged: (value) {
                setState(() => isDarkMode = value);
                _savePreferences();
              },
            ),

            const SizedBox(height: 30),

            // **Save Button**
            ElevatedButton(
              onPressed: () {
                _savePreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings saved successfully!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
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

  /// **Section Title Widget**
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }
}
