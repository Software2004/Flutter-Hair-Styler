
import 'package:flutter/foundation.dart';

@immutable
class SavedStyle {
  final String id;
  final String imagePath;
  final String name;
  final DateTime dateSaved;

  const SavedStyle({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.dateSaved,
  });

  // Optional: For debugging or if you need to compare instances
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedStyle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          imagePath == other.imagePath &&
          name == other.name &&
          dateSaved == other.dateSaved;

  @override
  int get hashCode =>
      id.hashCode ^
      imagePath.hashCode ^
      name.hashCode ^
      dateSaved.hashCode;

  @override
  String toString() {
    return 'SavedStyle{id: $id, name: $name, imagePath: $imagePath, dateSaved: $dateSaved}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'name': name,
        'dateSaved': dateSaved.toIso8601String(),
      };

  factory SavedStyle.fromJson(Map<String, dynamic> json) => SavedStyle(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        name: json['name'] as String,
        dateSaved: DateTime.parse(json['dateSaved'] as String),
      );
}
