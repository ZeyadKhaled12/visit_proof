// =============================================================================
// APP OFFER — the price and the limits of the one plan.
// =============================================================================
//
// The website reads every price and limit from here, so changing a number
// here changes the pricing section, the FAQ and the request page.
// Prices are in Saudi riyals. See docs/VisitProof_Pricing_Plan_AR.md.
// =============================================================================

import 'app_language.dart';

class AppOffer {
  AppOffer._();

  // --- The one plan ----------------------------------------------------------

  static const int freeMonths = 1;
  static const int periodMonths = 6;

  /// Price in riyals of every [periodMonths] after the free months: the one
  /// price the website shows.
  static const num pricePerPeriod = 56;

  static const int maxUsers = 10;
  static const int photoStorageGb = 5;

  /// After an unpaid period ends, the app stays readable for this long.
  static const int readOnlyDays = 30;

  // Changes made only for one customer have no set price: each request is
  // discussed with the customer and priced on its own.

  // --- How to reach us ----------------------------------------------------------

  /// International format, digits only (e.g. 9665XXXXXXXX). While empty, the
  /// website shows no WhatsApp buttons.
  static const String whatsappNumber = '201109300241';

  static bool get hasWhatsapp => whatsappNumber.isNotEmpty;

  /// The number as shown. The mark keeps the "+" in front of it in Arabic text.
  static String get whatsappDisplay => '\u200E+$whatsappNumber';

  /// 56 → "56 SAR" ("56 ر.س" in Arabic).
  static String price(num amount) => '{0} SAR'.trArgs([amount]);

  /// "First month free".
  static String get freeTitle => freeMonths == 1
      ? 'First month free'.tr
      : 'First {0} months free'.trArgs([freeMonths]);

  /// The free period, as a line in a price list.
  static String get freeSpan => freeMonths == 1
      ? 'The first month'.tr
      : 'Months 1 to {0}'.trArgs([freeMonths]);

  /// The offer in one paragraph, as shown on the request page.
  static String get summary =>
      '{0}, then {1} every {2} months for the whole company. Up to {3} users and {4} GB of photos. Delivered as a PWA on a private link. Changes to your version are free within a limit; anything beyond it is a paid feature we agree on first.'
          .trArgs([
        freeTitle,
        price(pricePerPeriod),
        periodMonths,
        maxUsers,
        photoStorageGb,
      ]);
}
