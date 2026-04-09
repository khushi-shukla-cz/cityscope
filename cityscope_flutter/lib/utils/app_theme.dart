import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgStart = Color(0xFF1E1E2F);
  static const Color bgEnd = Color(0xFF2C2C3C);
  static const Color green = Color(0xFF4CAF50);
  static const Color orange = Color(0xFFFF5722);
  static const Color blue = Color(0xFF2196F3);
  static const Color purple = Color(0xFF9C27B0);
  static const Color yellow = Color(0xFFFFC107);
  static const Color cardBg = Color(0x1AFFFFFF);
  static const Color cardBorder = Color(0x1FFFFFFF);
  static const Color text = Color(0xFFE8EAF0);
  static const Color textDim = Color(0xFF8892A4);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bgStart,
      colorScheme: base.colorScheme.copyWith(
        primary: green,
        secondary: blue,
        surface: const Color(0xFF232335),
      ),
      textTheme: GoogleFonts.exo2TextTheme(base.textTheme).apply(
        bodyColor: text,
        displayColor: text,
      ),
      cardTheme: const CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: cardBorder),
        ),
      ),
    );
  }
}
