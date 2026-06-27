import 'package:flutter/material.dart';
import 'package:rain_vault/pages/Loading_screen.dart';
import 'package:rain_vault/pages/setting_page.dart'; // 👈 SettingsPage import

void main() => runApp(const RTRWHApp());

class RTRWHApp extends StatefulWidget {
  const RTRWHApp({super.key});

  @override
  State<RTRWHApp> createState() => _RTRWHAppState();
}

class _RTRWHAppState extends State<RTRWHApp> {
  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RainVault',
      theme: _isDarkTheme
          ? ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.cyanAccent,
        ),
      )
          : ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF2F4F8),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F2A44),
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0F2A44),
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.white70,
        ),
      ),
      // 👇 SplashScreen ab toggleTheme accept karega
      home: SplashScreen(toggleTheme: _toggleTheme, isDarkTheme: _isDarkTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}
