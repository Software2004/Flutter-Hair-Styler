import 'dart:io';
import 'package:file_selector/file_selector.dart';

/// Linux implementation of image picker using file_selector
class PlatformImagePicker {
  /// Pick an image from the file system
  static Future<XFile?> pickImageFromGallery() async {
    if (Platform.isLinux) {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'images',
        mimeTypes: ['image/png', 'image/jpeg', 'image/jpg', 'image/webp'],
      );
      
      final XFile? file = await FileSelector.platform.openFile(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );
      
      return file;
    }
    return null;
  }

  /// Camera functionality not available on Linux desktop
  static Future<XFile?> pickImageFromCamera() async {
    // Camera functionality not typically available on Linux desktop
    return null;
  }
}