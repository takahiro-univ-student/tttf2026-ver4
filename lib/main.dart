import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const IslandApp());
}

class IslandApp extends StatelessWidget {
  const IslandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '島ナビAI',
      theme: AppTheme.theme(),
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    );
  }
}