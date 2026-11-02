import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../widgets/studio_widget_panel.dart';
import '../widgets/studio_widget_phone.dart';
import '../widgets/website_widget_parts.dart';
import 'website_request_scr.dart';
import '../website_theme.dart';

/// The live demo with the design studio. On a computer the controls sit
/// beside a phone preview; on a phone the app fills the screen and the
/// controls open from the top bar.
class WebsiteStudioScr extends StatelessWidget {
  const WebsiteStudioScr({super.key});

  static const double _panelWidth = 400;

  void _request(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const WebsiteRequestScr()));

  void _openPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: WebTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * .85,
        child: StudioWidgetPanel(onRequest: () {
          Navigator.pop(sheetContext);
          _request(context);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      backgroundColor: WebTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: WebTheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: WebTheme.textPrimary),
        title: wide
            ? const WebsiteLogo()
            : Text('Live demo'.tr,
                style: WebTheme.font(
                    color: WebTheme.textPrimary, fontWeight: FontWeight.w800)),
        actions: [
          if (!wide)
            IconButton(
              tooltip: 'Design your app'.tr,
              onPressed: () => _openPanel(context),
              icon: Icon(Icons.palette_rounded, color: WebTheme.primary),
            ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: () => _request(context),
              style: FilledButton.styleFrom(
                  backgroundColor: WebTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              icon: Icon(Icons.send_rounded,
                  color: WebTheme.onPrimary, size: 18),
              label: Text(wide ? 'Request this version'.tr : 'Request'.tr,
                  style: WebTheme.font(
                      color: WebTheme.onPrimary, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                Container(
                  width: _panelWidth,
                  color: WebTheme.surface,
                  child: StudioWidgetPanel(onRequest: () => _request(context)),
                ),
                // The phone takes the full height; the hint sits beside it.
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 3, child: Center(child: StudioWidgetPhone())),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(end: 16),
                            child: Text(
                                'This is the real app with a sample company. Tap around.'
                                    .tr,
                                style: WebTheme.font(
                                    color: WebTheme.textSecondary,
                                    fontSize: WebTheme.textBody,
                                    height: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) => StudioWidgetAppScreen(
                  size: Size(constraints.maxWidth, constraints.maxHeight)),
            ),
    );
  }
}
