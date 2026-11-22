import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// هوية خشبية دافئة: جوز عميق + كراميل + ذهبي فاخر
  static const Color primary = Color(0xFF0B5345); // جوز عميق
  static const Color primaryDark = Color(0xFF083B30); // إسبريسو
  static const Color accent = Color(0xFFC5A059); // ذهبي فاخر
  static const Color surface = Color(0xFFF8F6F2);
  static const Color textDark = Color(0xFF212121);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE9E4D9);
  static const Color shadow = Color(0x1A000000);

  static ThemeData lightTheme() {
    final base = GoogleFonts.cairoTextTheme(const TextTheme());
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: base,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 2,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
    );
  }
}
