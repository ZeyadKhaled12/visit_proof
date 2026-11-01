// =============================================================================
// APP THEME — the single place to rebrand Visit Proof for a company.
// =============================================================================
//
// Every color, font and text size in the app comes from this file. Change a
// value here and it updates on every screen; no other file needs editing.
//
// How to rebrand:
//   1. Colors      → edit [AppTheme.light] (light mode) and [AppTheme.dark]
//                    (dark mode). Colors are written as 0xAARRGGBB:
//                    AA = opacity (FF solid, 00 invisible), then the hex color.
//   2. Font family → set [AppTheme.fontFamily] (English) and
//                    [AppTheme.fontFamilyArabic] (Arabic) to Google Fonts names,
//                    as written on fonts.google.com ('Poppins', 'Cairo').
//   3. Text sizes  → edit a size token, or [AppTheme.fontScale] to make all
//                    text bigger or smaller at once.
//   4. Dark mode   → [AppTheme.darkModeEnabled] shows or hides the switch;
//                    [AppTheme.darkModeByDefault] sets the starting mode.
//
// Only variables live here, plus small helpers at the bottom that apply them.
// Reusable widgets belong in core/utils/general_widgets.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_language.dart';

/// One full set of colors. The app has two: [AppTheme.light] and
/// [AppTheme.dark]. Each field says where the color is used.
class AppPalette {
  const AppPalette({
    required this.primary,
    required this.secondary,
    required this.cardAccent,
    required this.onPrimary,
    required this.scaffoldBackground,
    required this.surface,
    required this.cardColor,
    required this.searchFieldBg,
    required this.locationChipBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDarkHint,
    required this.textLightHint,
    required this.textNotes,
    required this.iconGrey,
    required this.iconLightGrey,
    required this.statGreen,
    required this.pending,
    required this.statOrange,
    required this.whatsappGreen,
    required this.shadowColor,
    required this.cardShadowColor,
    required this.fabShadowColor,
  });

  // --- Brand -----------------------------------------------------------------

  /// Main brand color: buttons, links, selected items, charts.
  final Color primary;

  /// Second brand color: section icons, gradients with [primary], accents.
  final Color secondary;

  /// Accent on cards and borders. Usually the same as [primary].
  final Color cardAccent;

  /// Text and icons drawn ON brand colors (buttons, gradients, badges).
  final Color onPrimary;

  // --- Backgrounds -----------------------------------------------------------

  /// Background behind every screen.
  final Color scaffoldBackground;

  /// Surfaces: app bars, sheets, panels, list tiles.
  final Color surface;

  /// Background of cards.
  final Color cardColor;

  /// Background of search fields.
  final Color searchFieldBg;

  /// Soft fill for chips, info boxes, progress tracks and empty states.
  final Color locationChipBg;

  // --- Text ------------------------------------------------------------------

  /// Main text: titles, names, values.
  final Color textPrimary;

  /// Secondary text: subtitles, labels, descriptions.
  final Color textSecondary;

  /// Detail text under a title: addresses, problem descriptions.
  final Color textDarkHint;

  /// Faint text: placeholders, timestamps, notes.
  final Color textLightHint;

  /// Sheet subtitles and empty-state notes.
  final Color textNotes;

  // --- Icons -----------------------------------------------------------------

  /// Default icons, and the "draft" / "low priority" color.
  final Color iconGrey;

  /// Faint icons, dividers and borders.
  final Color iconLightGrey;

  // --- Status (visits, payments, priorities, messages) -----------------------

  /// Success: completed, paid, available, good changes.
  final Color statGreen;

  /// Waiting / warning: scheduled, in progress, pending, busy.
  final Color pending;

  /// Problem / danger: cancelled, overdue, delete, errors.
  final Color statOrange;

  /// WhatsApp buttons and badges.
  final Color whatsappGreen;

  // --- Shadows ---------------------------------------------------------------

  /// Soft shadow under most cards and bars.
  final Color shadowColor;

  /// Tinted shadow under brand cards.
  final Color cardShadowColor;

  /// Glow under the floating "Add" buttons.
  final Color fabShadowColor;
}

class AppTheme {
  AppTheme._();

  // ===========================================================================
  // LIGHT MODE COLORS — edit to rebrand the light theme
  // ===========================================================================

  static const AppPalette light = AppPalette(
    primary: Color(0xFF6C5CE7), // purple
    secondary: Color(0xFF00CEC9), // mint cyan
    cardAccent: Color(0xFF6C5CE7),
    onPrimary: Color(0xFFFFFFFF), // white text on purple
    scaffoldBackground: Color(0xFFF4F6F9),
    surface: Color(0xFFFFFFFF),
    cardColor: Color(0xFFFFFFFF),
    searchFieldBg: Color(0xFFFFFFFF),
    locationChipBg: Color(0xFFF1F2F6),
    textPrimary: Color(0xFF2C3E50),
    textSecondary: Color(0xFF8B93A6),
    textDarkHint: Color(0xFF636E72),
    textLightHint: Color(0xFFA0A5B9),
    textNotes: Color(0xFFA4B0BE),
    iconGrey: Color(0xFF8B93A6),
    iconLightGrey: Color(0xFFB2BEC3),
    statGreen: Color(0xFF00B894),
    pending: Color(0xFFFFA000),
    statOrange: Color(0xFFE17055),
    whatsappGreen: Color(0xFF00B894),
    shadowColor: Color(0x08000000), // black at 3 %
    cardShadowColor: Color(0x146C5CE7), // primary at 8 %
    fabShadowColor: Color(0x666C5CE7), // primary at 40 %
  );

  // ===========================================================================
  // DARK MODE COLORS — edit to rebrand the dark theme
  // ===========================================================================
  // Brand and status colors are a little lighter than in light mode so they
  // stay readable on dark backgrounds.

  static const AppPalette dark = AppPalette(
    primary: Color(0xFF8E80F7),
    secondary: Color(0xFF2EDBD6),
    cardAccent: Color(0xFF8E80F7),
    onPrimary: Color(0xFFFFFFFF),
    scaffoldBackground: Color(0xFF12141C),
    surface: Color(0xFF1C1F2A),
    cardColor: Color(0xFF1C1F2A),
    searchFieldBg: Color(0xFF232736),
    locationChipBg: Color(0xFF262A38),
    textPrimary: Color(0xFFE8EAF1),
    textSecondary: Color(0xFF9AA1B5),
    textDarkHint: Color(0xFFB7BDCC),
    textLightHint: Color(0xFF717889),
    textNotes: Color(0xFF7D8497),
    iconGrey: Color(0xFF9AA1B5),
    iconLightGrey: Color(0xFF4A5063),
    statGreen: Color(0xFF1AAE85), // checked for chart readability on dark
    pending: Color(0xFFFFB84D),
    statOrange: Color(0xFFFF8A70),
    whatsappGreen: Color(0xFF25D366),
    shadowColor: Color(0x33000000), // black at 20 %
    cardShadowColor: Color(0x29000000), // black at 16 %
    fabShadowColor: Color(0x598E80F7), // primary at 35 %
  );

  // ===========================================================================
  // DARK MODE SETTINGS
  // ===========================================================================

  /// Shows the dark mode switch in the app menu.
  static const bool darkModeEnabled = true;

  /// Starting mode before the user picks one.
  static const bool darkModeByDefault = false;

  // ===========================================================================
  // TYPOGRAPHY
  // ===========================================================================

  /// Font of the whole app in English, loaded from Google Fonts by name.
  static const String fontFamily = 'Manrope';

  /// Font used when the app is in Arabic. Pick a Google Font that has
  /// Arabic letters (e.g. 'Cairo', 'Tajawal', 'Almarai', 'IBM Plex Sans Arabic').
  static const String fontFamilyArabic = 'Cairo';

  /// Multiplies every text size. 1.0 = as designed, 1.1 = 10 % bigger.
  static const double fontScale = 1.0;

  // --- Text sizes, smallest to largest --------------------------------------

  /// Tiny labels: chart axes, small badges.
  static const double textMicro = 10;

  /// Captions: hints, timestamps, secondary lines in lists.
  static const double textCaption = 11.5;

  /// Small text: chips, notes, subtitles.
  static const double textSmall = 12;

  /// Body text: most regular text and list rows.
  static const double textBody = 13;

  /// Large body: form fields, important rows, sheet text.
  static const double textBodyLarge = 14;

  /// Subtitles and button labels.
  static const double textSubtitle = 15;

  /// Card and section titles.
  static const double textTitle = 16;

  /// App bar titles and large buttons.
  static const double textTitleLarge = 18;

  /// Screen headlines (e.g. "Operations overview").
  static const double textHeadline = 20;

  /// Big numbers: KPI values, amounts, hero figures.
  static const double textDisplay = 26;

  // ===========================================================================
  // ACTIVE THEME — no design values below this line
  // ===========================================================================

  /// Current mode. Changed by the dark mode switch; the app restyles itself.
  static final ValueNotifier<bool> darkMode = ValueNotifier(darkModeByDefault);

  static bool get isDark => darkMode.value;

  /// The font for the current language.
  static String get activeFontFamily =>
      AppLanguage.isArabic ? fontFamilyArabic : fontFamily;

  /// The palette in use right now.
  static AppPalette get palette => isDark ? dark : light;

  static Color get primary => palette.primary;
  static Color get secondary => palette.secondary;
  static Color get cardAccent => palette.cardAccent;
  static Color get onPrimary => palette.onPrimary;
  static Color get scaffoldBackground => palette.scaffoldBackground;
  static Color get surface => palette.surface;
  static Color get cardColor => palette.cardColor;
  static Color get searchFieldBg => palette.searchFieldBg;
  static Color get locationChipBg => palette.locationChipBg;
  static Color get textPrimary => palette.textPrimary;
  static Color get textSecondary => palette.textSecondary;
  static Color get textDarkHint => palette.textDarkHint;
  static Color get textLightHint => palette.textLightHint;
  static Color get textNotes => palette.textNotes;
  static Color get iconGrey => palette.iconGrey;
  static Color get iconLightGrey => palette.iconLightGrey;
  static Color get statGreen => palette.statGreen;
  static Color get pending => palette.pending;
  static Color get statOrange => palette.statOrange;
  static Color get whatsappGreen => palette.whatsappGreen;
  static Color get shadowColor => palette.shadowColor;
  static Color get cardShadowColor => palette.cardShadowColor;
  static Color get fabShadowColor => palette.fabShadowColor;

  /// Text style in the app font. Use instead of TextStyle everywhere.
  static TextStyle font({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
  }) {
    return GoogleFonts.getFont(
      activeFontFamily,
      fontSize: fontSize == null ? null : fontSize * fontScale,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
    );
  }

  /// Phone status bar (top) and navigation bar (bottom) for the active mode:
  /// dark icons on light screens, light icons on dark screens.
  static SystemUiOverlayStyle get systemOverlay => SystemUiOverlayStyle(
        statusBarColor: const Color(0x00000000),
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: scaffoldBackground,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      );

  /// Status bar over brand-colored headers (light icons in both modes).
  static SystemUiOverlayStyle get systemOverlayOnPrimary =>
      systemOverlay.copyWith(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      );

  /// Flutter's built-in widgets (dialogs, pickers, text fields, snack bars)
  /// styled from the active palette.
  static ThemeData get materialTheme {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: surface,
      cardColor: cardColor,
      dividerColor: iconLightGrey,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        surface: surface,
        onSurface: textPrimary,
        error: statOrange,
      ),
      textTheme: GoogleFonts.getTextTheme(activeFontFamily).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(systemOverlayStyle: systemOverlay),
      dialogTheme: DialogThemeData(backgroundColor: surface),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: surface),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    );
  }
}
