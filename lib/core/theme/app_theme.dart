import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const purple = Color(0xFF6C3FC5);
  static const purpleLight = Color(0xFF8B5CF6);
  static const purpleDark = Color(0xFF4C1D95);
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFF22C55E);
  static const greenBg = Color(0xFFDCFCE7);
  static const red = Color(0xFFDC2626);
  static const redBg = Color(0xFFFEE2E2);
  static const yellow = Color(0xFFD97706);
  static const yellowBg = Color(0xFFFEF3C7);
  static const bg = Color(0xFFF8F7FF);
  static const text = Color(0xFF1E1B4B);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const white = Color(0xFFFFFFFF);

  static const primary = purple;
  static const primaryLight = purpleLight;
  static const primaryDark = purpleDark;
  static const success = green;
  static const successLight = greenBg;
  static const accent = yellow;
  static const accentLight = yellowBg;
  static const error = red;
  static const errorLight = redBg;
  static const info = purple;
  static const infoLight = Color(0xFFEDE9FE);
  static const darkNavy = text;
  static const lightGray = Color(0xFFF3F4F6);
  static const inputBorder = border;
  static const pageBg = bg;
  static const dark = text;

  static const driver = purple;
  static const driverLight = Color(0xFFEDE9FE);
  static const owner = yellow;
  static const ownerLight = yellowBg;
  static const admin = green;
  static const adminLight = greenBg;

  static const greenBadge = greenBg;
  static const greenBadgeText = Color(0xFF166534);
  static const yellowBadge = yellowBg;
  static const yellowBadgeText = Color(0xFF92400E);
  static const redBadge = redBg;
  static const redBadgeText = Color(0xFF991B1B);
  static const blueBadge = Color(0xFFEDE9FE);
  static const blueBadgeText = Color(0xFF5B21B6);
}

ThemeData appTheme() {
  final interTextTheme = GoogleFonts.interTextTheme();
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: interTextTheme.copyWith(
      headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w800),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w800),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w800),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      primary: AppColors.purple,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.purple,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.purpleLight, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
  );
}
