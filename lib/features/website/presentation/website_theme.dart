// =============================================================================
// WEBSITE THEME — the sales website's own look, separate from the app.
// =============================================================================
//
// A fixed black-and-white style (in the spirit of apple.com). Nothing the
// visitor changes in the design studio — colors, dark mode, fonts, text
// size — touches it: those live in AppTheme / AppBrand and only restyle the
// app inside the phone preview.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../configs/app_language.dart';

class WebTheme {
  WebTheme._();

  // --- Colors ----------------------------------------------------------------

  /// Buttons, links and highlights: near-black.
  static const Color primary = Color(0xFF1D1D1F);

  /// Text and icons drawn on [primary].
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Second tone for gradients and icons: dark grey.
  static const Color secondary = Color(0xFF515154);

  /// Page background.
  static const Color scaffoldBackground = Color(0xFFFFFFFF);

  /// Alternate sections, panels and app bars.
  static const Color surface = Color(0xFFF5F5F7);

  /// Cards on top of sections.
  static const Color cardColor = Color(0xFFFFFFFF);

  /// Text fields.
  static const Color searchFieldBg = Color(0xFFFFFFFF);

  /// Soft fills for chips and options.
  static const Color locationChipBg = Color(0xFFF2F2F4);

  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textLightHint = Color(0xFF86868B);

  static const Color iconGrey = Color(0xFF6E6E73);

  /// Borders and dividers.
  static const Color iconLightGrey = Color(0xFFD2D2D7);

  /// Status colors, used sparingly.
  static const Color statGreen = Color(0xFF248A3D);
  static const Color pending = Color(0xFFB25000);
  static const Color statOrange = Color(0xFFD70015);

  static const Color shadowColor = Color(0x0F000000);

  // --- Text ------------------------------------------------------------------

  static const String fontFamily = 'Inter';
  static const String fontFamilyArabic = 'IBM Plex Sans Arabic';

  static String get activeFontFamily =>
      AppLanguage.isArabic ? fontFamilyArabic : fontFamily;

  static const double textCaption = 11.5;
  static const double textSmall = 12;
  static const double textBody = 13;
  static const double textBodyLarge = 14;
  static const double textSubtitle = 15;
  static const double textTitle = 16;
  static const double textTitleLarge = 18;
  static const double textHeadline = 20;
  static const double textDisplay = 26;

  static TextStyle font({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final family = activeFontFamily;
    final base = _fonts.putIfAbsent('$family|$fontWeight',
        () => GoogleFonts.getFont(family, fontWeight: fontWeight));
    return base.copyWith(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// One Google Font lookup per family and weight.
  static final Map<String, TextStyle> _fonts = {};

  /// Flutter's own widgets on the website (dialogs, sliders, checkboxes,
  /// dropdowns, snack bars) in the same black and white.
  /// Built once per language.
  static ThemeData get materialTheme =>
      _themes[AppLanguage.isArabic] ??= _buildMaterialTheme();

  static final Map<bool, ThemeData> _themes = {};

  static ThemeData _buildMaterialTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: cardColor,
      cardColor: cardColor,
      dividerColor: iconLightGrey,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onPrimary,
        surface: cardColor,
        onSurface: textPrimary,
        error: statOrange,
      ),
      textTheme: GoogleFonts.getTextTheme(activeFontFamily).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: cardColor),
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: cardColor),
      snackBarTheme: const SnackBarThemeData(backgroundColor: primary),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        // A light fade-up instead of the heavier zoom; iPhone keeps its
        // slide and swipe-back.
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
      }),
    );
  }
}
