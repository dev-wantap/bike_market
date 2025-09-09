import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'widgets/auth/auth_gate.dart';

class BikeMarketApp extends StatelessWidget {
  const BikeMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CycleLink',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
