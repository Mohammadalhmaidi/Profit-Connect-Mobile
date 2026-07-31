import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized Design System for the application
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // Colors
  // ===========================================================================
  static const Color primaryDark = Color(0xFF004D40);
  static const Color primaryMedium = Color(0xFF00695C);
  static const Color primaryLight = Color(0xFF00897B);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color vibrantPurple = Color(0xFF7C4DFF);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningAmber = Color(0xFFFFC107);

  static const Color backgroundPrimary = Color(0xFFF5F5F5);
  static const Color backgroundAlt = Color(0xFFFFFFFF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerMedium = Color(0xFFBDBDBD);

  static const Color chipSelected = Color(0xFFE0F2F1);
  static const Color chipUnselected = Color(0xFFF5F5F5);

  static const Color fieldBackground = Color(0xFFF5F5F5);
  static const Color fieldBorder = Color(0xFFE0E0E0);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryMedium],
  );

  static const Color indicatorActive = primaryDark;
  static const Color indicatorInactive = Color(0xFFBDBDBD);

  static const Color logoutRed = Color(0xFFE53935);
  static const Color onlineGreen = Color(0xFF4CAF50);
  static const Color offlineGrey = Color(0xFF9E9E9E);

  // ===========================================================================
  // Text Styles
  // ===========================================================================
  static TextStyle get headlineLarge => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get titleLarge => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: textHint,
        height: 1.5,
      );

  static TextStyle get labelLarge => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: textHint,
        height: 1.4,
      );

  // ===========================================================================
  // Spacing
  // ===========================================================================
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;

  // ===========================================================================
  // Border Radius
  // ===========================================================================
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 50.0;

  // ===========================================================================
  // Shadows
  // ===========================================================================
  static List<BoxShadow> get shadowXs => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ===========================================================================
  // Theme Data
  // ===========================================================================
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryDark,
        scaffoldBackgroundColor: backgroundPrimary,
        colorScheme: ColorScheme.light(
          primary: primaryDark,
          secondary: accentCyan,
          surface: surfaceWhite,
          error: errorRed,
          onPrimary: textOnPrimary,
          onSurface: textPrimary,
        ),
        textTheme: TextTheme(
          displayLarge: headlineLarge,
          displayMedium: headlineMedium,
          displaySmall: headlineSmall,
          headlineLarge: titleLarge,
          headlineMedium: titleMedium,
          headlineSmall: titleSmall,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: labelLarge,
          labelMedium: labelMedium,
          labelSmall: labelSmall,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceWhite,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: headlineSmall.copyWith(color: textPrimary),
          iconTheme: IconThemeData(color: textPrimary, size: 24.sp),
          actionsIconTheme: IconThemeData(color: textPrimary, size: 24.sp),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDark,
            foregroundColor: textOnPrimary,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: labelLarge,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryDark,
            side: BorderSide(color: primaryDark, width: 1.5),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryDark,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            textStyle: labelMedium,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: fieldBackground,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide(color: fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide(color: primaryDark, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide(color: errorRed),
          ),
          hintStyle: bodyMedium.copyWith(color: textHint),
          labelStyle: bodyMedium.copyWith(color: textSecondary),
        ),
        cardTheme: CardTheme(
          color: surfaceWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          shadowColor: Colors.black.withOpacity(0.04),
          margin: EdgeInsets.zero,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceWhite,
          selectedItemColor: primaryDark,
          unselectedItemColor: indicatorInactive,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: labelSmall,
          unselectedLabelStyle: labelSmall,
        ),
        dividerTheme: DividerThemeData(
          color: dividerLight,
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: chipUnselected,
          selectedColor: chipSelected,
          labelStyle: labelMedium,
          secondaryLabelStyle: labelMedium.copyWith(color: primaryDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusRound),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: surfaceWhite,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          titleTextStyle: titleLarge,
          contentTextStyle: bodyMedium,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: surfaceWhite,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: textPrimary,
          contentTextStyle: bodyMedium.copyWith(color: textOnPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryDark,
          foregroundColor: textOnPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusRound),
          ),
        ),
        iconTheme: IconThemeData(
          color: textPrimary,
          size: 24.sp,
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          titleTextStyle: bodyLarge,
          subtitleTextStyle: bodyMedium,
          leadingAndTrailingTextStyle: bodyMedium,
          iconColor: textPrimary,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: primaryDark,
          linearTrackColor: fieldBackground,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: primaryDark,
          unselectedLabelColor: textHint,
          indicatorColor: primaryDark,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: labelMedium,
          unselectedLabelStyle: labelMedium,
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: textPrimary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: bodySmall.copyWith(color: textOnPrimary),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        ),
      );

  static ThemeData get darkTheme => lightTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark(
          primary: primaryLight,
          secondary: accentCyan,
          surface: const Color(0xFF1E1E1E),
          error: errorRed,
          onPrimary: textOnPrimary,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 0,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          iconTheme: IconThemeData(color: Colors.white, size: 24.sp),
          actionsIconTheme: IconThemeData(color: Colors.white, size: 24.sp),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: primaryLight,
          unselectedItemColor: Colors.grey,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          hintStyle: bodyMedium.copyWith(color: Colors.grey),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF2C2C2C),
          selectedColor: primaryLight.withOpacity(0.2),
          labelStyle: labelMedium.copyWith(color: Colors.white),
        ),
      );
}