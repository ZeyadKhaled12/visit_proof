import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_offer.dart';
import '../widgets/website_widget_parts.dart';
import '../website_theme.dart';

enum WebsiteLegalPage { privacy, terms }

/// The privacy policy and the terms of service, in the site's two languages.
class WebsiteLegalScr extends StatelessWidget {
  const WebsiteLegalScr({super.key, required this.page});
  final WebsiteLegalPage page;

  static Future<void> open(BuildContext context, WebsiteLegalPage page) =>
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => WebsiteLegalScr(page: page)));

  String get _title =>
      page == WebsiteLegalPage.privacy ? 'Privacy policy'.tr : 'Terms of service'.tr;

  String get _contact => AppOffer.hasWhatsapp
      ? 'Reach us on WhatsApp on {0}, or through the contact details you received from us.'
          .trArgs([AppOffer.whatsappDisplay])
      : 'Reach us through the contact details you received from us.'.tr;

  List<(String, String)> get _sections => page == WebsiteLegalPage.privacy
      ? [
          (
            'What we collect'.tr,
            'When you request your version, we receive your name, company, phone number, email if you give it, the changes you ask for and the design you made. The website asks for nothing else.'
                .tr
          ),
          (
            'The demo'.tr,
            'What you type in the demo stays in your browser and starts again when you reopen the page. Your design is kept in this browser until you clear it.'
                .tr
          ),
          (
            'Why we use it'.tr,
            'Only to contact you, prepare your version and support you. We do not sell it or share it for advertising.'
                .tr
          ),
          (
            'Inside the app'.tr,
            'Each technician agrees once before the app shares their location. After that, their location and proof photos are recorded with each action on a visit, for their company only. A technician can withdraw this from any action screen, but actions that need a location will wait until they agree again.'
                .tr
          ),
          (
            'How long we keep it'.tr,
            'We keep your details while we serve you. If a period is not renewed, your app stays readable for {0} days so you can take your data, then it is deleted after a reminder.'
                .trArgs([AppOffer.readOnlyDays])
          ),
          (
            'Your rights'.tr,
            'You can ask us at any time to show, correct, export or delete your data.'
                .tr
          ),
          (
            'Contact us'.tr,
            _contact
          ),
        ]
      : [
          (
            'The service'.tr,
            'Visit Proof is an app for managing technicians and maintenance visits, delivered on a private web link with your design.'
                .tr
          ),
          (
            'Price and payment'.tr,
            '{0}, then {1} every {2} months for the whole company, up to {3} users and {4} GB of photos. Nothing is charged before you agree.'
                .trArgs([
              AppOffer.freeTitle,
              AppOffer.price(AppOffer.pricePerPeriod),
              AppOffer.periodMonths,
              AppOffer.maxUsers,
              AppOffer.photoStorageGb,
            ])
          ),
          (
            'Renewing and stopping'.tr,
            'There is no long contract. You renew every {0} months. If you stop, the app stays readable for {1} days so you can take your data, then it is deleted after a reminder.'
                .trArgs([AppOffer.periodMonths, AppOffer.readOnlyDays])
          ),
          (
            'Changes to your version'.tr,
            'Changes are free within a limit. Anything beyond it is a paid feature, and nothing is built before you agree on its price.'
                .tr
          ),
          (
            'Your data'.tr,
            'Your data stays yours, and we export it for you whenever you ask. You are responsible for telling your technicians that their location and photos are recorded.'
                .tr
          ),
          (
            'Availability'.tr,
            'We work to keep the service running and backed up, but we cannot promise it will never be interrupted.'
                .tr
          ),
          (
            'Updates to these terms'.tr,
            'We may update these terms, and we will tell you before any change that affects your price.'
                .tr
          ),
          (
            'Contact us'.tr,
            _contact
          ),
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: WebTheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: WebTheme.textPrimary),
        title: Text(_title,
            style: WebTheme.font(
                color: WebTheme.textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        child: WebsiteSection(
          vertical: 28,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: WebsiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final section in _sections) ...[
                      Text(section.$1,
                          style: WebTheme.font(
                              color: WebTheme.textPrimary,
                              fontSize: WebTheme.textTitle,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(section.$2,
                          style: WebTheme.font(
                              color: WebTheme.textSecondary,
                              fontSize: WebTheme.textBodyLarge,
                              height: 1.6)),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
