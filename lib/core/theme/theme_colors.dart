import 'package:flutter/material.dart';

/// Semantic color tokens that switch between light and dark palettes.
/// Access via `context.colors` (see [ThemeColorsX]).
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textOnPrimary,
    required this.divider,
    required this.inputBorder,
    required this.chipSelected,
    required this.chipUnselected,
  });

  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textOnPrimary;
  final Color divider;
  final Color inputBorder;
  final Color chipSelected;
  final Color chipUnselected;

  static const AppThemeColors light = AppThemeColors(
    background: Color(0xFFFAFAFA),
    backgroundAlt: Color(0xFFF8F9FE),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF7F7FB),
    textPrimary: Color(0xFF1B0330),
    textSecondary: Color(0xFF7D7D9E),
    textHint: Color(0xFFB0B0C5),
    textOnPrimary: Color(0xFFFFFFFF),
    divider: Color(0xFFE0E0E0),
    inputBorder: Color(0xFFE0E0E0),
    chipSelected: Color(0xFFE9E1F7),
    chipUnselected: Color(0xFFEFECF8),
  );

  static const AppThemeColors dark = AppThemeColors(
    background: Color(0xFF121212),
    backgroundAlt: Color(0xFF16181D),
    surface: Color(0xFF1E1E24),
    surfaceMuted: Color(0xFF31313A),
    textPrimary: Color(0xFFF5F3FA),
    textSecondary: Color(0xFFCDC8E0),
    textHint: Color(0xFF9A98B2),
    textOnPrimary: Color(0xFFFFFFFF),
    divider: Color(0xFF3A3A44),
    inputBorder: Color(0xFF4A4A56),
    chipSelected: Color(0xFF573F75),
    chipUnselected: Color(0xFF2C2C36),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? textOnPrimary,
    Color? divider,
    Color? inputBorder,
    Color? chipSelected,
    Color? chipUnselected,
  }) => AppThemeColors(
    background: background ?? this.background,
    backgroundAlt: backgroundAlt ?? this.backgroundAlt,
    surface: surface ?? this.surface,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textHint: textHint ?? this.textHint,
    textOnPrimary: textOnPrimary ?? this.textOnPrimary,
    divider: divider ?? this.divider,
    inputBorder: inputBorder ?? this.inputBorder,
    chipSelected: chipSelected ?? this.chipSelected,
    chipUnselected: chipUnselected ?? this.chipUnselected,
  );

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      chipSelected: Color.lerp(chipSelected, other.chipSelected, t)!,
      chipUnselected: Color.lerp(chipUnselected, other.chipUnselected, t)!,
    );
  }
}

extension ThemeColorsX on BuildContext {
  AppThemeColors get colors => Theme.of(this).extension<AppThemeColors>()!;
}
