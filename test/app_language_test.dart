import 'package:flutter_test/flutter_test.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'package:visit_proof/configs/app_translations.dart';

void main() {
  tearDown(() => AppLanguage.arabic.value = false);

  test('English returns the key unchanged', () {
    AppLanguage.arabic.value = false;
    expect('Log out'.tr, 'Log out');
    expect('Visits assigned: {0}'.trArgs([3]), 'Visits assigned: 3');
  });

  test('Arabic returns the translation and fills placeholders', () {
    AppLanguage.arabic.value = true;
    expect('Log out'.tr, 'تسجيل الخروج');
    expect(AppLanguage.locale.languageCode, 'ar');
    final filled = 'Visits assigned: {0}'.trArgs([3]);
    expect(filled, contains('3'));
    expect(filled, isNot(contains('{0}')));
  });

  test('Arabic falls back to English for unknown text', () {
    AppLanguage.arabic.value = true;
    expect('client@example.com'.tr, 'client@example.com');
  });

  test('every translation keeps the same placeholders as its key', () {
    final placeholder = RegExp(r'\{\d+\}');
    for (final entry in arabicTranslations.entries) {
      final inKey = placeholder.allMatches(entry.key).map((m) => m[0]).toSet();
      final inValue =
          placeholder.allMatches(entry.value).map((m) => m[0]).toSet();
      expect(inValue.difference(inKey), isEmpty, reason: entry.key);
    }
  });
}
