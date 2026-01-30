import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme() {
    const navy0 = Color(0xFF070A12);
    const navy2 = Color(0xFF0F172A);
    const accent = Color(0xFF60A5FA);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: navy2,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: navy0,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: navy2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.white.withOpacity(0.06),
        side: BorderSide(color: Colors.white.withOpacity(0.10)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      textTheme: base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
    );
  }

  static BoxDecoration background() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF070A12), Color(0xFF0B1224), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}