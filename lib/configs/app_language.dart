// =============================================================================
// APP LANGUAGE — English / Arabic switching.
// =============================================================================
//
// Every text in the app is written in English and passed through `.tr`
// (or `.trArgs([...])` when it contains values). In Arabic mode the text is
// looked up in app_translations.dart; anything not found stays in English.
//
//   Text('Visits'.tr)
//   Text('{0} visits today'.trArgs([count]))   // {0}, {1}… are the values
//
// To change a translation, edit app_translations.dart only.
// =============================================================================

import 'package:flutter/material.dart';

import 'app_translations.dart';

class AppLanguage {
  AppLanguage._();

  /// Shows the language switch in the app menu.
  static const bool languageSwitchEnabled = true;

  /// Starting language before the user picks one.
  static const bool arabicByDefault = false;

  /// Current language. Changed by the switch; the app restyles itself and
  /// flips to right-to-left for Arabic.
  static final ValueNotifier<bool> arabic = ValueNotifier(arabicByDefault);

  static bool get isArabic => arabic.value;

  static Locale get locale => Locale(isArabic ? 'ar' : 'en');

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];
}

extension AppTranslate on String {
  /// This text in the current language.
  String get tr =>
      AppLanguage.isArabic ? (arabicTranslations[this] ?? this) : this;

  /// Translates, then fills {0}, {1}… with [args] in order.
  String trArgs(List<Object?> args) {
    var text = tr;
    for (var i = 0; i < args.length; i++) {
      text = text.replaceAll('{$i}', '${args[i]}');
    }
    return text;
  }
}
