import 'package:flutter/foundation.dart';

import '../utils/general_models/g_model_geo_point.dart';
import '../../features/visits/data/models/visit_detail_models/visit_detail_model.dart';

/// The website demo and test builds: visitors and testers are not at any
/// real site, so the technician's location can be simulated.
class DemoMode {
  DemoMode._();

  /// A customer's own app: built with --dart-define=CUSTOMER_APP=true.
  /// It keeps its data and opens straight into the app, without the website.
  static const bool customerApp = bool.fromEnvironment('CUSTOMER_APP');

  /// The app is the website demo (a browser build that is not a
  /// customer's app).
  static bool get isOn => kIsWeb && !customerApp;

  /// Every start loads the test company again (all builds except a
  /// customer's).
  static bool get testData => !customerApp;

  /// "I am at the site": technician actions use the visit's site location
  /// instead of the device GPS. On by default in the demo.
  static final ValueNotifier<bool> simulateOnSite = ValueNotifier(true);

  static bool get simulating => testData && simulateOnSite.value;

  /// Central Riyadh, used for sites without coordinates.
  static const double _fallbackLatitude = 24.7136;
  static const double _fallbackLongitude = 46.6753;

  /// A fresh location a few meters from the visit's site.
  static GModelGeoPoint locationFor(VisitDetailModel visit) {
    final site = visit.site;
    return GModelGeoPoint(
      latitude: (site?.latitude ?? _fallbackLatitude) + 0.00012,
      longitude: (site?.longitude ?? _fallbackLongitude) + 0.00009,
      accuracy: 8,
      capturedAt: DateTime.now(),
    );
  }
}
