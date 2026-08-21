import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'theme_colors.dart';

/// Centralized Design System for the application
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // Colors (Single source of truth: AppColors — purple brand identity)
  // ===========================================================================
  static const Color primaryDark = AppColors.primary;
  static const Color primaryMedium = AppColors.secondaryDark;
  static const Color primaryLight = AppColors.vibrantPurple;
  static const Color accentCyan = AppColors.accent;
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color vibrantPurple = AppColors.vibrantPurple;
  static const Color successGreen = AppColors.successGreen;
  static const Color errorRed = AppColors.error;
  static const Color warningAmber = Color(0xFFFFC107);

  static const Color backgroundPrimary = AppColors.background;
  static const Color backgroundAlt = AppColors.backgroundAlt;
  static const Color surfaceWhite = AppColors.surface;
  static const Color surfaceGrey = AppColors.fieldBackground;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint = AppColors.textHint;
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerMedium = Color(0xFFBDBDBD);

  static const Color chipSelected = Color(0xFFE9E1F7);
  static const Color chipUnselected = AppColors.chipUnselected;

  static const Color fieldBackground = AppColors.fieldBackground;
  static const Color fieldBorder = Color(0xFFE0E0E0);

  static const LinearGradient backgroundGradient = AppColors.backgroundGradient;

  static const Color indicatorActive = primaryDark;
  static const Color indicatorInactive = Color(0xFFD9D9E3);

  static const Color logoutRed = AppColors.logoutRed;
  static const Color onlineGreen = Color(0xFF4CAF50);
  static const Color offlineGrey = Color(0xFF9E9E9E);

  // ===========================================================================
  // Text Styles (colorless — inherit from the active theme so dark mode works)
  // ===========================================================================
  static TextStyle get headlineLarge =>
      TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, height: 1.2);

  static TextStyle get headlineMedium =>
      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, height: 1.3);

  static TextStyle get headlineSmall =>
      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get titleLarge =>
      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, height: 1.4);

  static TextStyle get titleMedium =>
      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get titleSmall =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get bodyLarge =>
      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, height: 1.5);

  static TextStyle get bodyMedium =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, height: 1.5);

  static TextStyle get bodySmall =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, height: 1.5);

  static TextStyle get labelLarge =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get labelMedium =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get labelSmall =>
      TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, height: 1.4);

  // ===========================================================================
  // Spacing
  // ===========================================================================
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // ===========================================================================
  // Border Radius
  // ===========================================================================
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusRound = 50;

  // ===========================================================================
  // Shadows
  // ===========================================================================
  static List<BoxShadow> get shadowXs => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ===========================================================================
  // Theme Data
  // ===========================================================================
  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    scheme: AppThemeColors.light,
    onPrimary: textOnPrimary,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    primary: primaryDark,
    selectedItemColor: primaryDark,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    scheme: AppThemeColors.dark,
    onPrimary: textOnPrimary,
    onSurface: const Color(0xFFF5F3FA),
    onSurfaceVariant: const Color(0xFFCDC8E0),
    primary: primaryLight,
    selectedItemColor: primaryLight,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppThemeColors scheme,
    required Color onPrimary,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color primary,
    required Color selectedItemColor,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primary,
            onPrimary: onPrimary,
            primaryContainer: const Color(0xFF4A3060),
            onPrimaryContainer: const Color(0xFFF0EFF6),
            secondary: accentCyan,
            secondaryContainer: const Color(0xFF0E3A4A),
            onSecondaryContainer: const Color(0xFFE0F7FF),
            surface: scheme.surface,
            onSurface: onSurface,
            surfaceContainerHighest: scheme.surfaceMuted,
            onSurfaceVariant: onSurfaceVariant,
            error: errorRed,
            outline: scheme.inputBorder,
            outlineVariant: scheme.divider,
          )
        : ColorScheme.light(
            primary: primary,
            onPrimary: onPrimary,
            primaryContainer: const Color(0xFFEFE4F5),
            onPrimaryContainer: const Color(0xFF3A0051),
            secondary: accentCyan,
            secondaryContainer: const Color(0xFFD6F3FA),
            onSecondaryContainer: const Color(0xFF00323F),
            surface: scheme.surface,
            onSurface: onSurface,
            surfaceContainerHighest: scheme.surfaceMuted,
            onSurfaceVariant: onSurfaceVariant,
            error: errorRed,
            outline: scheme.inputBorder,
            outlineVariant: scheme.divider,
          );

    final textTheme = TextTheme(
      displayLarge: headlineLarge.copyWith(color: onSurface),
      displayMedium: headlineMedium.copyWith(color: onSurface),
      displaySmall: headlineSmall.copyWith(color: onSurface),
      headlineLarge: titleLarge.copyWith(color: onSurface),
      headlineMedium: titleMedium.copyWith(color: onSurface),
      headlineSmall: titleSmall.copyWith(color: onSurface),
      bodyLarge: bodyLarge.copyWith(color: onSurface),
      bodyMedium: bodyMedium.copyWith(color: onSurfaceVariant),
      bodySmall: bodySmall.copyWith(color: scheme.textHint),
      labelLarge: labelLarge.copyWith(color: onSurface),
      labelMedium: labelMedium.copyWith(color: onSurfaceVariant),
      labelSmall: labelSmall.copyWith(color: scheme.textHint),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: scheme.background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [scheme],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headlineSmall.copyWith(color: onSurface),
        iconTheme: IconThemeData(color: onSurface, size: 24.sp),
        actionsIconTheme: IconThemeData(color: onSurface, size: 24.sp),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: labelLarge.copyWith(color: onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: labelLarge.copyWith(color: primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          textStyle: labelMedium.copyWith(color: primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceMuted,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: scheme.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorRed),
        ),
        hintStyle: bodyMedium.copyWith(color: scheme.textHint),
        labelStyle: bodyMedium.copyWith(color: scheme.textSecondary),
        prefixIconColor: scheme.textSecondary,
        suffixIconColor: scheme.textSecondary,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: scheme.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: labelSmall.copyWith(color: selectedItemColor),
        unselectedLabelStyle: labelSmall.copyWith(color: scheme.textHint),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.chipUnselected,
        selectedColor: scheme.chipSelected,
        labelStyle: labelMedium.copyWith(color: onSurfaceVariant),
        secondaryLabelStyle: labelMedium.copyWith(color: primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: titleLarge.copyWith(color: onSurface),
        contentTextStyle: bodyMedium.copyWith(color: onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurface,
        contentTextStyle: bodyMedium.copyWith(color: scheme.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
      ),
      iconTheme: IconThemeData(color: onSurface, size: 24.sp),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        titleTextStyle: bodyLarge.copyWith(color: onSurface),
        subtitleTextStyle: bodyMedium.copyWith(color: onSurfaceVariant),
        leadingAndTrailingTextStyle: bodyMedium,
        iconColor: onSurfaceVariant,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: scheme.surfaceMuted,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: scheme.textHint,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: labelMedium.copyWith(color: primary),
        unselectedLabelStyle: labelMedium.copyWith(color: scheme.textHint),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: bodySmall.copyWith(color: scheme.surface),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
    );
  }
}
