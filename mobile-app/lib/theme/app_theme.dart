import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MarqueeFlow brand colors from approved mockups (v1.4).
class AppColors {
  static const cream = Color(0xFFFFF8EE);
  static const creamDark = Color(0xFFF5EBD8);
  static const maroon = Color(0xFF7A1028);
  static const maroonDark = Color(0xFF5C0B1E);
  static const gold = Color(0xFFC8A45D);
  static const goldLight = Color(0xFFE8D5A8);
  static const badgeTan = Color(0xFFD9C4A0);
  static const text = Color(0xFF3D1B1B);
  static const textMuted = Color(0xFF6B5B5B);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8DCC8);
  static const error = Color(0xFFB42318);
  static const errorBg = Color(0xFFFEF3F2);
  static const success = Color(0xFF2E7D32);
  static const soloAccent = Color(0xFFF4D6DC);
  static const teamAccent = Color(0xFFD8EAD8);
}

class AppText {
  static TextStyle display(String text, {Color color = AppColors.maroon, double size = 28}) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.15,
    );
  }

  static TextStyle brandName({double size = 20}) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: AppColors.maroon,
      letterSpacing: 0.2,
    );
  }

  static TextStyle eyebrow(String text) {
    return GoogleFonts.sourceSans3(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.3,
      color: AppColors.textMuted,
    );
  }

  static TextStyle body([String? _]) {
    return GoogleFonts.sourceSans3(
      fontSize: 15,
      color: AppColors.textMuted,
      height: 1.45,
    );
  }

  static TextStyle label() {
    return GoogleFonts.sourceSans3(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    );
  }

  static TextStyle button() {
    return GoogleFonts.sourceSans3(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
  }
}

ThemeData buildMarqueeFlowTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.maroon,
      primary: AppColors.maroon,
      surface: AppColors.card,
    ),
    textTheme: TextTheme(
      headlineLarge: AppText.display(''),
      bodyMedium: AppText.body(),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.maroon,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.brandName(size: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppText.button(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.maroon,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.gold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.sourceSans3(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: AppText.label(),
      hintStyle: AppText.body(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.maroon;
        return Colors.white;
      }),
      side: const BorderSide(color: AppColors.gold),
    ),
  );
}
