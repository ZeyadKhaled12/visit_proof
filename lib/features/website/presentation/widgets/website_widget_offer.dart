import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_offer.dart';
import '../website_theme.dart';
import 'website_widget_parts.dart';

/// The offer in one card: a free month, then the price of a coffee for the
/// whole company.
class WebsiteOfferCard extends StatelessWidget {
  const WebsiteOfferCard({
    super.key,
    required this.onRequest,
    this.finished = false,
  });

  final VoidCallback onRequest;

  /// Shown at the end of the scenario, with a word of congratulations.
  final bool finished;

  @override
  Widget build(BuildContext context) {
    final points = [
      'No card and nothing to pay today'.tr,
      'Up to {0} users, with no fee per user'.trArgs([AppOffer.maxUsers]),
      'Unlimited visits, clients and sites'.tr,
      'Setup, your colors and your logo are free'.tr,
      'Changes to your version are free within a limit'.tr,
      'Not convinced after the free month? Leave and pay nothing'.tr,
    ];

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [WebTheme.primary, WebTheme.secondary],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (finished) ...[
            Text('You have seen it work. Now make it yours.'.tr,
                style: WebTheme.font(
                    color: WebTheme.parchment,
                    fontSize: WebTheme.textTitle,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
          ],
          WebsiteBadge(
              text: 'For managing technicians and maintenance'.tr,
              color: WebTheme.accent,
              background: WebTheme.accent.withValues(alpha: .16)),
          const SizedBox(height: 16),
          Text(AppOffer.freeTitle,
              style: WebTheme.font(
                  color: WebTheme.accent,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.2)),
          const SizedBox(height: 14),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: AppOffer.monthlyEquivalent,
                style: WebTheme.font(
                    color: WebTheme.onPrimary,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    height: 1.1)),
            TextSpan(
                text: ' ${'a month for the whole company'.tr}',
                style: WebTheme.font(
                    color: WebTheme.parchment,
                    fontSize: WebTheme.textTitle,
                    fontWeight: FontWeight.w600)),
          ])),
          const SizedBox(height: 6),
          Text(
              'You pay {0} every {1} months, after the free period.'.trArgs(
                  [AppOffer.usd(AppOffer.pricePerPeriod), AppOffer.periodMonths]),
              style: WebTheme.font(
                  color: WebTheme.parchment.withValues(alpha: .85),
                  fontSize: WebTheme.textBodyLarge)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            WebsiteBadge(
                text: 'Less than a cup of coffee a month'.tr,
                color: WebTheme.parchment,
                background: WebTheme.parchment.withValues(alpha: .14)),
            WebsiteBadge(
                text: 'Only {0} per user with a full team'
                    .trArgs([AppOffer.monthlyPerUser]),
                color: WebTheme.parchment,
                background: WebTheme.parchment.withValues(alpha: .14)),
          ]),
          const SizedBox(height: 18),
          for (final point in points)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: WebTheme.accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(point,
                        style: WebTheme.font(
                            color: WebTheme.onPrimary,
                            fontSize: WebTheme.textBodyLarge,
                            height: 1.45)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          WebsiteButton(
            text: 'Request your version now'.tr,
            icon: Icons.send_rounded,
            color: WebTheme.accent,
            foreground: WebTheme.primary,
            expand: true,
            onPressed: onRequest,
          ),
        ],
      ),
    );
  }

  /// Opens the offer over the page.
  static Future<void> show(BuildContext context,
      {required VoidCallback onRequest, bool finished = false}) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                WebsiteOfferCard(
                  finished: finished,
                  onRequest: () {
                    Navigator.pop(dialogContext);
                    onRequest();
                  },
                ),
                PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: IconButton(
                    tooltip: 'Close'.tr,
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close_rounded,
                        color: WebTheme.parchment),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The offer as a section of the landing page.
class WebsiteOfferSection extends StatelessWidget {
  const WebsiteOfferSection({super.key, required this.onRequest});
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return WebsiteSection(
      vertical: 12,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: WebsiteOfferCard(onRequest: onRequest),
        ),
      ),
    );
  }
}
