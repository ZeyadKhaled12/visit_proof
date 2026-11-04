// The browser's install features (`window.wizpoPwa` in web/index.html).
// Phones and computers running the app natively get the do-nothing stub.
export 'pwa_bridge_stub.dart' if (dart.library.js_interop) 'pwa_bridge_web.dart';
