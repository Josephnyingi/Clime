import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/app_state.dart'; // ✅ new shared state

class SettingsScreen extends StatefulWidget {
  final Function(bool) setTheme;

  const SettingsScreen({super.key, required this.setTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> locations = [
    "Machakos",
    "Vhembe",
  ];

  @override
  void initState() {
    super.initState();
    // Nothing to load now, all from AppState
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: AppState.startDate, end: AppState.endDate),
    );

    if (picked != null) {
      setState(() {
        AppState.startDate = picked.start;
        AppState.endDate = picked.end;
      });
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
              value: AppState.selectedLocation,
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  AppState.selectedLocation = newValue!;
                });
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
              title: Text("From: ${DateFormat('yyyy-MM-dd').format(AppState.startDate)}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateRange,
            ),
            ListTile(
              title: Text("To: ${DateFormat('yyyy-MM-dd').format(AppState.endDate)}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateRange,
            ),

            const SizedBox(height: 20),

            _buildSwitchTile("Use Celsius (°C)", AppState.isCelsius, (value) {
              setState(() => AppState.isCelsius = value);
            }),

            const SizedBox(height: 20),

            _buildSwitchTile("Use Millimeters (mm)", AppState.isMillimeters, (value) {
              setState(() => AppState.isMillimeters = value);
            }),

            const SizedBox(height: 20),

            _buildSwitchTile("Enable Dark Mode", AppState.isDarkMode, (value) {
              setState(() {
                AppState.isDarkMode = value;
              });
              widget.setTheme(value);
            }),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings applied successfully")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Apply Settings"),
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
