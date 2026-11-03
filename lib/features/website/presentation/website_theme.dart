// =============================================================================
// WEBSITE THEME — the Wizpo website's own look, separate from the app.
// =============================================================================
//
// A fixed light style in the Wizpo palette: midnight ink, wizard purple,
// gold, deep green, wine and parchment. Nothing the visitor changes in the
// design studio — colors, dark mode, fonts, text size — touches it: those
// live in AppTheme / AppBrand and only restyle the app inside the phone
// preview.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../configs/app_language.dart';

class WebTheme {
  WebTheme._();

  // --- Colors ----------------------------------------------------------------

  /// Buttons, links and highlights: midnight ink.
  static const Color primary = Color(0xFF15182D);

  /// Text and icons drawn on [primary].
  static const Color onPrimary = Color(0xFFF4EAD6);

  /// Second tone for gradients, labels and icons: wizard purple.
  static const Color secondary = Color(0xFF4B315F);

  /// The "magic" touch: badges, stars and small highlights. Use it on
  /// [primary] or as a soft fill; it is too light for text on white.
  static const Color accent = Color(0xFFD6AC58);

  /// Gold that is dark enough for text on light backgrounds.
  static const Color accentText = Color(0xFF8A6420);

  /// Parchment: the brand's light color.
  static const Color parchment = Color(0xFFF4EAD6);

  /// Page background.
  static const Color scaffoldBackground = Color(0xFFFFFDF8);

  /// Alternate sections, panels and app bars.
  static const Color surface = Color(0xFFF8F2E6);

  /// Cards on top of sections.
  static const Color cardColor = Color(0xFFFFFFFF);

  /// Text fields.
  static const Color searchFieldBg = Color(0xFFFFFFFF);

  /// Soft fills for chips and options.
  static const Color locationChipBg = Color(0xFFF2EBDD);

  static const Color textPrimary = Color(0xFF15182D);
  static const Color textSecondary = Color(0xFF5C5870);
  static const Color textLightHint = Color(0xFF8A8598);

  static const Color iconGrey = Color(0xFF5C5870);

  /// Borders and dividers.
  static const Color iconLightGrey = Color(0xFFE0D6C2);

  /// Status colors, used sparingly: deep green, dark gold and wine.
  static const Color statGreen = Color(0xFF1E5045);
  static const Color pending = Color(0xFF8A6420);
  static const Color statOrange = Color(0xFF6B2B3A);

  static const Color shadowColor = Color(0x1215182D);

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
