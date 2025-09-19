import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Conditional imports based on platform
import 'image_picker_android.dart' if (dart.library.io) 'image_picker_linux.dart' as platform_picker;

class PlatformImagePicker {
  static Future<XFile?> pickImageFromGallery() async {
    if (Platform.isAndroid) {
      final ImagePicker picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.gallery);
    } else if (Platform.isLinux) {
      return await platform_picker.PlatformImagePicker.pickImageFromGallery();
    }
    return null;
  }
}