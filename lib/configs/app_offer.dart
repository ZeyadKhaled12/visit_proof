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

  static const int freeMonths = 1;
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

  /// What one user costs a month when the company uses all its seats.
  static String get monthlyPerUser =>
      usd((pricePerPeriod / periodMonths / maxUsers * 100).round() / 100);

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
      '{0}, then {1} every {2} months for the whole company ({3} a month). Up to {4} users and {5} GB of photos. Delivered as a PWA on a private link. Changes to your version are free within a limit; anything beyond it is a paid feature we agree on first.'
          .trArgs([
        freeTitle,
        usd(pricePerPeriod),
        periodMonths,
        monthlyEquivalent,
        maxUsers,
        photoStorageGb,
      ]);
}
