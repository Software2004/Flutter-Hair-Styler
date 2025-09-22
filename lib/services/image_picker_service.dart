import 'package:image_picker/image_picker.dart';

import '../platform/image_picker.dart';

/// Simple facade used by UI to pick images without caring about platform.
class ImagePickerService {
  /// Pick an image from the gallery (Android uses image_picker, Linux uses file_selector).
  static Future<XFile?> pickFromGallery() async {
    return await PlatformImagePicker.pickImageFromGallery();
  }

  /// Pick an image from the camera (only available on Android; Linux returns null).
  static Future<XFile?> pickFromCamera() async {
    return await PlatformImagePicker.pickImageFromCamera();
  }
}

