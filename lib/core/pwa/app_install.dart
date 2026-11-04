import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../configs/app_brand.dart';
import '../../configs/app_language.dart';
import '../../configs/app_theme.dart';
import 'pwa_bridge.dart';

/// What an installed app is opened with: the design chosen in the studio.
class AppInstallPayload {
  const AppInstallPayload(
      {required this.brand, required this.dark, required this.arabic});

  final AppBrandModel brand;

  /// Fixed: the installed app cannot switch it.
  final bool dark;

  /// Only the first language; the user can still switch it.
  final bool arabic;
}

// =============================================================================
// INSTALLED APP — the studio's design as its own PWA.
// =============================================================================
//
// The design travels inside the app's link: <site>/#app=<design>. Opening
// that link (from the installed icon or a browser tab) shows only the Visit
// Proof app with that design and no way to change it (see DemoMode.installedApp
// and main()). The link is the whole app, so nothing has to be stored on a
// server, and the design survives cleared browser data and iPhone's
// separate home-screen storage. It sits after "#", which browsers never send
// to the server: with a logo the design is far longer than the ~8,000
// characters GitHub Pages accepts in a link ("414 URI Too Long").
// =============================================================================
class AppInstall {
  AppInstall._();

  /// The query parameter that carries the design.
  static const String param = 'app';

  /// The design in this page's link, as written there: `#app=<design>`
  /// (followed by `~/<screen>` once the app moves on), or `?app=<design>`
  /// in links made before the design moved behind "#".
  static final String? openedRaw = kIsWeb ? _readRaw(Uri.base) : null;

  static String? _readRaw(Uri url) {
    final fragment = url.fragment;
    if (fragment.startsWith('$param=')) {
      final design = fragment.substring(param.length + 1);
      final screen = design.indexOf('~');
      return screen < 0 ? design : design.substring(0, screen);
    }
    return url.queryParameters[param];
  }

  /// The design this page was opened with, or null for the website.
  static final AppInstallPayload? opened = decode(openedRaw);

  /// Logos are made small before they go into the link.
  static const int _logoSize = 192;

  /// The current design (studio): brand, light/dark and language.
  static Future<String> encodeCurrent() async {
    var brand = AppBrand.value;
    final logo = brand.logo;
    if (logo != null) brand = brand.copyWith(logo: await _shrink(logo));
    final json = jsonEncode({
      'brand': AppBrand.toJson(brand),
      'dark': AppTheme.isDark,
      'ar': AppLanguage.isArabic,
    });
    return base64Url.encode(utf8.encode(json)).replaceAll('=', '');
  }

  static AppInstallPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = Map<String, dynamic>.from(jsonDecode(
              utf8.decode(base64Url.decode(base64Url.normalize(raw))))
          as Map);
      return AppInstallPayload(
        brand: AppBrand.fromJson(Map<String, dynamic>.from(json['brand'])),
        dark: json['dark'] == true,
        arabic: json['ar'] == true,
      );
    } catch (_) {
      return null;
    }
  }

  /// Short and stable for one design: tells installed apps apart.
  static String idOf(String raw) {
    var hash = 0x811c9dc5;
    for (final unit in raw.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// Each installed design keeps its own saved data, apart from the
  /// website demo (which wipes its own on every start).
  static String get storagePrefix => 'vp_app_${idOf(openedRaw ?? '')}.';

  /// The site's folder, e.g. https://…/visit_proof/.
  static String get _scope {
    final url = '${Uri.base.origin}${Uri.base.path}';
    return url.substring(0, url.lastIndexOf('/') + 1);
  }

  /// The link the installed app opens.
  static String urlFor(String raw) => '$_scope#$param=$raw';

  /// Gives the page the manifest of the design in [raw], styled with the
  /// brand that is active now (the studio's, or the installed app's).
  static Future<void> publish(String raw) async {
    final name = AppBrand.appName;
    final icon192 = await _icon(192);
    final icon512 = await _icon(512);
    final mask192 = await _icon(192, maskable: true);
    final mask512 = await _icon(512, maskable: true);
    final manifest = jsonEncode({
      'id': '$_scope?$param-id=${idOf(raw)}',
      'name': name,
      'short_name': name,
      'start_url': urlFor(raw),
      'scope': _scope,
      'display': 'standalone',
      'orientation': 'portrait',
      'background_color': AppBrand.hex(AppTheme.scaffoldBackground),
      'theme_color': AppBrand.hex(AppTheme.primary),
      'icons': [
        _iconEntry(icon192, 192, 'any'),
        _iconEntry(icon512, 512, 'any'),
        _iconEntry(mask192, 192, 'maskable'),
        _iconEntry(mask512, 512, 'maskable'),
      ],
    });
    PwaBridge.setManifest(
        manifest, icon192, AppBrand.hex(AppTheme.primary), name);
  }

  static Map<String, String> _iconEntry(String src, int size, String purpose) =>
      {
        'src': src,
        'sizes': '${size}x$size',
        'type': 'image/png',
        'purpose': purpose,
      };

  /// The app icon as a PNG data URL: the logo, or the picked icon on the
  /// main color. A maskable icon fills the square and keeps its content in
  /// the middle, where every phone's icon shape leaves it whole.
  static Future<String> _icon(int size, {bool maskable = false}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final s = size.toDouble();
    final square = Rect.fromLTWH(0, 0, s, s);
    final background = Paint()..color = AppTheme.primary;
    if (maskable) {
      canvas.drawRect(square, background);
    } else {
      canvas.drawRRect(
          RRect.fromRectAndRadius(square, Radius.circular(s * .22)), background);
    }

    final logo = AppBrand.value.logo;
    if (logo != null) {
      final codec = await ui.instantiateImageCodec(logo, targetWidth: size);
      final image = (await codec.getNextFrame()).image;
      final box = maskable
          ? Rect.fromCenter(center: square.center, width: s * .7, height: s * .7)
          : square;
      canvas.save();
      canvas.clipRRect(
          RRect.fromRectAndRadius(box, Radius.circular(box.width * .22)));
      paintImage(canvas: canvas, rect: box, image: image, fit: BoxFit.cover);
      canvas.restore();
    } else {
      final icon = AppBrand.icon.icon;
      final painter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            fontSize: s * (maskable ? .45 : .58),
            color: AppTheme.onPrimary,
          ),
        ),
      )..layout();
      painter.paint(canvas,
          square.center - Offset(painter.width / 2, painter.height / 2));
    }

    final image = await recorder.endRecording().toImage(size, size);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    return 'data:image/png;base64,${base64Encode(png!.buffer.asUint8List())}';
  }

  static Future<Uint8List> _shrink(Uint8List logo) async {
    final codec = await ui.instantiateImageCodec(logo, targetWidth: _logoSize);
    final image = (await codec.getNextFrame()).image;
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    return png!.buffer.asUint8List();
  }
}
