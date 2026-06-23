import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color diverseyNavy = Color(0xFF041B2D); // Dark navy from logo
  static const Color solenisMint = Color(0xFF00C18A); // Mint green from logo
  static const Color backgroundLight = Color(0xFFF4F7F6);
  static const Color cardBackground = Colors.white;
  static const Color cardBorder = Color(0xFFE0E5E9);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: solenisMint,
      colorScheme: const ColorScheme.light(
        primary: solenisMint,
        secondary: diverseyNavy,
        surface: cardBackground,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: diverseyNavy, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(color: diverseyNavy, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.outfit(color: diverseyNavy, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.outfit(color: diverseyNavy, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.outfit(color: diverseyNavy),
        labelLarge: GoogleFonts.outfit(color: Colors.grey.shade600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        centerTitle: false,
        iconTheme: IconThemeData(color: diverseyNavy),
      ),
    );
  }
}
