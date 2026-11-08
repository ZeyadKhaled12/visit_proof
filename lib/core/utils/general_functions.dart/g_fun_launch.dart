import 'package:visit_proof/configs/app_language.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../configs/app_toasts.dart';

class GFunLaunch {
  static Future<void> navigateToGoogleMaps({
    required double latitude,
    required double longitude,
  }) async {
    final Uri googleMapsUrl = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination': '$latitude,$longitude',
        // 'travelmode': 'driving',
        // 'dir_action': 'navigate',
      },
    );

    try {
      final bool launched = await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open Google Maps'.tr);
      }
    } catch (e) {
      throw Exception('Navigation failed: {0}'.trArgs([e]));
    }
  }

  static Future<void> openWhatsApp(String phoneNumber, {String? message}) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final Uri whatsappUri = Uri.https('wa.me', '/$cleanNumber',
        message == null ? null : {'text': message});
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        AppToasts.showMessage('Could not launch WhatsApp for {0}'.trArgs([cleanNumber]),
            isError: true);
      }
    } catch (e) {
      AppToasts.showMessage('Error launching WhatsApp: {0}'.trArgs([e]), isError: true);
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      AppToasts.showMessage('Could not launch {0}'.trArgs([launchUri]), isError: true);
    }
  }
}
