import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Theme colors
  static const Color primaryBlue = Color(0xFF2575FC);
  static const Color secondaryBlue = Color(0xFF6A11CB);
  static const Color darkBgStart = Color(0xFF0F2027);
  static const Color darkBgMid = Color(0xFF203A43);
  static const Color darkBgEnd = Color(0xFF2C5364);

  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentCoral = Color(0xFFFF5252);
  static const Color accentGreen = Color(0xFF00E676);

  // Modern text theme using Outfit & Poppins
  static TextTheme textTheme = GoogleFonts.outfitTextTheme().copyWith(
    displayLarge: GoogleFonts.outfit(
      fontSize: 72,
      fontWeight: FontWeight.w200,
      color: Colors.white,
      letterSpacing: -1.5,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 48,
      fontWeight: FontWeight.w300,
      color: Colors.white,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.9),
    ),
    bodyLarge: GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.85),
    ),
    bodyMedium: GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.75),
    ),
    labelMedium: GoogleFonts.outfit(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.65),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF090D16),
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentAmber,
      surface: Color(0xFF131B2A),
    ),
    textTheme: textTheme,
    iconTheme: const IconThemeData(color: Colors.white),
  );

  // Glass card decoration helper
  static BoxDecoration glassDecoration({
    double opacity = 0.15,
    double borderRadius = 24,
    Border? border,
    List<BoxShadow>? shadows,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: gradient == null ? Colors.white.withValues(alpha: opacity) : null,
      gradient: gradient ??
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: opacity + 0.05),
              Colors.white.withValues(alpha: opacity * 0.5),
            ],
          ),
      border: border ??
          Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.2,
          ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
    );
  }
}
