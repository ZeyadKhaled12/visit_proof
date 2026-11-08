import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../core/demo/demo_mode.dart';
import '../studio_scenario.dart';
import '../widgets/studio_widget_dock.dart';
import '../widgets/studio_widget_install.dart';
import '../widgets/studio_widget_phone.dart';
import '../widgets/website_widget_brand.dart';
import '../widgets/website_widget_offer.dart';
import '../widgets/website_widget_parts.dart';
import 'website_request_scr.dart';
import 'website_scr.dart';
import '../website_theme.dart';

/// The website's first screen: the real app, a guide through its full cycle
/// and the design tools. On a computer the app sits in a phone frame beside
/// them; on a phone it fills the screen with them docked underneath.
class WebsiteStudioScr extends StatefulWidget {
  const WebsiteStudioScr({super.key});

  /// What the "Request a copy" buttons do:
  ///   false — open the request form ([WebsiteRequestScr]) to send the
  ///           design and the changes wanted;
  ///   true  — install the designed app on the device as a PWA
  ///           ([StudioInstall]).
  /// See the note in main.dart.
  static const bool requestInstallsApp = false;

  @override
  State<WebsiteStudioScr> createState() => _WebsiteStudioScrState();
}

enum _Menu { language, details, restart, simulate, fullCompany }

class _WebsiteStudioScrState extends State<WebsiteStudioScr> {
  static const double _dockWidth = 400;

  final _scenario = StudioScenario();
  bool _offerShown = false;

  @override
  void initState() {
    super.initState();
    if (WebsiteStudioScr.requestInstallsApp) StudioInstall.start();
    _scenario
      ..start()
      ..addListener(_onScenario);
    _openFromLink();
  }

  /// "?demo=technician" opens the app as the technician, "?request" the
  /// request page and "?site" the details page, so a link can take a
  /// customer directly there.
  void _openFromLink() {
    final query = Uri.base.queryParameters;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query['demo'] == 'technician') {
        StudioScenario.viewAs(technician: true);
      } else if (query.containsKey('request')) {
        _openRequest();
      } else if (query.containsKey('site')) {
        _openDetails();
      }
    });
  }

  @override
  void dispose() {
    if (WebsiteStudioScr.requestInstallsApp) StudioInstall.stop();
    _scenario.dispose();
    super.dispose();
  }

  /// Finishing the cycle is when the offer means the most.
  void _onScenario() {
    final finished = _scenario.step == StudioStep.finished;
    if (finished && !_offerShown && !_scenario.exploring) {
      _offerShown = true;
      _showOffer(finished: true);
    } else if (!finished) {
      _offerShown = false;
    }
  }

  void _showOffer({bool finished = false}) => WebsiteOfferCard.show(context,
      finished: finished, onRequest: _request);

  void _request() =>
      WebsiteStudioScr.requestInstallsApp ? StudioInstall.install(context) : _openRequest();

  void _openRequest() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const WebsiteRequestScr()));

  void _openDetails() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const WebsiteScr()));

  void _onMenu(_Menu item) {
    switch (item) {
      case _Menu.language:
        AppLanguage.arabic.value = !AppLanguage.isArabic;
      case _Menu.details:
        _openDetails();
      case _Menu.restart:
        _scenario.restart();
      case _Menu.simulate:
        DemoMode.simulateOnSite.value = !DemoMode.simulateOnSite.value;
      case _Menu.fullCompany:
        _scenario.restart(fullCompany: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final dock = StudioWidgetDock(
        scenario: _scenario, wide: wide, onOffer: _showOffer);

    return Scaffold(
      backgroundColor: WebTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: WebTheme.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: InkWell(onTap: _openDetails, child: const _Title()),
        actions: [
          if (wide) ...[
            TextButton(
              onPressed: _openDetails,
              child: Text('Details and pricing'.tr,
                  style: WebTheme.font(
                      color: WebTheme.textSecondary,
                      fontWeight: FontWeight.w700)),
            ),
            const WebsiteLanguageButton(),
          ],
          IconButton(
            tooltip: 'The offer'.tr,
            onPressed: _showOffer,
            icon: const Icon(Icons.redeem_rounded, color: WebTheme.accentText),
          ),
          _menu(wide),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2, end: 10),
            child: FilledButton(
              onPressed: _request,
              style: FilledButton.styleFrom(
                  backgroundColor: WebTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Request a copy'.tr,
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
                    width: _dockWidth, color: WebTheme.surface, child: dock),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: StudioWidgetPhone()),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => StudioWidgetAppScreen(
                        size: Size(
                            constraints.maxWidth, constraints.maxHeight)),
                  ),
                ),
                dock,
              ],
            ),
    );
  }

  Widget _menu(bool wide) {
    PopupMenuItem<_Menu> item(_Menu value, IconData icon, String text) =>
        PopupMenuItem(
          value: value,
          child: Row(children: [
            Icon(icon, color: WebTheme.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: WebTheme.font(
                      color: WebTheme.textPrimary,
                      fontSize: WebTheme.textBodyLarge)),
            ),
          ]),
        );

    return PopupMenuButton<_Menu>(
      tooltip: 'More'.tr,
      color: WebTheme.surface,
      icon: const Icon(Icons.more_vert_rounded, color: WebTheme.textPrimary),
      onSelected: _onMenu,
      itemBuilder: (context) => [
        if (!wide) ...[
          item(_Menu.language, Icons.translate_rounded,
              AppLanguage.isArabic ? 'English' : 'العربية'),
          item(_Menu.details, Icons.info_outline_rounded,
              'Details and pricing'.tr),
        ],
        item(_Menu.restart, Icons.replay_rounded, 'Start the scenario again'.tr),
        item(
            _Menu.simulate,
            DemoMode.simulateOnSite.value
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            'Pretend I am at the site'.tr),
        item(_Menu.fullCompany, Icons.business_rounded,
            'Explore a large sample company'.tr),
      ],
    );
  }
}

/// What this app is, always in view.
class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A phone's bar keeps its room for the words.
        if (MediaQuery.sizeOf(context).width >= 600) ...[
          const WizpoMark(size: 30),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Visit Proof'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WebTheme.font(
                      color: WebTheme.textPrimary,
                      fontSize: WebTheme.textTitle,
                      fontWeight: FontWeight.w800,
                      height: 1.2)),
              Text('For managing technicians and maintenance'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WebTheme.font(
                      color: WebTheme.accentText,
                      fontSize: WebTheme.textCaption,
                      fontWeight: FontWeight.w700,
                      height: 1.2)),
            ],
          ),
        ),
      ],
    );
  }
}
