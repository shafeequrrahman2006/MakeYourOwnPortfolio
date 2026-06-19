import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MUOPTheme {
  // Brand Colors
  static const Color background = Color(0xFF0A0A0A);
  static const Color cardBg = Color(0xFF121212);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFBDBDBD);
  static const Color border = Color(0xFF2A2A2A);
  
  // Custom Gradients & Shadows
  static const Color glowColor = Color(0x22FFC107);
  static const Color greenGlow = Color(0x224CAF50);
  
  static BoxBorder glassBorder({Color color = border}) {
    return Border.all(
      color: color,
      width: 1.2,
    );
  }
  
  static List<BoxShadow> glowShadow({Color color = glowColor, double radius = 20.0}) {
    return [
      BoxShadow(
        color: color,
        blurRadius: radius,
        spreadRadius: 2,
      ),
    ];
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    
    return baseTheme.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryYellow,
        secondary: primaryYellow,
        surface: cardBg,
        background: background,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: primaryText,
        onBackground: primaryText,
        outline: border,
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: primaryText,
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.outfit(
          color: primaryText,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        titleLarge: GoogleFonts.outfit(
          color: primaryText,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.outfit(
          color: primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFF161616),
        filled: true,
        hintStyle: GoogleFonts.outfit(color: secondaryText.withOpacity(0.5)),
        labelStyle: GoogleFonts.outfit(color: secondaryText),
        floatingLabelStyle: GoogleFonts.outfit(color: primaryYellow),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryYellow, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
