import 'dart:async';
import 'dart:convert';

import '../../../../configs/app_brand.dart';
import '../../../../configs/app_theme.dart';
import '../../../../core/local/local_pref.dart';

/// Keeps the design a visitor made in the browser, so it is still there when
/// they close the website and come back.
class WebsiteDesignLocalDataSource {
  WebsiteDesignLocalDataSource._();

  static const String key = 'website_design';
  static const Duration _saveDelay = Duration(milliseconds: 250);

  /// The page opened with a design from an earlier visit.
  static bool restored = false;

  static Timer? _pending;

  /// The visitor has changed something from the app's own look.
  static bool get isCustom {
    final brand = AppBrand.value;
    return brand.colors.isNotEmpty ||
        brand.hasCustomName ||
        brand.logo != null ||
        brand.iconKey != AppBrand.defaultIconKey ||
        brand.fontArabic != null ||
        brand.fontEnglish != null ||
        brand.fontScale != 1.0 ||
        AppTheme.isDark;
  }

  /// Puts the saved design back on screen. A damaged one is dropped.
  static void restore() {
    final saved = LocalPref.sharedPreferences.getString(key);
    if (saved == null) return;
    try {
      final json = Map<String, dynamic>.from(jsonDecode(saved) as Map);
      AppBrand.update(AppBrand.fromJson(json));
      AppTheme.darkMode.value =
          AppTheme.darkModeEnabled && json['dark'] == true;
      restored = isCustom;
    } catch (_) {
      LocalPref.sharedPreferences.remove(key);
    }
  }

  /// Saves every later change. Dragging a color sends many changes, so
  /// only the last one in a short moment is written.
  static void watch() {
    AppBrand.current.addListener(_saveSoon);
    AppTheme.darkMode.addListener(_saveSoon);
  }

  static void _saveSoon() {
    _pending?.cancel();
    _pending = Timer(_saveDelay, save);
  }

  static Future<void> save() async {
    final prefs = LocalPref.sharedPreferences;
    try {
      if (!isCustom) {
        await prefs.remove(key);
        return;
      }
      await prefs.setString(
          key,
          jsonEncode({
            ...AppBrand.toJson(AppBrand.value),
            'dark': AppTheme.isDark,
          }));
    } catch (_) {
      // A browser can refuse the write (a large logo in a full or private
      // storage). The design stays on screen; it just will not come back.
    }
  }

  /// Back to the app's own look, here and on the next visit.
  static Future<void> clear() async {
    _pending?.cancel();
    restored = false;
    AppBrand.reset();
    AppTheme.darkMode.value = false;
    await LocalPref.sharedPreferences.remove(key);
  }
}
