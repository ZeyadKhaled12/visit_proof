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

import 'app_brand.dart';
import 'app_language.dart';

/// One full set of colors. The app has two: [AppTheme.light] and
/// [AppTheme.dark]. Each field says where the color is used.
class AppPalette {
  const AppPalette({
    required this.primary,
    required this.primarySoft,
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
    required this.progress,
    required this.statOrange,
    required this.whatsappGreen,
    required this.shadowColor,
    required this.cardShadowColor,
    required this.fabShadowColor,
    required this.scrim,
    required this.onScrim,
    required this.reward,
  });

  // --- Brand -----------------------------------------------------------------

  /// Main brand color: buttons, links, selected items, charts.
  final Color primary;

  /// Soft fill behind brand-colored icons, avatars and selected rows.
  final Color primarySoft;

  /// Teal with one meaning only: on the way and refunded.
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

  /// Waiting / warning: scheduled, pending, busy.
  final Color pending;

  /// Work in progress.
  final Color progress;

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

  // --- Guided tours ---------------------------------------------------------

  /// Darkens the screen around the spotlight.
  final Color scrim;

  /// Text and lines drawn on [scrim].
  final Color onScrim;

  /// Stars and points earned in a tour.
  final Color reward;

  AppPalette copyWith({
    Color? primary,
    Color? primarySoft,
    Color? secondary,
    Color? cardAccent,
    Color? onPrimary,
    Color? scaffoldBackground,
    Color? surface,
    Color? cardColor,
    Color? searchFieldBg,
    Color? locationChipBg,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDarkHint,
    Color? textLightHint,
    Color? textNotes,
    Color? iconGrey,
    Color? iconLightGrey,
    Color? statGreen,
    Color? pending,
    Color? progress,
    Color? statOrange,
    Color? whatsappGreen,
    Color? shadowColor,
    Color? cardShadowColor,
    Color? fabShadowColor,
    Color? scrim,
    Color? onScrim,
    Color? reward,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      secondary: secondary ?? this.secondary,
      cardAccent: cardAccent ?? this.cardAccent,
      onPrimary: onPrimary ?? this.onPrimary,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      cardColor: cardColor ?? this.cardColor,
      searchFieldBg: searchFieldBg ?? this.searchFieldBg,
      locationChipBg: locationChipBg ?? this.locationChipBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDarkHint: textDarkHint ?? this.textDarkHint,
      textLightHint: textLightHint ?? this.textLightHint,
      textNotes: textNotes ?? this.textNotes,
      iconGrey: iconGrey ?? this.iconGrey,
      iconLightGrey: iconLightGrey ?? this.iconLightGrey,
      statGreen: statGreen ?? this.statGreen,
      pending: pending ?? this.pending,
      progress: progress ?? this.progress,
      statOrange: statOrange ?? this.statOrange,
      whatsappGreen: whatsappGreen ?? this.whatsappGreen,
      shadowColor: shadowColor ?? this.shadowColor,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
      fabShadowColor: fabShadowColor ?? this.fabShadowColor,
      scrim: scrim ?? this.scrim,
      onScrim: onScrim ?? this.onScrim,
      reward: reward ?? this.reward,
    );
  }
}

class AppTheme {
  AppTheme._();

  // ===========================================================================
  // LIGHT MODE COLORS — edit to rebrand the light theme
  // ===========================================================================

  static const AppPalette light = AppPalette(
    primary: Color(0xFF2350E0), // calm blue
    primarySoft: Color(0xFFE8EEFF),
    secondary: Color(0xFF0B7A8F), // teal: on the way, refunds
    cardAccent: Color(0xFF2350E0),
    onPrimary: Color(0xFFFFFFFF), // white text on blue
    scaffoldBackground: Color(0xFFF4F6FA),
    surface: Color(0xFFFFFFFF),
    cardColor: Color(0xFFFFFFFF),
    searchFieldBg: Color(0xFFFFFFFF),
    locationChipBg: Color(0xFFEEF1F6),
    textPrimary: Color(0xFF121826),
    textSecondary: Color(0xFF4A5468),
    textDarkHint: Color(0xFF6B7487),
    textLightHint: Color(0xFF6B7487),
    textNotes: Color(0xFF6B7487),
    iconGrey: Color(0xFF5B6577),
    iconLightGrey: Color(0xFFDCE1EA),
    statGreen: Color(0xFF15803D),
    pending: Color(0xFFB45309),
    progress: Color(0xFF6D28D9),
    statOrange: Color(0xFFC62828),
    whatsappGreen: Color(0xFF128C4A),
    shadowColor: Color(0x0A121826),
    cardShadowColor: Color(0x0F2350E0),
    fabShadowColor: Color(0x332350E0),
    scrim: Color(0xD90B1020),
    onScrim: Color(0xFFFFFFFF),
    reward: Color(0xFFFFC23D),
  );

  // ===========================================================================
  // DARK MODE COLORS — edit to rebrand the dark theme
  // ===========================================================================
  // Brand and status colors are a little lighter than in light mode so they
  // stay readable on dark backgrounds.

  static const AppPalette dark = AppPalette(
    primary: Color(0xFF7C9BFF),
    primarySoft: Color(0xFF1E2A52),
    secondary: Color(0xFF3CC6DB),
    cardAccent: Color(0xFF7C9BFF),
    onPrimary: Color(0xFF0B1020),
    scaffoldBackground: Color(0xFF0E1117),
    surface: Color(0xFF181C25),
    cardColor: Color(0xFF181C25),
    searchFieldBg: Color(0xFF1F2430),
    locationChipBg: Color(0xFF242A37),
    textPrimary: Color(0xFFEEF1F7),
    textSecondary: Color(0xFFA9B1C2),
    textDarkHint: Color(0xFF8790A3),
    textLightHint: Color(0xFF8790A3),
    textNotes: Color(0xFF8790A3),
    iconGrey: Color(0xFFA9B1C2),
    iconLightGrey: Color(0xFF2E3442),
    statGreen: Color(0xFF4ADE80),
    pending: Color(0xFFFBBF5A),
    progress: Color(0xFFC4A7FF),
    statOrange: Color(0xFFFF8A80),
    whatsappGreen: Color(0xFF25D366),
    shadowColor: Color(0x00000000),
    cardShadowColor: Color(0x00000000),
    fabShadowColor: Color(0x00000000),
    scrim: Color(0xE6050810),
    onScrim: Color(0xFFFFFFFF),
    reward: Color(0xFFFFC23D),
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
  static const double textMicro = 11;

  /// Captions: hints, timestamps, secondary lines in lists.
  static const double textCaption = 12;

  /// Small text: chips, notes, subtitles.
  static const double textSmall = 13;

  /// Body text: most regular text and list rows.
  static const double textBody = 15;

  /// Large body: form fields, important rows, sheet text.
  static const double textBodyLarge = 16;

  /// Subtitles and button labels.
  static const double textSubtitle = 17;

  /// Card and section titles.
  static const double textTitle = 18;

  /// App bar titles and large buttons.
  static const double textTitleLarge = 20;

  /// Screen headlines (e.g. "Operations overview").
  static const double textHeadline = 24;

  /// Big numbers: KPI values, amounts, hero figures.
  static const double textDisplay = 32;

  // ===========================================================================
  // ACTIVE THEME — no design values below this line
  // ===========================================================================

  /// Current mode. Changed by the dark mode switch; the app restyles itself.
  static final ValueNotifier<bool> darkMode = ValueNotifier(darkModeByDefault);

  static bool get isDark => darkMode.value;

  /// The font for the current language.
  static String get activeFontFamily => AppLanguage.isArabic
      ? (AppBrand.value.fontArabic ?? fontFamilyArabic)
      : (AppBrand.value.fontEnglish ?? fontFamily);

  /// [fontScale] times the customer's text size.
  static double get activeFontScale => fontScale * AppBrand.value.fontScale;

  /// The palette in use right now, with the customer's colors from
  /// [AppBrand]. Brand and status colors are made a little lighter in dark
  /// mode; background, card and text colors only change the light mode.
  static AppPalette get palette {
    final brand = AppBrand.value;
    final dark = isDark;
    if (_palette != null &&
        identical(brand, _paletteBrand) &&
        dark == _paletteDark) {
      return _palette!;
    }
    _paletteBrand = brand;
    _paletteDark = dark;
    return _palette = _buildPalette();
  }

  // Every color getter reads the palette, often thousands of times a frame,
  // so it is built once and reused until the mode or the brand changes.
  static AppPalette? _palette;
  static AppBrandModel? _paletteBrand;
  static bool? _paletteDark;

  static AppPalette _buildPalette() {
    final base = isDark ? dark : light;
    final colors = AppBrand.value.colors;
    if (colors.isEmpty) return base;

    Color? pick(AppBrandColor slot) {
      final color = colors[slot];
      if (color == null) return null;
      if (!isDark) return color;
      if (slot.lightModeOnly) return null;
      return Color.lerp(color, const Color(0xFFFFFFFF), .18);
    }

    final primary = pick(AppBrandColor.primary);
    final background = pick(AppBrandColor.background);
    final card = pick(AppBrandColor.card);
    final text = pick(AppBrandColor.text);
    return base.copyWith(
      primary: primary,
      cardAccent: primary,
      onPrimary: primary == null ? null : readableOn(primary),
      primarySoft: primary?.withValues(alpha: .12),
      cardShadowColor: primary?.withValues(alpha: .08),
      fabShadowColor: primary?.withValues(alpha: .4),
      secondary: pick(AppBrandColor.secondary),
      scaffoldBackground: background,
      locationChipBg: background == null
          ? null
          : Color.lerp(background, base.textPrimary, .05),
      surface: card,
      cardColor: card,
      searchFieldBg: card,
      textPrimary: text,
      textDarkHint: text == null
          ? null
          : Color.lerp(text, background ?? base.scaffoldBackground, .25),
      statGreen: pick(AppBrandColor.success),
      whatsappGreen: pick(AppBrandColor.success),
      pending: pick(AppBrandColor.warning),
      statOrange: pick(AppBrandColor.danger),
    );
  }

  /// White on dark colors, near-black on light ones.
  static Color readableOn(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF1E2230);

  static Color get primary => palette.primary;
  static Color get primarySoft => palette.primarySoft;
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
  static Color get progress => palette.progress;
  static Color get statOrange => palette.statOrange;
  static Color get whatsappGreen => palette.whatsappGreen;
  static Color get shadowColor => palette.shadowColor;
  static Color get cardShadowColor => palette.cardShadowColor;
  static Color get fabShadowColor => palette.fabShadowColor;
  static Color get scrim => palette.scrim;
  static Color get onScrim => palette.onScrim;
  static Color get reward => palette.reward;

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
    return _baseFont(activeFontFamily, fontWeight, fontStyle).copyWith(
      fontSize: fontSize == null ? null : fontSize * activeFontScale,
      color: color,
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

  // Looking a Google Font up is slow next to copying a TextStyle, and every
  // Text asks for one, so each family/weight/style is looked up only once.
  static final Map<String, TextStyle> _fonts = {};

  static TextStyle _baseFont(
      String family, FontWeight? weight, FontStyle? style) {
    return _fonts.putIfAbsent('$family|$weight|$style',
        () => GoogleFonts.getFont(family, fontWeight: weight, fontStyle: style));
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
    final key = '$isDark|${AppLanguage.isArabic}';
    if (_theme != null &&
        key == _themeKey &&
        identical(AppBrand.value, _themeBrand)) {
      return _theme!;
    }
    _themeKey = key;
    _themeBrand = AppBrand.value;
    return _theme = _buildMaterialTheme();
  }

  static ThemeData? _theme;
  static String? _themeKey;
  static AppBrandModel? _themeBrand;

  static ThemeData _buildMaterialTheme() {
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
