import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';
import 'app_utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('truecaller_api_key');
    if (apiKey != null) {
      _apiKeyController.text = apiKey;
    }
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('truecaller_api_key', _apiKeyController.text);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('API Key', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Truecaller API Key',
                      hintStyle: TextStyle(fontFamily: 'Poppins'),
                      suffixIcon: Icon(Icons.vpn_key),
                    ),
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_apiKeyController.text.isEmpty) {
                        AppUtils.showSnackBar(context, 'Error: Please enter a valid API key.');
                      } else {
                        _saveApiKey();
                        AppUtils.showSnackBar(context, 'Success: API key saved.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Save', style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text('Theme', style: Theme.of(context).textTheme.titleLarge),
                RadioListTile<ThemeMode>(
                  title: const Text('System', style: TextStyle(fontFamily: 'Poppins')),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) => themeProvider.setThemeMode(value!),
                  activeColor: themeProvider.accentColor,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light', style: TextStyle(fontFamily: 'Poppins')),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) => themeProvider.setThemeMode(value!),
                  activeColor: themeProvider.accentColor,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark', style: TextStyle(fontFamily: 'Poppins')),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) => themeProvider.setThemeMode(value!),
                  activeColor: themeProvider.accentColor,
                ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accent Color', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildColorOption(context, const Color(0xFF3B82F6)),
                      _buildColorOption(context, const Color(0xFF10B981)),
                      _buildColorOption(context, const Color(0xFFF43F5E)),
                      _buildColorOption(context, const Color(0xFF8B5CF6)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = themeProvider.accentColor == color;
    return GestureDetector(
      onTap: () => themeProvider.setAccentColor(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
      ),
    );
  }
}