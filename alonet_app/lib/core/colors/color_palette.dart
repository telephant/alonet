import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Color palette definitions for different themes and contexts
class ColorPalette {
  /// Light theme color palette
  static const ColorPalette light = ColorPalette._light();
  
  /// Dark theme color palette
  static const ColorPalette dark = ColorPalette._dark();

  const ColorPalette._light()
      : primary = AppColors.primaryBlue,
        primaryVariant = AppColors.primaryBlueDark,
        secondary = AppColors.secondaryPurple,
        secondaryVariant = AppColors.secondaryPurpleDark,
        surface = AppColors.surface,
        background = AppColors.white,
        error = AppColors.error,
        onPrimary = AppColors.white,
        onSecondary = AppColors.white,
        onSurface = AppColors.textPrimary,
        onBackground = AppColors.textPrimary,
        onError = AppColors.white;

  const ColorPalette._dark()
      : primary = AppColors.primaryBlueLight,
        primaryVariant = AppColors.primaryBlue,
        secondary = AppColors.secondaryPurpleLight,
        secondaryVariant = AppColors.secondaryPurple,
        surface = AppColors.surfaceDark,
        background = AppColors.black,
        error = AppColors.error,
        onPrimary = AppColors.black,
        onSecondary = AppColors.black,
        onSurface = AppColors.textOnDark,
        onBackground = AppColors.textOnDark,
        onError = AppColors.black;

  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color secondaryVariant;
  final Color surface;
  final Color background;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onSurface;
  final Color onBackground;
  final Color onError;
}

/// Semantic color definitions for UI components
class SemanticColors {
  SemanticColors._();

  // Navigation Colors
  static const Color navigationSelected = AppColors.primaryBlue;
  static const Color navigationUnselected = AppColors.mediumGrey;
  static const Color navigationBackground = AppColors.white;
  
  // Button Colors
  static const Color buttonPrimary = AppColors.primaryBlue;
  static const Color buttonSecondary = AppColors.lightGrey;
  static const Color buttonDanger = AppColors.error;
  static const Color buttonSuccess = AppColors.success;
  
  // Input Colors
  static const Color inputBorder = AppColors.borderLight;
  static const Color inputBorderFocused = AppColors.primaryBlue;
  static const Color inputBackground = AppColors.white;
  static const Color inputText = AppColors.textPrimary;
  static const Color inputHint = AppColors.textHint;
  
  // Card Colors
  static const Color cardBackground = AppColors.white;
  static const Color cardBorder = AppColors.borderLight;
  static const Color cardShadow = AppColors.shadowLight;
  
  // Status Colors
  static const Color statusSuccess = AppColors.success;
  static const Color statusWarning = AppColors.warning;
  static const Color statusError = AppColors.error;
  static const Color statusInfo = AppColors.info;
}
