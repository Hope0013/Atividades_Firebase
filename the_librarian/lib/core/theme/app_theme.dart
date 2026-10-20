import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Configuração do tema visual Vintage do The Librarian.
/// Aplica tipografia serifada clássica (Playfair Display para títulos
/// e Lora para corpo de texto), com botões e campos estilizados.
class AppTheme {
  static ThemeData get vintageTheme {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        color: AppColors.leatherBrown,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        color: AppColors.leatherBrown,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        color: AppColors.leatherBrown,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: AppColors.leatherBrown,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.lora(
        color: AppColors.leatherBrown,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.lora(
        color: AppColors.sepiaText,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.lora(
        color: AppColors.sepiaText,
        fontSize: 14,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.lora(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.parchmentLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.burgundy,
        onPrimary: Colors.white,
        secondary: AppColors.forestGreen,
        onSecondary: Colors.white,
        error: AppColors.errorRed,
        onError: Colors.white,
        surface: AppColors.parchmentCard,
        onSurface: AppColors.leatherBrown,
      ),
      textTheme: textTheme,
      
      // AppBar com estilo clássico e sutil
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.parchmentLight,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: AppColors.leatherBrown),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.leatherBrown,
          fontSize: 21,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),

      // Cartões com borda artesanal de livro
      cardTheme: CardThemeData(
        color: AppColors.parchmentCard,
        elevation: 2,
        shadowColor: AppColors.woodDark.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.parchmentBorder, width: 1.2),
        ),
      ),

      // Estilo dos campos de texto (Input)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.parchmentCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.lora(color: AppColors.sepiaMuted, fontSize: 14),
        labelStyle: GoogleFonts.lora(color: AppColors.sepiaText, fontSize: 14),
        prefixIconColor: AppColors.antiqueGold,
        suffixIconColor: AppColors.sepiaMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.parchmentBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.parchmentBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.antiqueGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
      ),

      // Botões principais (Elevated)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: AppColors.burgundyDark.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.antiqueGold, width: 1),
          ),
          textStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Botões secundários (Outlined)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.burgundy,
          side: const BorderSide(color: AppColors.burgundy, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.lora(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Abas com indicador dourado
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.burgundy,
        unselectedLabelColor: AppColors.sepiaMuted,
        indicatorColor: AppColors.burgundy,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.playfairDisplay(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.lora(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Barra de navegação inferior
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.parchmentWarm,
        selectedItemColor: AppColors.burgundy,
        unselectedItemColor: AppColors.sepiaMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
