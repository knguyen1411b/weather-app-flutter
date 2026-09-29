import 'package:flutter/material.dart';
import 'screens/weather_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thời Tiết',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.darkTheme,
      home: const WeatherScreen(),
    );
  }
}
