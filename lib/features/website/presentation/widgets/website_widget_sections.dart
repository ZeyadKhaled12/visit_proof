import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_offer.dart';
import '../../../../core/utils/general_functions.dart/g_fun_launch.dart';
import '../screens/website_legal_scr.dart';
import 'website_widget_brand.dart';
import 'website_widget_parts.dart';
import '../website_theme.dart';

String _price(num amount) => AppOffer.price(amount);

// =============================================================================
// HERO
// =============================================================================

class WebsiteHero extends StatelessWidget {
  const WebsiteHero(
      {super.key, required this.onTryDemo, required this.onBrowse});
  final VoidCallback onTryDemo;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final wide = WebsiteLayout.isWide(context);
    final align = wide ? TextAlign.start : TextAlign.center;
    final text = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        WebsiteBadge(
            text: WebsiteBrand.tagline.tr.toUpperCase(),
            color: WebTheme.accent,
            background: WebTheme.primary),
        const SizedBox(height: 18),
        Text('Manage your technicians and maintenance from one app.'.tr,
            textAlign: align,
            style: WebTheme.font(
                color: WebTheme.textPrimary,
                fontSize: wide ? 46 : 32,
                fontWeight: FontWeight.w800,
                height: 1.15)),
        const SizedBox(height: 16),
        Text(
            'Schedule visits, dispatch your technicians and get proof of every job: live location, photos and a clear record, in an app with your colors and your logo.'
                .tr,
            textAlign: align,
            style: WebTheme.font(
                color: WebTheme.textSecondary,
                fontSize: WebTheme.textTitleLarge,
                height: 1.6)),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            WebsiteButton(
                text: 'Try {0} live'.trArgs(['Visit Proof'.tr]),
                icon: Icons.play_arrow_rounded,
                onPressed: onTryDemo),
            WebsiteButton(
                text: 'Browse the apps'.tr,
                icon: Icons.apps_rounded,
                outlined: true,
                onPressed: onBrowse),
          ],
        ),
        const SizedBox(height: 18),
        Text(
            'No sign-up and no card. Your design stays saved in this browser.'
                .tr,
            textAlign: align,
            style: WebTheme.font(
                color: WebTheme.textLightHint, fontSize: WebTheme.textSmall)),
      ],
    );

    return WebsiteSection(
      vertical: wide ? 72 : 40,
      child: wide
          ? Row(
              children: [
                Expanded(flex: 6, child: text),
                const SizedBox(width: 48),
                const Expanded(flex: 5, child: _HeroPreview()),
              ],
            )
          : Column(children: [
              text,
              const SizedBox(height: 36),
              const _HeroPreview(),
            ]),
    );
  }
}

/// A mock workspace: the live app with a visit it proved, and room for the
/// apps that are coming.
class _HeroPreview extends StatelessWidget {
  const _HeroPreview();

  @override
  Widget build(BuildContext context) {
    Widget step(IconData icon, String text, Color color) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: WebTheme.font(
                      color: WebTheme.textPrimary,
                      fontSize: WebTheme.textBodyLarge,
                      fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.check_rounded, color: WebTheme.statGreen, size: 18),
          ]),
        );

    return WebsiteCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const WizpoMark(size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text('My workspace'.tr,
                  style: WebTheme.font(
                      color: WebTheme.textPrimary,
                      fontSize: WebTheme.textTitle,
                      fontWeight: FontWeight.w800)),
            ),
            Icon(Icons.auto_awesome_rounded, color: WebTheme.accent, size: 20),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WebTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const _AppIcon(icon: Icons.verified_rounded, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Visit Proof'.tr,
                            style: WebTheme.font(
                                color: WebTheme.textPrimary,
                                fontSize: WebTheme.textSubtitle,
                                fontWeight: FontWeight.w800)),
                        Text('VIS-000124 · AC periodic maintenance'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WebTheme.font(
                                color: WebTheme.textSecondary,
                                fontSize: WebTheme.textSmall)),
                      ],
                    ),
                  ),
                  WebsiteBadge(text: 'Completed'.tr, color: WebTheme.statGreen),
                ]),
                const SizedBox(height: 8),
                step(Icons.location_on_rounded,
                    'Arrived · 18 m from the site'.tr, WebTheme.secondary),
                step(Icons.photo_camera_rounded,
                    '3 photos before and after'.tr, WebTheme.primary),
                step(Icons.payments_rounded,
                    'Payment collected · receipt photo'.tr, WebTheme.statGreen),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: _ComingSoonTile()),
            SizedBox(width: 12),
            Expanded(child: _ComingSoonTile()),
          ]),
        ],
      ),
    );
  }
}

/// A placeholder for an app that is not out yet.
class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebTheme.iconLightGrey, width: 1.4),
      ),
      child: Row(children: [
        const Icon(Icons.auto_awesome_rounded, color: WebTheme.accent, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Coming soon'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WebTheme.font(
                  color: WebTheme.textLightHint,
                  fontSize: WebTheme.textBody,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

/// An app's icon tile in the brand's purple and ink.
class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.icon, this.size = 48});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [WebTheme.secondary, WebTheme.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(size * .28),
      ),
      child: Icon(icon, color: WebTheme.parchment, size: size * .55),
    );
  }
}

// =============================================================================
// APPS
// =============================================================================

/// The catalog: the apps available today and the ones on the way.
class WebsiteApps extends StatelessWidget {
  const WebsiteApps(
      {super.key, required this.onTryDemo, required this.onDetails});
  final VoidCallback onTryDemo;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final visitProof = WebsiteCard(
      borderColor: WebTheme.primary,
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const _AppIcon(icon: Icons.verified_rounded, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Visit Proof'.tr,
                      style: WebTheme.font(
                          color: WebTheme.textPrimary,
                          fontSize: WebTheme.textHeadline,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('For managing technicians and maintenance'.tr,
                      style: WebTheme.font(
                          color: WebTheme.textSecondary,
                          fontSize: WebTheme.textBody)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            WebsiteBadge(text: 'Available now'.tr, color: WebTheme.statGreen),
            WebsiteBadge(
                text: AppOffer.freeTitle,
                color: WebTheme.accentText,
                background: WebTheme.accent.withValues(alpha: .18)),
          ]),
          const SizedBox(height: 16),
          Text(
              'Every technician visit is scheduled, proven with live location and photos, and closed with a clear record — in an app with your colors, your fonts and your logo.'
                  .tr,
              style: WebTheme.font(
                  color: WebTheme.textSecondary,
                  fontSize: WebTheme.textBodyLarge,
                  height: 1.6)),
          const SizedBox(height: 22),
          Wrap(spacing: 12, runSpacing: 12, children: [
            WebsiteButton(
                text: 'Try it and design your app'.tr,
                icon: Icons.palette_rounded,
                onPressed: onTryDemo),
            WebsiteButton(
                text: 'See the details'.tr,
                icon: Icons.arrow_downward_rounded,
                outlined: true,
                onPressed: onDetails),
          ]),
        ],
      ),
    );

    final comingSoon = Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [WebTheme.primary, WebTheme.secondary],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: WebTheme.accent, size: 36),
          const SizedBox(height: 16),
          WebsiteBadge(
              text: 'Coming soon'.tr,
              color: WebTheme.accent,
              background: WebTheme.accent.withValues(alpha: .16)),
          const SizedBox(height: 14),
          Text('More apps are on the way'.tr,
              style: WebTheme.font(
                  color: WebTheme.onPrimary,
                  fontSize: WebTheme.textHeadline,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
              'We are building more small apps for the everyday work of a business. Each one will join the same workspace, with the same simple pricing.'
                  .tr,
              style: WebTheme.font(
                  color: WebTheme.onPrimary.withValues(alpha: .85),
                  fontSize: WebTheme.textBodyLarge,
                  height: 1.6)),
        ],
      ),
    );

    return WebsiteSection(
      color: WebTheme.surface,
      child: Column(
        children: [
          WebsiteHeading(
            eyebrow: 'The apps'.tr,
            title: 'Pick the tools your team needs'.tr,
            subtitle:
                'Each app does one job well. Start with one today and add more as they arrive.'
                    .tr,
          ),
          const SizedBox(height: 36),
          WebsiteLayout.isWide(context)
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: visitProof),
                      const SizedBox(width: 18),
                      Expanded(flex: 2, child: comingSoon),
                    ],
                  ),
                )
              : Column(children: [
                  visitProof,
                  const SizedBox(height: 18),
                  comingSoon,
                ]),
        ],
      ),
    );
  }
}

// =============================================================================
// FEATURES
// =============================================================================

class WebsiteFeatures extends StatelessWidget {
  const WebsiteFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.event_available_rounded,
        'Plan and assign visits',
        'Create a visit in seconds, pick the technician and see the whole day on one dispatch board.'
      ),
      (
        Icons.my_location_rounded,
        'Proof of presence',
        'Starting work needs the technician\'s live location near the site. Every step is logged with where it happened.'
      ),
      (
        Icons.photo_library_rounded,
        'Before and after photos',
        'Camera photos taken on the spot, attached to the visit and shown to you in one place.'
      ),
      (
        Icons.history_rounded,
        'A full activity log',
        'Who did what and when: status changes, notes, payments and locations, all in one timeline.'
      ),
      (
        Icons.payments_rounded,
        'Payments collected on site',
        'The technician records the payment with a receipt photo; you confirm it when you have time.'
      ),
      (
        Icons.receipt_long_rounded,
        'Invoices for every visit',
        'Each visit has its invoice, issued automatically when the work is done.'
      ),
      (
        Icons.people_alt_rounded,
        'Clients, sites and equipment',
        'Your customers, their locations and their machines, ready for the next visit.'
      ),
      (
        Icons.translate_rounded,
        'Arabic and English',
        'A real right-to-left Arabic app; each user picks their language.'
      ),
    ];

    return WebsiteSection(
      child: Column(
        children: [
          WebsiteHeading(
            eyebrow: 'Visit Proof'.tr,
            title: 'Everything a small field team needs, nothing it does not'
                .tr,
            subtitle:
                'One app for the office and one for the technicians, connected live.'
                    .tr,
          ),
          const SizedBox(height: 36),
          WebsiteGrid(
            minWidth: 250,
            children: [
              for (final item in items)
                WebsiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: WebTheme.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(item.$1, color: WebTheme.primary, size: 24),
                      ),
                      const SizedBox(height: 14),
                      Text(item.$2.tr,
                          style: WebTheme.font(
                              color: WebTheme.textPrimary,
                              fontSize: WebTheme.textTitle,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(item.$3.tr,
                          style: WebTheme.font(
                              color: WebTheme.textSecondary,
                              fontSize: WebTheme.textBody,
                              height: 1.55)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HOW IT WORKS
// =============================================================================

class WebsiteSteps extends StatelessWidget {
  const WebsiteSteps({super.key, required this.onTryDemo});
  final VoidCallback onTryDemo;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.touch_app_rounded,
        'Try the full cycle',
        'Follow one visit from start to finish, as the admin and then as the technician.'
      ),
      (
        Icons.palette_rounded,
        'Design your version',
        'Pick any colors, fonts, text size, icon or logo, and the app name. You see every change instantly.'
      ),
      (
        Icons.send_rounded,
        'Send your request',
        'One tap sends us your design and your notes.'
      ),
      (
        Icons.link_rounded,
        'Get your private link',
        'We prepare your company\'s app and send you its link. Your team opens it and adds it to the home screen.'
      ),
    ];

    return WebsiteSection(
      color: WebTheme.surface,
      child: Column(
        children: [
          WebsiteHeading(
            eyebrow: 'How it works'.tr,
            title: 'From demo to your own app in four steps'.tr,
          ),
          const SizedBox(height: 36),
          WebsiteGrid(
            minWidth: 240,
            children: [
              for (var i = 0; i < steps.length; i++)
                WebsiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: WebTheme.primary,
                          child: Text('${i + 1}',
                              style: WebTheme.font(
                                  color: WebTheme.onPrimary,
                                  fontWeight: FontWeight.w800)),
                        ),
                        const Spacer(),
                        Icon(steps[i].$1, color: WebTheme.secondary, size: 26),
                      ]),
                      const SizedBox(height: 14),
                      Text(steps[i].$2.tr,
                          style: WebTheme.font(
                              color: WebTheme.textPrimary,
                              fontSize: WebTheme.textTitle,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(steps[i].$3.tr,
                          style: WebTheme.font(
                              color: WebTheme.textSecondary,
                              fontSize: WebTheme.textBody,
                              height: 1.55)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          WebsiteButton(
              text: 'Start with step 1'.tr,
              icon: Icons.play_arrow_rounded,
              onPressed: onTryDemo),
        ],
      ),
    );
  }
}

// =============================================================================
// PRICING
// =============================================================================

class WebsitePricing extends StatelessWidget {
  const WebsitePricing({super.key, required this.onRequest});
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final wide = WebsiteLayout.isWide(context);

    final plan = WebsiteCard(
      borderColor: WebTheme.primary,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '{0} · one plan for every small team'
                  .trArgs(['Visit Proof'.tr]),
              style: WebTheme.font(
                  color: WebTheme.secondary,
                  fontSize: WebTheme.textSubtitle,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Text(AppOffer.freeTitle,
              style: WebTheme.font(
                  color: WebTheme.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: 'then {0}'.trArgs([_price(AppOffer.pricePerPeriod)]),
                style: WebTheme.font(
                    color: WebTheme.textPrimary,
                    fontSize: WebTheme.textHeadline,
                    fontWeight: FontWeight.w800)),
            TextSpan(
                text: ' ${'every {0} months'.trArgs([AppOffer.periodMonths])}',
                style: WebTheme.font(
                    color: WebTheme.textSecondary,
                    fontSize: WebTheme.textTitle)),
          ])),
          const SizedBox(height: 4),
          Text(
              'For the whole company, not per user.'.tr,
              style: WebTheme.font(
                  color: WebTheme.textSecondary, fontSize: WebTheme.textBody)),
          const SizedBox(height: 18),
          Divider(color: WebTheme.iconLightGrey.withValues(alpha: .5)),
          const SizedBox(height: 10),
          WebsiteCheckLine(
              text: 'Up to {0} users: admins and technicians'
                  .trArgs([AppOffer.maxUsers])),
          WebsiteCheckLine(text: 'Unlimited visits, clients and sites'.tr),
          WebsiteCheckLine(
              text: '{0} GB for photos (compressed automatically)'
                  .trArgs([AppOffer.photoStorageGb])),
          WebsiteCheckLine(
              text: 'Your colors, fonts, icon or logo and your app name'.tr),
          WebsiteCheckLine(text: 'Hosting, daily backups and updates'.tr),
          WebsiteCheckLine(text: 'Support on WhatsApp and email'.tr),
          WebsiteCheckLine(text: 'Arabic and English'.tr),
          WebsiteCheckLine(
              text: 'Your data is yours: we export it for you whenever you ask'
                  .tr),
          const SizedBox(height: 22),
          WebsiteButton(
              text: 'Request my version'.tr,
              icon: Icons.send_rounded,
              expand: true,
              onPressed: onRequest),
          const SizedBox(height: 10),
          Text('Nothing to pay today.'.tr,
              style: WebTheme.font(
                  color: WebTheme.textLightHint, fontSize: WebTheme.textSmall)),
        ],
      ),
    );

    final billing = WebsiteCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exactly what you pay'.tr,
              style: WebTheme.font(
                  color: WebTheme.textPrimary,
                  fontSize: WebTheme.textTitleLarge,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _PriceRow(
              label: AppOffer.freeSpan,
              value: 'Free'.tr),
          _PriceRow(
              label: 'Every {0} months after that'
                  .trArgs([AppOffer.periodMonths]),
              value: _price(AppOffer.pricePerPeriod)),
          _PriceRow(label: 'Setup, colors and logo'.tr, value: 'Free'.tr),
          _PriceRow(label: 'Extra fees per user'.tr, value: 'None'.tr),
          const SizedBox(height: 16),
          Text('Changes to your version'.tr,
              style: WebTheme.font(
                  color: WebTheme.textPrimary,
                  fontSize: WebTheme.textTitle,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
              'Want something changed in your version? Write it in your request. Changes are free within a limit. If we find that what you ask for goes beyond it, it becomes a paid feature, and we agree on its price with you before any work starts.'
                  .tr,
              style: WebTheme.font(
                  color: WebTheme.textSecondary,
                  fontSize: WebTheme.textBody,
                  height: 1.55)),
          const SizedBox(height: 10),
          _PriceRow(
              label: 'Changes to your version'.tr,
              value: 'Free within a limit'.tr),
          _PriceRow(label: 'Larger features'.tr, value: 'Paid, agreed first'.tr),
          const SizedBox(height: 14),
          Text(
              'If a period is not renewed, your app stays readable for {0} days so you can take your data, then it is deleted after a reminder.'
                  .trArgs([AppOffer.readOnlyDays]),
              style: WebTheme.font(
                  color: WebTheme.textLightHint,
                  fontSize: WebTheme.textSmall,
                  height: 1.5)),
        ],
      ),
    );

    return WebsiteSection(
      child: Column(
        children: [
          WebsiteHeading(
            eyebrow: 'Pricing'.tr,
            title: 'Simple, small and clear'.tr,
            subtitle:
                'We are built for companies at the start of their journey. When you grow past {0} users, you have outgrown us — and that is the goal.'
                    .trArgs([AppOffer.maxUsers]),
          ),
          const SizedBox(height: 36),
          wide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: plan),
                      const SizedBox(width: 18),
                      Expanded(child: billing),
                    ],
                  ),
                )
              : Column(children: [plan, const SizedBox(height: 18), billing]),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label,
                style: WebTheme.font(
                    color: WebTheme.textSecondary,
                    fontSize: WebTheme.textBodyLarge)),
          ),
          const SizedBox(width: 12),
          Text(value,
              style: WebTheme.font(
                  color: WebTheme.textPrimary,
                  fontSize: WebTheme.textBodyLarge,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// =============================================================================
// DELIVERY (PWA)
// =============================================================================

class WebsiteDelivery extends StatelessWidget {
  const WebsiteDelivery({super.key});

  @override
  Widget build(BuildContext context) {
    final points = [
      (
        Icons.link_rounded,
        'A private link for your company',
        'Your app lives on its own web link. Only your team signs in to it.'
      ),
      (
        Icons.add_to_home_screen_rounded,
        'Installs like an app',
        'Open the link on any phone and choose "Add to Home Screen". It gets your icon and opens full screen.'
      ),
      (
        Icons.phone_iphone_rounded,
        'iPhone, Android and computers',
        'No App Store or Google Play needed. The office can use it on a laptop.'
      ),
      (
        Icons.system_update_alt_rounded,
        'Always up to date',
        'Updates arrive by themselves. Nobody has to download anything.'
      ),
    ];

    return WebsiteSection(
      color: WebTheme.surface,
      child: Column(
        children: [
          WebsiteHeading(
            eyebrow: 'How you receive it'.tr,
            title: 'Your app arrives as a link, not a download'.tr,
            subtitle:
                'We deliver it as a PWA (progressive web app): a web app that installs on the phone like a normal app.'
                    .tr,
          ),
          const SizedBox(height: 36),
          WebsiteGrid(
            minWidth: 240,
            children: [
              for (final point in points)
                WebsiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(point.$1, color: WebTheme.secondary, size: 28),
                      const SizedBox(height: 12),
                      Text(point.$2.tr,
                          style: WebTheme.font(
                              color: WebTheme.textPrimary,
                              fontSize: WebTheme.textTitle,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(point.$3.tr,
                          style: WebTheme.font(
                              color: WebTheme.textSecondary,
                              fontSize: WebTheme.textBody,
                              height: 1.55)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FAQ
// =============================================================================

class WebsiteFaq extends StatelessWidget {
  const WebsiteFaq({super.key});

  @override
  Widget build(BuildContext context) {
    final questions = [
      (
        'What is {0}?'.trArgs([WebsiteBrand.name]),
        '{0} is a marketplace of ready-to-use business apps for small teams. You choose the apps you need, try each one live, and we set it up with your colors and your logo.'
            .trArgs([WebsiteBrand.name])
      ),
      (
        'Which apps can I get today?',
        '{0} is available now. More apps are coming soon and will join the same workspace.'
            .trArgs(['Visit Proof'.tr])
      ),
      (
        'Do I pay anything now?',
        'No. {0}. We only ask for payment after that.'
            .trArgs([AppOffer.freeTitle])
      ),
      (
        'What do I pay after the free period?',
        '{0} every {1} months for your whole company, up to {2} users. There is no fee per user and no setup fee.'
            .trArgs([
          _price(AppOffer.pricePerPeriod),
          AppOffer.periodMonths,
          AppOffer.maxUsers
        ])
      ),
      (
        'Is there a contract?',
        'No. You renew every {0} months. If you stop, you keep reading access for {1} days to take your data.'
            .trArgs([AppOffer.periodMonths, AppOffer.readOnlyDays])
      ),
      (
        'What if I need more than {0} users?'.trArgs([AppOffer.maxUsers]),
        'That means your company has grown — congratulations. We help you export your data so you can move to a bigger system.'
            .tr
      ),
      (
        'Can I change the colors or logo later?',
        'Yes, at no cost. Colors, fonts, text size, icon, logo and app name are part of the plan.'
            .tr
      ),
      (
        'What counts as a custom change?',
        'Anything the app does not do today: a new field, a new report, a new screen or a connection to another system. Small changes are free within a limit; anything beyond it is a paid feature, and nothing is built before you agree on its price.'
            .tr
      ),
      (
        'How do my technicians get the app?',
        'You send them your app\'s link. They open it on their phone, add it to the home screen and sign in with the email and password you give them.'
            .tr
      ),
      (
        'Is my data private?',
        'Each company has its own separate space. Other companies cannot see your clients, visits or photos.'
            .tr
      ),
      (
        'Is the demo saving what I type?',
        'The demo data starts again every time you open the page. Only your design is kept, in this browser, until you clear it. Nothing is sent until you press send on your request.'
            .tr
      ),
    ];

    return WebsiteSection(
      child: Column(
        children: [
          WebsiteHeading(
              eyebrow: 'Questions'.tr, title: 'Frequently asked questions'.tr),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              children: [
                for (final q in questions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WebsiteCard(
                      padding: EdgeInsets.zero,
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          childrenPadding:
                              const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 18),
                          iconColor: WebTheme.primary,
                          collapsedIconColor: WebTheme.textSecondary,
                          title: Text(q.$1.tr,
                              style: WebTheme.font(
                                  color: WebTheme.textPrimary,
                                  fontSize: WebTheme.textSubtitle,
                                  fontWeight: FontWeight.w700)),
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(q.$2,
                                  style: WebTheme.font(
                                      color: WebTheme.textSecondary,
                                      fontSize: WebTheme.textBodyLarge,
                                      height: 1.6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CLOSING CALL TO ACTION AND FOOTER
// =============================================================================

class WebsiteClosing extends StatelessWidget {
  const WebsiteClosing({super.key, required this.onTryDemo});
  final VoidCallback onTryDemo;

  @override
  Widget build(BuildContext context) {
    return WebsiteSection(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [WebTheme.primary, WebTheme.secondary],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome_rounded,
                color: WebTheme.accent, size: 34),
            const SizedBox(height: 14),
            Text('Every company passes through its first steps.'.tr,
                textAlign: TextAlign.center,
                style: WebTheme.font(
                    color: WebTheme.onPrimary,
                    fontSize: WebsiteLayout.isWide(context) ? 30 : 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('Let us organize yours while you grow.'.tr,
                textAlign: TextAlign.center,
                style: WebTheme.font(
                    color: WebTheme.onPrimary.withValues(alpha: .9),
                    fontSize: WebTheme.textTitle)),
            const SizedBox(height: 24),
            WebsiteButton(
              text: 'Design my app now'.tr,
              icon: Icons.palette_rounded,
              color: WebTheme.onPrimary,
              outlined: true,
              onPressed: onTryDemo,
            ),
          ],
        ),
      ),
    );
  }
}

class WebsiteFooter extends StatelessWidget {
  const WebsiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return WebsiteSection(
      vertical: 28,
      color: WebTheme.surface,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WebsiteLogo(),
              const SizedBox(height: 8),
              Text(WebsiteBrand.tagline.tr,
                  style: WebTheme.font(
                      color: WebTheme.secondary,
                      fontSize: WebTheme.textSmall,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(spacing: 4, children: [
                if (AppOffer.hasWhatsapp)
                  _FooterLink('WhatsApp: {0}'.trArgs([AppOffer.whatsappDisplay]),
                      () => GFunLaunch.openWhatsApp(AppOffer.whatsappNumber)),
                _FooterLink(
                    'Privacy policy'.tr,
                    () => WebsiteLegalScr.open(
                        context, WebsiteLegalPage.privacy)),
                _FooterLink('Terms of service'.tr,
                    () => WebsiteLegalScr.open(context, WebsiteLegalPage.terms)),
              ]),
              Text('Prices in Saudi riyals. The demo runs only in your browser.'.tr,
                  style: WebTheme.font(
                      color: WebTheme.textLightHint,
                      fontSize: WebTheme.textSmall)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink(this.text, this.onTap);
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(text,
          style: WebTheme.font(
              color: WebTheme.secondary,
              fontSize: WebTheme.textSmall,
              fontWeight: FontWeight.w700)),
    );
  }
}
