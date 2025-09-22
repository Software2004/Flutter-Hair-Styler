import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';

// Conditional imports based on platform (REMOVED as logic is self-contained below)
// import 'image_picker_android.dart' if (dart.library.io) 'image_picker_android.dart';
// import 'image_picker_linux.dart' if (dart.library.io) 'image_picker_linux.dart';

/// Cross-platform image picker that uses the appropriate implementation
/// based on the current platform (Android or Linux)
class PlatformImagePicker {
  /// Pick an image from the gallery
  /// Uses image_picker on Android and file_selector on Linux
  static Future<XFile?> pickImageFromGallery() async {
    if (Platform.isAndroid) {
      return await _pickImageFromGalleryAndroid();
    } else if (Platform.isLinux) {
      return await _pickImageFromGalleryLinux();
    }
    return null;
  }

  /// Pick an image from the camera
  /// Uses image_picker on Android, not available on Linux
  static Future<XFile?> pickImageFromCamera() async {
    if (Platform.isAndroid) {
      return await _pickImageFromCameraAndroid();
    } else if (Platform.isLinux) {
      // Camera functionality not typically available on Linux desktop
      return null;
    }
    return null;
  }

  // Android implementations
  static Future<XFile?> _pickImageFromGalleryAndroid() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
  }

  static Future<XFile?> _pickImageFromCameraAndroid() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
  }

  // Linux implementations
  static Future<XFile?> _pickImageFromGalleryLinux() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      mimeTypes: ['image/png', 'image/jpeg', 'image/jpg', 'image/webp'],
    );

    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );

    return file;
  }
}