/// Not a browser: nothing to install.
class PwaBridge {
  PwaBridge._();

  static void setManifest(
      String json, String icon, String themeColor, String title) {}

  static void resetManifest() {}

  static bool get canPrompt => false;

  /// 'accepted', 'dismissed' or 'unavailable'.
  static Future<String> prompt() async => 'unavailable';

  static bool get isIos => false;

  static bool get isStandalone => false;

  static void useInstalledUrls(String design) {}
}
