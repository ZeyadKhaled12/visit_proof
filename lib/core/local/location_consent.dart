import '../session/app_session.dart';
import 'local_pref.dart';

/// Each technician agrees once on this device to share their location with
/// the admin, and can take that back from any action screen.
class LocationConsent {
  LocationConsent._();

  static const String key = 'location_consent';

  static List<String> get _agreed =>
      LocalPref.sharedPreferences.getStringList(key) ?? const [];

  static bool get given => _agreed.contains(AppSession.technicianId);

  static Future<void> give() async {
    final id = AppSession.technicianId;
    if (id == null || given) return;
    await LocalPref.sharedPreferences.setStringList(key, [..._agreed, id]);
  }

  static Future<void> withdraw() => LocalPref.sharedPreferences.setStringList(
      key, _agreed.where((e) => e != AppSession.technicianId).toList());
}
