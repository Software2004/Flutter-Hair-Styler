import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserPathsService {
  // Initialize FirebaseDatabase instance with the specified URL
  static final FirebaseDatabase _db = _initDB();

  static FirebaseDatabase _initDB() {
    final instance = FirebaseDatabase.instance;
    instance.databaseURL = "https://flutter-hair-styler-default-rtdb.asia-southeast1.firebasedatabase.app";
    return instance;
  }

  // Firebase Realtime Database keys must not contain '.', '#', '$', '[', or ']'
  static String _sanitizeKey(String input) {
    // Replace forbidden characters and null character with '_'
    final forbidden = ['.', '#', '000', '[', ']'];
    var sanitized = input;
    for (final ch in forbidden) {
      sanitized = sanitized.replaceAll(ch, '_');
    }
    // Also trim whitespace and collapse any repeated underscores
    sanitized = sanitized.trim().replaceAll(RegExp(r'_+'), '_');
    // Avoid leading/trailing underscores only if non-empty
    if (sanitized.isNotEmpty) {
      sanitized = sanitized.replaceFirst(RegExp(r'^_+'), '');
      sanitized = sanitized.replaceFirst(RegExp(r'_+$ '), ''); // Corrected trailing underscore removal regex
    }
    // Ensure non-empty fallback
    return sanitized.isEmpty ? 'unknown' : sanitized;
  }

  static DatabaseReference userRef(String uid) =>
      _db.ref('users/$uid');

  static DatabaseReference creditsRemainingRef(String uid) =>
      _db.ref('users/$uid/credits/remaining');

  // Corrected to return a proper DatabaseReference and use the _db instance
  static DatabaseReference creditsLastUpdatedRef(String uid) => 
      _db.ref('users/$uid/credits/lastUpdated');

  static DatabaseReference subscriptionRef(String uid) =>
      _db.ref('users/$uid/subscription');

  static Future<String?> getAndroidDeviceId() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.id; // Android hardware ID (SSAID on newer devices)
    } catch (_) {
      return null;
    }
  }

  static Future<String> effectiveUserKey() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return user.uid;
    final device = await getAndroidDeviceId();
    final raw = device ?? 'unknown';
    final safe = _sanitizeKey(raw);
    return 'device_$safe';
  }
}
