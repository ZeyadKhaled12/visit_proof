/// How long the local data sources pretend a server takes to answer.
///
/// The data lives on the device, so this only needs to be long enough for a
/// loading state to show briefly; raise it to test slow-network screens.
class AppLatency {
  AppLatency._();

  static const Duration local = Duration(milliseconds: 60);
}
