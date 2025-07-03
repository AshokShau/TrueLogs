import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';
import 'truecaller_data.dart';
import 'app_utils.dart';
import 'search_bar.dart';
import 'call_log_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _numberController = TextEditingController();
  TruecallerData? _truecallerData;
  List<CallLogEntry> _callLogs = [];
  bool _isLoading = false;
  String? _errorMessage;
  Set<String> _searchingNumbers = {};

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
  }

  Future<void> _fetchCallLogs() async {
    setState(() => _isLoading = true);
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
      if (!status.isGranted) {
        setState(() {
          _errorMessage = 'Call log permission denied';
          _isLoading = false;
        });
        AppUtils.showSnackBar(context, 'Permission Denied: Call log access is required.');
        return;
      }
    }
    try {
      final entries = await CallLog.get();
      setState(() {
        _callLogs = entries.take(20).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch call logs';
        _isLoading = false;
      });
      AppUtils.showSnackBar(context, 'Error: Failed to fetch call logs.');
    }
  }

  Future<TruecallerData?> _fetchTruecallerData(String number) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('truecaller_api_key');
    if (apiKey == null) {
      AppUtils.showSnackBar(context, 'Error: Please set Truecaller API key in settings.');
      return null;
    }
    try {
      final url = Uri.parse(
        'https://search5-noneu.truecaller.com/v2/search?q=${Uri.encodeQueryComponent(number)}&countryCode=IN&type=4&encoding=json',
      );
      final response = await http.get(url, headers: {'Authorization': 'Bearer $apiKey'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data'].isEmpty) {
          AppUtils.showSnackBar(context, 'No Data: No information found for this number.');
          return null;
        }
        final user = data['data'][0];
        return TruecallerData(
          name: user['name'] ?? 'Unknown',
          email: user['email'] ?? 'Not available',
          location: user['addresses']?.isNotEmpty == true
              ? '${user['addresses'][0]['city'] ?? ''}, ${user['addresses'][0]['countryCode'] ?? ''}'
              : 'Unknown',
        );
      } else {
        AppUtils.showSnackBar(context, 'Error: Failed to fetch data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppUtils.showSnackBar(context, 'Error: Failed to fetch data.');
      return null;
    }
  }

  void _onSearch(String number) async {
    if (number.isEmpty) {
      AppUtils.showSnackBar(context, 'Error: Please enter a phone number.');
      return;
    }
    setState(() => _searchingNumbers.add(number));
    final data = await _fetchTruecallerData(number);
    setState(() {
      _truecallerData = data;
      _searchingNumbers.remove(number);
    });
    if (data != null) {
      AppUtils.showSnackBar(context, 'Success: Details fetched successfully.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueLogs', style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCallLogs,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCallLogs,
        color: themeProvider.accentColor,
        child: _isLoading && _callLogs.isEmpty
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.accentColor),
          ),
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SearchBarA(
              controller: _numberController,
              onSearch: () => _onSearch(_numberController.text),
              isLoading: _searchingNumbers.contains(_numberController.text),
              accentColor: themeProvider.accentColor,
            ),
            if (_truecallerData != null) ...[
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Caller Info', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Name: ${_truecallerData!.name}', style: const TextStyle(fontFamily: 'Poppins')),
                      Text('Email: ${_truecallerData!.email}', style: const TextStyle(fontFamily: 'Poppins')),
                      Text('Location: ${_truecallerData!.location}', style: const TextStyle(fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _truecallerData = null;
                            _numberController.clear();
                            setState(() {});
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: themeProvider.accentColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text('Recent Calls', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchCallLogs,
                        child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins')),
                      ),
                    ],
                  ),
                ),
              )
            else if (_callLogs.isEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No call logs available', style: TextStyle(fontFamily: 'Poppins'))),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _callLogs.length,
                itemBuilder: (context, index) {
                  final log = _callLogs[index];
                  final number = log.number ?? 'Unknown';
                  return CallLogItem(
                    log: log,
                    onTap: () {
                      _numberController.text = number;
                      _onSearch(number);
                    },
                    isSearching: _searchingNumbers.contains(number),
                    accentColor: themeProvider.accentColor,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}