import 'local_pref.dart';

/// The admin's defaults for new visits. A single visit can still be changed
/// on its own form.
class CompanySettings {
  CompanySettings._();

  static const String _beforeKey = 'require_before_photos';
  static const String _afterKey = 'require_after_photos';

  static bool get requireBeforePhotos =>
      LocalPref.sharedPreferences.getBool(_beforeKey) ?? false;

  static bool get requireAfterPhotos =>
      LocalPref.sharedPreferences.getBool(_afterKey) ?? false;

  static Future<void> setRequireBeforePhotos(bool value) =>
      LocalPref.sharedPreferences.setBool(_beforeKey, value);

  static Future<void> setRequireAfterPhotos(bool value) =>
      LocalPref.sharedPreferences.setBool(_afterKey, value);
}
