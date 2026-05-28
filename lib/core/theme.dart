import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameTheme {
  // Paleta de Colores
  static const Color spaceCadet = Color(0xFF0B0F19); // Fondo ultra oscuro
  static const Color slateBlue = Color(0xFF1E293B); // Paneles e interfaces
  static const Color neonCyan = Color(0xFF00E5FF); // Leo y soldados
  static const Color neonGreen = Color(
    0xFF39FF14,
  ); // Portales correctos / éxito
  static const Color neonRed = Color(
    0xFFFF3131,
  ); // Portales incorrectos / enemigos
  static const Color neonOrange = Color(0xFFFF5F1F); // Jefe enemigo
  static const Color textWhite = Color(0xFFF8FAFC); // Texto principal
  static const Color textGrey = Color(0xFF94A3B8); // Texto secundario

  // Tema de Flutter
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: spaceCadet,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonGreen,
        error: neonRed,
        surface: slateBlue,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textWhite,
          letterSpacing: 1.2,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          color: textWhite,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: textGrey),
        labelLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
      ),
      useMaterial3: true,
    );
  }

  // Estilos decorativos para CustomPainter
  static Paint getPaint(
    Color color, {
    bool isStroke = false,
    double strokeWidth = 2.0,
  }) {
    return Paint()
      ..color = color
      ..style = isStroke ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
  }

  // Sombra brillante (Glow effect) para los portales y elementos neón
  static BoxDecoration neonGlow({required Color color, double radius = 8.0}) {
    return BoxDecoration(
      color: slateBlue,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: radius,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
