import 'dart:io';
import 'package:file_selector/file_selector.dart';

class PlatformImagePicker {
  static Future<XFile?> pickImageFromGallery() async {
    if (Platform.isLinux) {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'images',
        mimeTypes: ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'],
      );
      
      final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
      
      if (files.isNotEmpty) {
        return files.first;
      }
    }
    return null;
  }
}