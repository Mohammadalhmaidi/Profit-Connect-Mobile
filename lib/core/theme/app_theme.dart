import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        primary: AppColors.primaryDark,
        brightness: Brightness.light,
      ),
      textTheme: _textTheme(Brightness.light),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.secondaryDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.secondaryDark,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.secondaryDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.vibrantPurple,
        primary: AppColors.vibrantPurple,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
      ),
      textTheme: _textTheme(Brightness.dark),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? AppColors.textPrimary : Colors.white;
    final secondaryColor = brightness == Brightness.light ? AppColors.textSecondary : Colors.white70;

    return TextTheme(
      headlineMedium: TextStyle(
        color: color,
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      bodyMedium: TextStyle(
        color: secondaryColor,
        fontSize: 16.sp,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        color: color,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
