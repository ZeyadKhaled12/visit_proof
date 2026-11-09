import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../../configs/app_offer.dart';
import '../widgets/website_widget_brand.dart';
import '../widgets/website_widget_offer.dart';
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
      title: WebsiteBrand.pageTitle,
      debugShowCheckedModeBanner: false,
      theme: WebTheme.materialTheme,
      locale: AppLanguage.locale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const WebsiteStudioScr(),
    );
  }
}

/// The details page, opened from the app: Wizpo's apps, then the one
/// available today (Visit Proof) — what it does, how to get it and what it
/// costs.
class WebsiteScr extends StatefulWidget {
  const WebsiteScr({super.key});

  @override
  State<WebsiteScr> createState() => _WebsiteScrState();
}

class _WebsiteScrState extends State<WebsiteScr> {
  final _apps = GlobalKey();
  final _features = GlobalKey();
  final _pricing = GlobalKey();
  final _faq = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(target,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  /// This page is opened on top of the app.
  void _openStudio() => Navigator.maybePop(context);

  void _openRequest() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const WebsiteRequestScr()));

  @override
  Widget build(BuildContext context) {
    final wide = WebsiteLayout.isWide(context);

    return Scaffold(
      floatingActionButton:
          AppOffer.hasWhatsapp ? const WebsiteWhatsappButton() : null,
      backgroundColor: WebTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: WebTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: WebTheme.shadowColor,
        iconTheme: const IconThemeData(color: WebTheme.textPrimary),
        title: const WebsiteLogo(),
        actions: [
          if (wide) ...[
            _NavLink('Apps'.tr, () => _scrollTo(_apps)),
            _NavLink('Visit Proof'.tr, () => _scrollTo(_features)),
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
                onTryDemo: _openStudio, onBrowse: () => _scrollTo(_apps)),
            WebsiteOfferSection(onRequest: _openRequest),
            KeyedSubtree(
                key: _apps,
                child: WebsiteApps(
                    onTryDemo: _openStudio,
                    onDetails: () => _scrollTo(_features))),
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
