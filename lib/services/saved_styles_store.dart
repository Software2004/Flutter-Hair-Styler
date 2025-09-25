import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import '../models/saved_style.dart';

class SavedStylesStore {
  static const String _fileName = 'saved_styles.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<SavedStyle>> load() async {
    final f = await _file();
    if (!await f.exists()) return [];
    final text = await f.readAsString();
    if (text.trim().isEmpty) return [];
    final List<dynamic> list = jsonDecode(text) as List<dynamic>;
    return list.map((e) => SavedStyle.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(List<SavedStyle> items) async {
    final f = await _file();
    final text = jsonEncode(items.map((e) => e.toJson()).toList());
    await f.writeAsString(text, flush: true);
  }

  Future<void> append(SavedStyle item) async {
    final items = await load();
    items.insert(0, item);
    await saveAll(items);
  }

  Future<void> deleteById(String id) async {
    final items = await load();
    items.removeWhere((e) => e.id == id);
    await saveAll(items);
  }

  Stream<List<SavedStyle>> watch() async* {
    final f = await _file();
    // Emit initial state
    yield await load();
    final Directory dir = f.parent;
    await for (final event in dir.watch(
      events: FileSystemEvent.create | FileSystemEvent.modify | FileSystemEvent.delete,
      recursive: false,
    )) {
      if (event.path.endsWith(_fileName)) {
        yield await load();
      }
    }
  }
}


