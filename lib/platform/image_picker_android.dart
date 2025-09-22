import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Android implementation of image picker
class PlatformImagePicker {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from the gallery
  static Future<XFile?> pickImageFromGallery() async {
    if (Platform.isAndroid) {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
    }
    return null;
  }

  /// Pick an image from the camera
  static Future<XFile?> pickImageFromCamera() async {
    if (Platform.isAndroid) {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
    }
    return null;
  }
}