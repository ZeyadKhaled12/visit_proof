import 'dart:async';

import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../configs/app_brand.dart';
import '../../../../configs/app_theme.dart';
import '../../../../core/pwa/app_install.dart';
import '../../../../core/pwa/pwa_bridge.dart';
import '../website_theme.dart';

/// The studio's "Request" button when it installs the designed app (see
/// WebsiteStudioScr.requestInstallsApp and the note in main.dart).
///
/// While the studio is open, the page's install manifest follows the
/// design, so the browser is ready to install it the moment the button is
/// pressed. Where a page cannot install by itself (iPhone, Firefox, or the
/// browser is not ready yet), the designed app opens in a new tab with the
/// steps to add it.
class StudioInstall {
  StudioInstall._();

  static Timer? _timer;
  static String? _raw;
  static bool _watching = false;

  /// Starts following the design (call when the studio opens).
  static void start() {
    if (_watching) return;
    _watching = true;
    AppBrand.current.addListener(_schedule);
    AppTheme.darkMode.addListener(_schedule);
    AppLanguage.arabic.addListener(_schedule);
    _schedule();
  }

  /// Stops, and gives the website its own manifest back.
  static void stop() {
    if (!_watching) return;
    _watching = false;
    AppBrand.current.removeListener(_schedule);
    AppTheme.darkMode.removeListener(_schedule);
    AppLanguage.arabic.removeListener(_schedule);
    _timer?.cancel();
    _raw = null;
    PwaBridge.resetManifest();
  }

  /// Waits until the visitor stops changing the design (dragging a color
  /// sends many changes).
  static void _schedule() {
    _raw = null;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 700), _publish);
  }

  static Future<void> _publish() async {
    final raw = await AppInstall.encodeCurrent();
    if (!_watching) return;
    await AppInstall.publish(raw);
    if (_watching) _raw = raw;
  }

  /// The "Request" button.
  static Future<void> install(BuildContext context) async {
    // The browser's dialog must open straight from the tap.
    if (_raw != null && PwaBridge.canPrompt) {
      final outcome = await PwaBridge.prompt();
      if (outcome == 'accepted' && context.mounted) _installed(context);
      if (outcome != 'unavailable') return;
    }
    final raw = _raw ?? await AppInstall.encodeCurrent();
    if (context.mounted) _openInTab(context, AppInstall.urlFor(raw));
  }

  static void _installed(BuildContext context) => _dialog(
        context,
        icon: Icons.check_circle_rounded,
        iconColor: WebTheme.statGreen,
        title: '{0} is installed'.trArgs([AppBrand.appName]),
        text:
            'Open it from your home screen or your apps. It opens with the design you chose.'
                .tr,
      );

  static void _openInTab(BuildContext context, String url) => _dialog(
        context,
        icon: Icons.install_mobile_rounded,
        iconColor: WebTheme.secondary,
        title: 'Install {0}'.trArgs([AppBrand.appName]),
        text: PwaBridge.isIos
            ? 'Your app opens in a new tab. In Safari, tap Share and then "Add to Home Screen".'
                .tr
            : 'Your app opens in a new tab. Choose "Install" in the bar at the top, or "Install app" in the browser menu.'
                .tr,
        action: 'Open my app'.tr,
        onAction: () => launchUrl(Uri.parse(url), webOnlyWindowName: '_blank'),
      );

  static void _dialog(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String text,
    String? action,
    VoidCallback? onAction,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WebTheme.cardColor,
        icon: Icon(icon, color: iconColor, size: 40),
        title: Text(title,
            textAlign: TextAlign.center,
            style: WebTheme.font(
                color: WebTheme.textPrimary,
                fontSize: WebTheme.textHeadline,
                fontWeight: FontWeight.w800)),
        content: Text(text,
            textAlign: TextAlign.center,
            style: WebTheme.font(
                color: WebTheme.textSecondary,
                fontSize: WebTheme.textBodyLarge,
                height: 1.55)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(action == null ? 'OK'.tr : 'Close'.tr,
                style: WebTheme.font(
                    color: WebTheme.textSecondary,
                    fontWeight: FontWeight.w700)),
          ),
          if (action != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onAction?.call();
              },
              style: FilledButton.styleFrom(
                  backgroundColor: WebTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text(action,
                  style: WebTheme.font(
                      color: WebTheme.onPrimary, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}
