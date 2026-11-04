import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../configs/app_brand.dart';
import '../../../configs/app_theme.dart';
import '../../demo/demo_mode.dart';
import '../../pwa/pwa_bridge.dart';

/// A bar above an installed app that is opened in a browser tab: installs
/// it, or on iPhone says how. Hidden once the app runs from its icon.
class GWidgetInstallBanner extends StatefulWidget {
  const GWidgetInstallBanner({super.key, required this.child});
  final Widget child;

  static bool get applies => DemoMode.installedApp && !PwaBridge.isStandalone;

  @override
  State<GWidgetInstallBanner> createState() => _GWidgetInstallBannerState();
}

class _GWidgetInstallBannerState extends State<GWidgetInstallBanner> {
  bool _closed = false;

  Future<void> _install() async {
    final outcome = await PwaBridge.prompt();
    if (outcome == 'accepted') setState(() => _closed = true);
    if (outcome != 'unavailable' || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text('Install {0}'.trArgs([AppBrand.appName]),
            style: AppTheme.font(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.textTitle,
                fontWeight: FontWeight.w800)),
        content: Text(
            'Open your browser menu and choose "Install app" or "Add to Home Screen".'
                .tr,
            style: AppTheme.font(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.textBody,
                height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'.tr,
                  style: AppTheme.font(
                      color: AppTheme.primary, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_closed || !GWidgetInstallBanner.applies) return widget.child;
    final ios = PwaBridge.isIos;

    return Column(
      children: [
        Material(
          color: AppTheme.primary,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 4, 8),
              child: Row(
                children: [
                  Icon(ios ? Icons.ios_share_rounded : Icons.download_rounded,
                      color: AppTheme.onPrimary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        ios
                            ? 'To install, tap Share and then "Add to Home Screen".'
                                .tr
                            : 'Install this app on your device.'.tr,
                        style: AppTheme.font(
                            color: AppTheme.onPrimary,
                            fontSize: AppTheme.textBody,
                            fontWeight: FontWeight.w700)),
                  ),
                  if (!ios)
                    TextButton(
                      onPressed: _install,
                      child: Text('Install'.tr,
                          style: AppTheme.font(
                              color: AppTheme.onPrimary,
                              fontWeight: FontWeight.w800)),
                    ),
                  IconButton(
                    tooltip: 'Close'.tr,
                    onPressed: () => setState(() => _closed = true),
                    icon: Icon(Icons.close_rounded,
                        color: AppTheme.onPrimary, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
