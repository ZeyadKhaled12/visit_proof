// =============================================================================
// APP BRAND — a customer's own look, applied live on top of AppTheme.
// =============================================================================
//
// The website's design studio edits [AppBrand.current]; every screen redraws
// with the new colors, fonts, text size, name and icon at once. Nothing here
// is saved: the demo starts from the default look every time it opens.
//
// Anything not set keeps the default value from AppTheme.
// =============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'app_language.dart';

/// A part of the theme the customer can recolor.
enum AppBrandColor {
  primary('Main color', 'Buttons, links and headers'),
  secondary('Second color', 'Gradients and section icons'),
  background('Background', 'Behind every screen (light mode)'),
  card('Cards and bars', 'Cards, sheets and app bars (light mode)'),
  text('Text', 'Titles and main text (light mode)'),
  success('Success', 'Completed and paid'),
  warning('Waiting', 'Scheduled, pending and in progress'),
  danger('Problem', 'Cancelled, overdue and errors');

  const AppBrandColor(this._label, this._hint);
  final String _label;
  final String _hint;

  String get label => _label.tr;
  String get hint => _hint.tr;

  /// Background, cards and text only change the light mode; dark mode keeps
  /// its own so it stays readable.
  bool get lightModeOnly =>
      this == background || this == card || this == text;
}

class AppBrandModel {
  const AppBrandModel({
    this.colors = const {},
    this.appName,
    this.iconKey = AppBrand.defaultIconKey,
    this.logo,
    this.fontEnglish,
    this.fontArabic,
    this.fontScale = 1.0,
  });

  /// Only the colors the customer changed.
  final Map<AppBrandColor, Color> colors;

  /// Shown in headers and the browser tab. Null keeps "Visit Proof".
  final String? appName;

  /// One of [AppBrand.icons].
  final String iconKey;

  /// An uploaded logo, shown instead of the icon. Kept in memory only.
  final Uint8List? logo;

  /// Google Fonts names; null keeps AppTheme's fonts.
  final String? fontEnglish;
  final String? fontArabic;

  /// Multiplies every text size.
  final double fontScale;

  bool get hasCustomName => (appName ?? '').trim().isNotEmpty;

  Color? operator [](AppBrandColor slot) => colors[slot];

  /// Sets one color, or clears it back to the default with null.
  AppBrandModel withColor(AppBrandColor slot, Color? color) {
    final next = Map<AppBrandColor, Color>.of(colors);
    color == null ? next.remove(slot) : next[slot] = color;
    return copyWith(colors: next);
  }

  /// copyWith cannot clear a field, so [clearLogo] / [clearName] do.
  AppBrandModel copyWith({
    Map<AppBrandColor, Color>? colors,
    String? appName,
    String? iconKey,
    Uint8List? logo,
    String? fontEnglish,
    String? fontArabic,
    double? fontScale,
    bool clearLogo = false,
    bool clearName = false,
  }) {
    return AppBrandModel(
      colors: colors ?? this.colors,
      appName: clearName ? null : (appName ?? this.appName),
      iconKey: iconKey ?? this.iconKey,
      logo: clearLogo ? null : (logo ?? this.logo),
      fontEnglish: fontEnglish ?? this.fontEnglish,
      fontArabic: fontArabic ?? this.fontArabic,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}

/// A ready-made pair of brand colors.
class AppBrandPreset {
  const AppBrandPreset(this.name, this.primary, this.secondary);
  final String name;
  final Color primary;
  final Color secondary;
}

/// A ready-made app icon.
class AppBrandIcon {
  const AppBrandIcon(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}

class AppBrand {
  AppBrand._();

  static const String defaultIconKey = 'verified';

  /// The look in use right now. The default is the app's own look.
  static final ValueNotifier<AppBrandModel> current =
      ValueNotifier(const AppBrandModel());

  static AppBrandModel get value => current.value;

  static void update(AppBrandModel brand) => current.value = brand;

  static void reset() => current.value = const AppBrandModel();

  /// The app name in the current language.
  static String get appName =>
      value.hasCustomName ? value.appName!.trim() : 'Visit Proof'.tr;

  static AppBrandIcon get icon =>
      icons.firstWhere((e) => e.key == value.iconKey, orElse: () => icons.first);

  /// Fonts offered in the studio (Google Fonts names).
  static const List<String> englishFonts = [
    'Manrope',
    'Inter',
    'Poppins',
    'Roboto',
    'Montserrat',
    'Nunito',
    'Lato',
    'Open Sans',
    'Rubik',
  ];

  /// Fonts with Arabic letters.
  static const List<String> arabicFonts = [
    'Cairo',
    'Tajawal',
    'Almarai',
    'IBM Plex Sans Arabic',
    'Noto Kufi Arabic',
    'Noto Sans Arabic',
    'Readex Pro',
    'Changa',
    'El Messiri',
    'Rubik',
  ];

  static const double minFontScale = .85;
  static const double maxFontScale = 1.25;

  static const List<AppBrandPreset> presets = [
    AppBrandPreset('Violet', Color(0xFF6C5CE7), Color(0xFF00CEC9)),
    AppBrandPreset('Ocean', Color(0xFF0B63CE), Color(0xFF14B8A6)),
    AppBrandPreset('Emerald', Color(0xFF0F9D58), Color(0xFF7CB342)),
    AppBrandPreset('Sunset', Color(0xFFE8590C), Color(0xFFF59F00)),
    AppBrandPreset('Ruby', Color(0xFFC2185B), Color(0xFF7B1FA2)),
    AppBrandPreset('Graphite', Color(0xFF37474F), Color(0xFF00897B)),
    AppBrandPreset('Royal', Color(0xFF283593), Color(0xFFD4A017)),
    AppBrandPreset('Sky', Color(0xFF0288D1), Color(0xFF26C6DA)),
  ];

  static const List<AppBrandIcon> icons = [
    AppBrandIcon(defaultIconKey, 'Proof badge', Icons.verified_rounded),
    AppBrandIcon('hvac', 'Air conditioning', Icons.ac_unit_rounded),
    AppBrandIcon('maintenance', 'Maintenance', Icons.build_rounded),
    AppBrandIcon('electrical', 'Electrical', Icons.bolt_rounded),
    AppBrandIcon('plumbing', 'Plumbing', Icons.plumbing_rounded),
    AppBrandIcon('cleaning', 'Cleaning', Icons.cleaning_services_rounded),
    AppBrandIcon('pest', 'Pest control', Icons.pest_control_rounded),
    AppBrandIcon('solar', 'Solar', Icons.solar_power_rounded),
    AppBrandIcon('security', 'Security & cameras', Icons.videocam_rounded),
    AppBrandIcon('engineering', 'Engineering', Icons.engineering_rounded),
    AppBrandIcon('home', 'Home services', Icons.home_repair_service_rounded),
    AppBrandIcon('inspection', 'Inspection', Icons.fact_check_rounded),
  ];

  /// #RRGGBB.
  static String hex(Color color) =>
      '#${[color.r, color.g, color.b].map((c) => (c * 255).round().toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';

  static Color? parseHex(String text) {
    final hex = text.replaceAll('#', '').trim();
    final value = int.tryParse(hex, radix: 16);
    if (hex.length != 6 || value == null) return null;
    return Color(0xFF000000 | value);
  }

  /// The customer's design, as saved with their request and given back at
  /// build time (see [fromEnvironment]).
  static Map<String, dynamic> toJson(AppBrandModel brand) => {
        'appName': brand.hasCustomName ? brand.appName!.trim() : null,
        'colors': {
          for (final entry in brand.colors.entries)
            entry.key.name: hex(entry.value)
        },
        'icon': brand.logo == null ? brand.iconKey : 'custom-logo',
        'logoBase64': brand.logo == null ? null : base64Encode(brand.logo!),
        'fontEnglish': brand.fontEnglish,
        'fontArabic': brand.fontArabic,
        'fontScale': brand.fontScale,
      };

  /// A customer's design given at build time, the request's design JSON
  /// without the logo:
  ///   --dart-define=BRAND={"colors":{"primary":"#0B63CE"},"appName":"Cool Air","icon":"hvac"}
  static AppBrandModel fromEnvironment() {
    const raw = String.fromEnvironment('BRAND');
    if (raw.isEmpty) return const AppBrandModel();
    try {
      return fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return const AppBrandModel();
    }
  }

  /// Reads [toJson] back, logo included. Throws on malformed data.
  static AppBrandModel fromJson(Map<String, dynamic> json) {
    final colors = <AppBrandColor, Color>{};
    final savedColors = json['colors'];
    if (savedColors is Map) {
      for (final slot in AppBrandColor.values) {
        final color = parseHex('${savedColors[slot.name] ?? ''}');
        if (color != null) colors[slot] = color;
      }
    }
    final icon = '${json['icon'] ?? defaultIconKey}';
    final logo = json['logoBase64'];
    return AppBrandModel(
      colors: colors,
      appName: json['appName'] as String?,
      iconKey: icons.any((e) => e.key == icon) ? icon : defaultIconKey,
      logo: logo is String ? base64Decode(logo) : null,
      fontEnglish: json['fontEnglish'] as String?,
      fontArabic: json['fontArabic'] as String?,
      fontScale: (json['fontScale'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
