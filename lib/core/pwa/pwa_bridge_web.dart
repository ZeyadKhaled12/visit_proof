import 'dart:js_interop';

@JS('wizpoPwa')
external _WizpoPwa? get _pwa;

extension type _WizpoPwa._(JSObject _) implements JSObject {
  external void setManifest(
      String json, String icon, String themeColor, String title);
  external void resetManifest();
  external bool canPrompt();
  external JSPromise<JSString> prompt();
  external bool isIos();
  external bool isStandalone();
}

/// The install helpers in web/index.html.
class PwaBridge {
  PwaBridge._();

  /// Replaces the page's manifest, so installing gives this app.
  static void setManifest(
          String json, String icon, String themeColor, String title) =>
      _pwa?.setManifest(json, icon, themeColor, title);

  /// Back to the website's own (Wizpo) manifest.
  static void resetManifest() => _pwa?.resetManifest();

  /// The browser has offered to install the current manifest.
  static bool get canPrompt => _pwa?.canPrompt() ?? false;

  /// Shows the browser's install dialog: 'accepted', 'dismissed' or
  /// 'unavailable'. Must run straight from a tap.
  static Future<String> prompt() async {
    final pwa = _pwa;
    if (pwa == null) return 'unavailable';
    return (await pwa.prompt().toDart).toDart;
  }

  /// iPhone and iPad: installing is only possible from Safari's Share menu.
  static bool get isIos => _pwa?.isIos() ?? false;

  /// Running as an installed app, not in a browser tab.
  static bool get isStandalone => _pwa?.isStandalone() ?? false;
}
