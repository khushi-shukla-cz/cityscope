import 'package:flutter/material.dart';

import 'screens/dashboard_shell.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const CityScopeApp());
}

class CityScopeApp extends StatelessWidget {
  const CityScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityScope - Urban Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const DashboardShell(),
    );
  }
}
