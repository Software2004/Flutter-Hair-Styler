import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PlatformImagePicker {
  static Future<XFile?> pickImageFromGallery() async {
    if (Platform.isAndroid) {
      final ImagePicker picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.gallery);
    }
    return null;
  }
}