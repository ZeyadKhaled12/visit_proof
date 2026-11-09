import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_offer.dart';
import '../../../../core/demo/demo_mode.dart';
import '../../../../core/utils/general_functions.dart/g_fun_launch.dart';
import '../../data/datasource/website_design_local_data_source.dart';
import '../studio_scenario.dart';
import '../widgets/studio_widget_bot.dart';
import '../widgets/studio_widget_dock.dart';
import '../widgets/studio_widget_install.dart';
import '../widgets/studio_widget_phone.dart';
import '../widgets/website_widget_brand.dart';
import '../widgets/website_widget_offer.dart';
import '../widgets/website_widget_parts.dart';
import 'website_legal_scr.dart';
import 'website_request_scr.dart';
import 'website_scr.dart';
import '../website_theme.dart';

/// The website's first screen: the real app with Wizpoo guiding the visitor
/// through its full cycle. On a computer the app sits in a phone frame beside
/// the steps and design tools; on a phone it fills the screen and the design
/// tools open under it from the top bar.
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

enum _Menu {
  language,
  details,
  restart,
  simulate,
  fullCompany,
  whatsapp,
  privacy,
  terms
}

class _WebsiteStudioScrState extends State<WebsiteStudioScr> {
  static const double _dockWidth = 340;

  final _scenario = StudioScenario();
  bool _offerShown = false;

  /// Phones show the design tools only when asked, or to a returning visitor
  /// whose design was brought back.
  bool _designOpen = WebsiteDesignLocalDataSource.restored;

  @override
  void initState() {
    super.initState();
    if (WebsiteStudioScr.requestInstallsApp) StudioInstall.start();
    DemoMode.prefillNewVisit = true;
    _scenario
      ..start()
      ..addListener(_onScenario);
    _openFromLink();
  }

  /// "?demo=technician" opens the app as the technician; "?request",
  /// "?site", "?privacy" and "?terms" open those pages, so a link can take a
  /// customer directly there.
  void _openFromLink() {
    final query = Uri.base.queryParameters;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query['demo'] == 'technician') {
        _scenario.skipIntro();
        StudioScenario.viewAs(technician: true);
      } else if (query.containsKey('request')) {
        _openRequest();
      } else if (query.containsKey('site')) {
        _openDetails();
      } else if (query.containsKey('privacy')) {
        WebsiteLegalScr.open(context, WebsiteLegalPage.privacy);
      } else if (query.containsKey('terms')) {
        WebsiteLegalScr.open(context, WebsiteLegalPage.terms);
      }
    });
  }

  @override
  void dispose() {
    if (WebsiteStudioScr.requestInstallsApp) StudioInstall.stop();
    DemoMode.prefillNewVisit = false;
    _scenario.dispose();
    super.dispose();
  }

  /// Finishing the cycle is when the offer means the most. A payment just
  /// confirmed is left on screen: the visitor opens the offer when ready, and
  /// nothing appears under their pointer as they reach for a button.
  void _onScenario() {
    final finished = _scenario.step == StudioStep.finished;
    if (finished && !_offerShown && !_scenario.exploring) {
      _offerShown = true;
      if (!_scenario.paymentConfirmed) _showOffer();
    } else if (!finished) {
      _offerShown = false;
    }
  }

  void _showOffer() => WebsiteOfferCard.show(context,
      finished: _scenario.step == StudioStep.finished, onRequest: _request);

  void _openWhatsapp() => GFunLaunch.openWhatsApp(AppOffer.whatsappNumber);

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
      case _Menu.whatsapp:
        _openWhatsapp();
      case _Menu.privacy:
        WebsiteLegalScr.open(context, WebsiteLegalPage.privacy);
      case _Menu.terms:
        WebsiteLegalScr.open(context, WebsiteLegalPage.terms);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final dock = StudioWidgetDock(
        scenario: _scenario, wide: wide, onOffer: _showOffer);
    final bot = StudioWidgetBot(scenario: _scenario, onOffer: _showOffer);

    return Scaffold(
      backgroundColor: WebTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: WebTheme.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
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
          if (!wide)
            IconButton(
              tooltip: 'Design your app'.tr,
              isSelected: _designOpen,
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _designOpen = !_designOpen),
              icon: const Icon(Icons.palette_outlined,
                  color: WebTheme.textPrimary),
              selectedIcon: const Icon(Icons.palette_rounded,
                  color: WebTheme.accentText),
            ),
          IconButton(
            tooltip: 'The offer'.tr,
            visualDensity: VisualDensity.compact,
            onPressed: _showOffer,
            icon: const Icon(Icons.redeem_rounded, color: WebTheme.accentText),
          ),
          _menu(wide),
          if (AppOffer.hasWhatsapp && wide)
            TextButton.icon(
              onPressed: _openWhatsapp,
              icon: const Icon(Icons.whatsapp, color: WebTheme.whatsapp),
              label: Text(AppOffer.whatsappDisplay,
                  style: WebTheme.font(
                      color: WebTheme.textPrimary,
                      fontWeight: FontWeight.w700)),
            ),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Center(child: StudioWidgetPhone(overlay: bot)),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) =>
                            StudioWidgetAppScreen(
                                size: Size(constraints.maxWidth,
                                    constraints.maxHeight),
                                overlay: bot),
                      ),
                      if (AppOffer.hasWhatsapp &&
                          MediaQuery.viewInsetsOf(context).bottom == 0)
                        // Above Wizpoo's bubble and the screens' bottom buttons.
                        const PositionedDirectional(
                          end: 10,
                          bottom: 200,
                          child: WebsiteWhatsappButton(),
                        ),
                    ],
                  ),
                ),
                if (_designOpen) dock,
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
        if (AppOffer.hasWhatsapp)
          item(_Menu.whatsapp, Icons.whatsapp,
              'WhatsApp: {0}'.trArgs([AppOffer.whatsappDisplay])),
        item(_Menu.privacy, Icons.privacy_tip_outlined, 'Privacy policy'.tr),
        item(_Menu.terms, Icons.description_outlined, 'Terms of service'.tr),
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
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text('For managing technicians and maintenance'.tr,
                    maxLines: 1,
                    style: WebTheme.font(
                        color: WebTheme.accentText,
                        fontSize: WebTheme.textCaption,
                        fontWeight: FontWeight.w700,
                        height: 1.2)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
