import 'package:flutter/material.dart';

/// Main color definitions for the alonet app
/// This class contains all the color constants used throughout the application
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Brand Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF64B5F6);
  
  // Secondary Colors
  static const Color secondaryPurple = Color(0xFF673AB7);
  static const Color secondaryPurpleDark = Color(0xFF512DA8);
  static const Color secondaryPurpleLight = Color(0xFF9575CD);
  
  // Accent Colors
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFF44336);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF424242);
  static const Color mediumGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFBDBDBD);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF4D4D4D);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnDark = Color(0xFFFFFFFF);
  
  // Surface Colors
  static const Color surface = Color(0xFFF9F8F3);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);
  static const Color borderDark = Color(0xFF757575);
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
  
  // Timeline Colors
  static const Color timelineBackgroundTop = Color(0xFFF8F6F4);
  static const Color timelineBackgroundBottom = Color(0xFFF5F3F1);
  static const Color timelineLine = Color(0xFFCCCCCC);
  static const Color timelineConnectionLine = Color(0xFFE0E0E0);
  static const Color momentBackground = Color(0xFFFFFFFF);
  static const Color momentShadow = Color(0x0D000000); // 5% opacity
  static const Color timelineText = Color(0xFF757575);
  
  // User Avatar Colors
  static const Color userAvatarBackground = Color(0xFFE8B4B8);
  static const Color userAvatarIcon = Color(0xFF7C3F42);
  static const Color partnerAvatarBackground = Color(0xFF4A5568);
  static const Color partnerAvatarIcon = Color(0xFFFFFFFF);
  
  // FAB (Floating Action Button) Colors
  static const Color fabBackground = Color(0xFFD4A574); // Warm golden brown
  static const Color fabIcon = Color(0xFFFFFFFF);
  static const Color fabShadow = Color(0x26000000); // 15% opacity - softer shadow
  
  // Dialog Colors - Warm and Calm Theme
  static const Color dialogAccent = Color(0xFFB8956A); // Muted warm brown
  static const Color dialogSecondary = Color(0xFFE8D5B7); // Light warm beige
  static const Color dialogBorder = Color(0xFFDDD0C0); // Soft warm border
}
