// // --- CENTRALIZED APP COLORS ---
import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF4F6F9);
  static const Color surfaceWhite = Colors.white;
  static const Color searchFieldBg = Colors.white;
  static const Color locationChipBg = Color(0xFFF1F2F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF8B93A6);
  static const Color textDarkHint = Color(0xFF636E72);
  static const Color textLightHint = Color(0xFFA0A5B9);
  static const Color textNotes = Color(0xFFA4B0BE);

  // Brand / Theme Colors
  static const Color primary = Color(0xFF6C5CE7); // Relaxing Purple
  static const Color secondary = Color(0xFF00CEC9); // Mint Cyan
  static const Color cardColor = Colors.white;
  static const Color cardAccent =
      Color(0xFF6C5CE7); // Unified color for all cards

  // Icons & Status Colors
  static const Color iconGrey = Color(0xFF8B93A6);
  static const Color iconLightGrey = Color(0xFFB2BEC3);
  static const Color whatsappGreen = Color(0xFF00B894);
  static const Color excelGreen = Color(0xFF107C41);
  static const Color statOrange = Color(0xFFE17055);
  static const Color statGreen = Color(0xFF00B894);
  static const Color pending =  Color(0xFFFFA000);

  // Shadows
  static Color shadowColor = Colors.black.withValues(alpha: .03);
  static Color cardShadowColor = cardAccent.withValues(alpha: .08);
  static Color fabShadowColor = primary.withValues(alpha: .4);
}
