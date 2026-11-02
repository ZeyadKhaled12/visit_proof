import 'package:flutter/foundation.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'package:geolocator/geolocator.dart';

import '../general_models/g_model_geo_point.dart';

/// Why the device location could not be read, so the UI can offer the right fix.
enum GFunLocationIssue { serviceOff, denied, deniedForever, mocked, failed }

class GFunLocationException implements Exception {
  final GFunLocationIssue issue;
  final String message;
  const GFunLocationException(this.issue, this.message);

  @override
  String toString() => message;
}

class GFunLocation {
  GFunLocation._();

  /// The device's live GPS position. Asks for permission when needed and
  /// throws [GFunLocationException] when no trustworthy fix is available.
  static Future<GModelGeoPoint> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw GFunLocationException(GFunLocationIssue.serviceOff,
          'Turn on location services to continue.'.tr);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw GFunLocationException(GFunLocationIssue.deniedForever,
          'Location access is blocked. Allow it from the app settings.'.tr);
    }
    if (permission == LocationPermission.denied) {
      throw GFunLocationException(GFunLocationIssue.denied,
          'Location access is required to record this action.'.tr);
    }

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
    } catch (_) {
      throw GFunLocationException(GFunLocationIssue.failed,
          'Could not get your GPS location. Move to an open area and try again.'.tr);
    }

    // A fake GPS app could place the technician anywhere.
    if (position.isMocked) {
      throw GFunLocationException(GFunLocationIssue.mocked,
          'A mock location app is active. Turn it off to continue.'.tr);
    }

    return GModelGeoPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      capturedAt: DateTime.now(),
    );
  }

  /// Opens the system page where the user can fix [issue].
  static Future<void> openSettings(GFunLocationIssue issue) async {
    // Browsers have no settings page to open; the site permission is used.
    if (kIsWeb) return;
    if (issue == GFunLocationIssue.serviceOff) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  /// Straight-line distance in meters.
  static double distance(GModelGeoPoint from, double toLatitude,
          double toLongitude) =>
      Geolocator.distanceBetween(
          from.latitude!, from.longitude!, toLatitude, toLongitude);

  /// "85 m" or "2.4 km".
  static String distanceText(num meters) => meters < 1000
      ? '{0} m'.trArgs([meters.round()])
      : '{0} km'.trArgs([(meters / 1000).toStringAsFixed(1)]);
}
