// =============================================================================
// APP OFFER — the price and the limits of the one plan.
// =============================================================================
//
// The website reads every price and limit from here, so changing a number
// here changes the pricing section, the FAQ and the request page.
// Prices are in US dollars. See docs/VisitProof_Pricing_Plan_AR.md.
// =============================================================================

import 'app_language.dart';

class AppOffer {
  AppOffer._();

  // --- The one plan ----------------------------------------------------------

  static const int freeMonths = 6;
  static const int periodMonths = 6;

  /// Price of every [periodMonths] after the free months.
  static const num pricePerPeriod = 15;

  static const int maxUsers = 10;
  static const int photoStorageGb = 5;

  /// After an unpaid period ends, the app stays readable for this long.
  static const int readOnlyDays = 30;

  // Changes made only for one customer have no set price: each request is
  // discussed with the customer and priced on its own.

  /// $15 → "$15", $2.5 → "$2.50".
  static String usd(num amount) =>
      '\$${amount == amount.roundToDouble() ? amount.toInt() : amount.toStringAsFixed(2)}';

  static String get monthlyEquivalent =>
      usd((pricePerPeriod / periodMonths * 100).round() / 100);

  /// The offer in one paragraph, as shown on the request page.
  static String get summary =>
      'First {0} months free, then {1} every {2} months for the whole company. Up to {3} users and {4} GB of photos. Delivered as a PWA on a private link. Special requests are priced separately, after we discuss them with you.'
          .trArgs([
        freeMonths,
        usd(pricePerPeriod),
        periodMonths,
        maxUsers,
        photoStorageGb,
      ]);
}
