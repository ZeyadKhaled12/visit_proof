import 'local_pref.dart';

/// The admin's defaults for new visits. A single visit can still be changed
/// on its own form.
class CompanySettings {
  CompanySettings._();

  static const String _beforeKey = 'require_before_photos';
  static const String _afterKey = 'require_after_photos';
  static const String _vatNumberKey = 'vat_number';

  static const int vatPercent = 15;

  static bool get requireBeforePhotos =>
      LocalPref.sharedPreferences.getBool(_beforeKey) ?? false;

  static bool get requireAfterPhotos =>
      LocalPref.sharedPreferences.getBool(_afterKey) ?? false;

  /// Empty while the company is not registered for VAT.
  static String get vatNumber =>
      LocalPref.sharedPreferences.getString(_vatNumberKey) ?? '';

  static bool get vatRegistered => vatNumber.isNotEmpty;

  /// A Saudi VAT number: 15 digits, the first and last being 3.
  static bool isValidVatNumber(String value) =>
      RegExp(r'^3\d{13}3$').hasMatch(value);

  static int vatCents(int taxableCents) =>
      (taxableCents * vatPercent / 100).round();

  /// Null means the company is not registered.
  static Future<void> setVatNumber(String? number) => number == null
      ? LocalPref.sharedPreferences.remove(_vatNumberKey)
      : LocalPref.sharedPreferences.setString(_vatNumberKey, number);

  static Future<void> setRequireBeforePhotos(bool value) =>
      LocalPref.sharedPreferences.setBool(_beforeKey, value);

  static Future<void> setRequireAfterPhotos(bool value) =>
      LocalPref.sharedPreferences.setBool(_afterKey, value);
}
