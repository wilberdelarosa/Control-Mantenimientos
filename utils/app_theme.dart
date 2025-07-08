import 'package:flutter/material.dart';

class AppColors {
  // Colores especificados
  static const Color darkGray = Color.fromRGBO(35, 33, 36, 1);
  static const Color primaryYellow = Color.fromRGBO(242, 185, 52, 1);
  static const Color secondaryYellow = Color.fromRGBO(242, 196, 70, 1);
  static const Color mediumGray = Color.fromRGBO(142, 142, 144, 1);
  static const Color white = Color.fromRGBO(255, 255, 254, 1);
  static const Color lightGray = Color.fromRGBO(132, 130, 133, 1);
  
  // Colores adicionales para estados
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryYellow,
        secondary: AppColors.secondaryYellow,
        background: AppColors.white,
        surface: AppColors.white,
        onPrimary: AppColors.darkGray,
        onSecondary: AppColors.darkGray,
        onBackground: AppColors.darkGray,
        onSurface: AppColors.darkGray,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.darkGray,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: AppColors.darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryYellow,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.darkGray,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryYellow,
        unselectedItemColor: AppColors.mediumGray,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryYellow,
        secondary: AppColors.secondaryYellow,
        background: AppColors.darkGray,
        surface: Color.fromRGBO(50, 48, 51, 1),
        onPrimary: AppColors.darkGray,
        onSecondary: AppColors.darkGray,
        onBackground: AppColors.white,
        onSurface: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkGray,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkGray,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Color.fromRGBO(50, 48, 51, 1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color.fromRGBO(50, 48, 51, 1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: AppColors.darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryYellow,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.darkGray,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkGray,
        selectedItemColor: AppColors.primaryYellow,
        unselectedItemColor: AppColors.mediumGray,
      ),
    );
  }
}
