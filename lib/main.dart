import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'TrueLogs',
          theme: lightTheme(themeProvider.accentColor),
          darkTheme: darkTheme(themeProvider.accentColor),
          themeMode: themeProvider.themeMode,
          home: const HomePage(),
          routes: {
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}