import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../widgets/studio_widget_panel.dart';
import '../widgets/website_widget_parts.dart';
import '../widgets/website_widget_sections.dart';
import 'website_request_scr.dart';
import 'website_studio_scr.dart';
import '../website_theme.dart';

/// The browser build: the sales website, with the app inside as a demo.
class WebsiteApp extends StatelessWidget {
  const WebsiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '{0} — field visits with proof'.trArgs(['Visit Proof'.tr]),
      debugShowCheckedModeBanner: false,
      theme: WebTheme.materialTheme,
      locale: AppLanguage.locale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const WebsiteScr(),
    );
  }
}

/// The landing page: what the app does, how to get it and what it costs.
class WebsiteScr extends StatefulWidget {
  const WebsiteScr({super.key});

  @override
  State<WebsiteScr> createState() => _WebsiteScrState();
}

class _WebsiteScrState extends State<WebsiteScr> {
  final _features = GlobalKey();
  final _pricing = GlobalKey();
  final _faq = GlobalKey();

  /// "?demo" opens the studio straight away ("?demo=admin" or
  /// "?demo=technician" also signs in) and "?request" the request page, so
  /// a link can take a customer directly there.
  @override
  void initState() {
    super.initState();
    final query = Uri.base.queryParameters;
    if (query.containsKey('demo')) {
      final role = query['demo'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openStudio();
        if (role == 'admin' || role == 'technician') {
          StudioWidgetPanel.viewAs(technician: role == 'technician');
        }
      });
    } else if (query.containsKey('request')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openRequest());
    }
  }

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _openStudio() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const WebsiteStudioScr()));

  void _openRequest() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const WebsiteRequestScr()));

  @override
  Widget build(BuildContext context) {
    final wide = WebsiteLayout.isWide(context);

    return Scaffold(
      backgroundColor: WebTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: WebTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: WebTheme.shadowColor,
        automaticallyImplyLeading: false,
        titleSpacing: WebsiteLayout.gutter(context),
        title: const WebsiteLogo(),
        actions: [
          if (wide) ...[
            _NavLink('Features'.tr, () => _scrollTo(_features)),
            _NavLink('Pricing'.tr, () => _scrollTo(_pricing)),
            _NavLink('FAQ'.tr, () => _scrollTo(_faq)),
          ],
          const WebsiteLanguageButton(),
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: 6, end: WebsiteLayout.gutter(context)),
            child: FilledButton(
              onPressed: _openStudio,
              style: FilledButton.styleFrom(
                  backgroundColor: WebTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text(wide ? 'Try the demo'.tr : 'Demo'.tr,
                  style: WebTheme.font(
                      color: WebTheme.onPrimary, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            WebsiteHero(
                onTryDemo: _openStudio, onPricing: () => _scrollTo(_pricing)),
            KeyedSubtree(key: _features, child: const WebsiteFeatures()),
            WebsiteSteps(onTryDemo: _openStudio),
            KeyedSubtree(
                key: _pricing, child: WebsitePricing(onRequest: _openRequest)),
            const WebsiteDelivery(),
            KeyedSubtree(key: _faq, child: const WebsiteFaq()),
            WebsiteClosing(onTryDemo: _openStudio),
            const WebsiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.text, this.onTap);
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(text,
          style: WebTheme.font(
              color: WebTheme.textSecondary, fontWeight: FontWeight.w700)),
    );
  }
}
