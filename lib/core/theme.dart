import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF8B5CF6); // Violeta vibrante (Atractivo y moderno)
  static const Color secondaryColor = Color(0xFF0EA5E9); // Azul cielo (Contraste brillante y amigable)
  static const Color backgroundColor = Color(0xFF0F172A); // Azul pizarra muy oscuro (Muy suave a la vista)
  static const Color surfaceColor = Color(0xFF1E293B); // Azul pizarra (Ideal para separar tarjetas del fondo)
  static const Color errorColor = Color(0xFFF43F5E); // Rojo carmín (Amigable y no estridente)
  static const Color successColor = Color(0xFF10B981); // Verde esmeralda (Claro y positivo)

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(backgroundColor: backgroundColor, elevation: 0, centerTitle: true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static BoxDecoration get primaryGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF1E1B4B), backgroundColor], // Degradado elegante de índigo muy oscuro a fondo

      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
