import 'package:visit_proof/configs/app_language.dart';
import 'package:image_picker/image_picker.dart';

import '../../../configs/app_toasts.dart';

class GFunPhoto {
  GFunPhoto._();

  static final ImagePicker _picker = ImagePicker();

  /// Opens the camera and returns the temporary path of the photo, or null
  /// when the user cancels. Proof photos come from the camera only, never
  /// from the gallery, so they are taken on the spot.
  static Future<String?> takePhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      return photo?.path;
    } catch (_) {
      AppToasts.showMessage(
          'Could not open the camera. Check the camera permission.'.tr,
          isError: true);
      return null;
    }
  }
}
