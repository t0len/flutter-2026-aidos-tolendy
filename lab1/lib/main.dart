import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      themeMode: _themeMode,
      onThemeMode: _setThemeMode,
      child: MaterialApp(
        title: 'Exchange',
        theme: appTheme(Brightness.light),
        darkTheme: appTheme(Brightness.dark),
        themeMode: _themeMode,
        initialRoute: Routes.shell,
        routes: {Routes.shell: (context) => const Shell()},
        onGenerateRoute: generateRoute,
        onUnknownRoute: unknownRoute,
      ),
    );
  }
}
