import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static String? _directory;

  static get directory async => _directory ??= await _getDirectory();

  static Future<String> _getDirectory() async {
    Directory dir = await getLibraryDirectory();
    return dir.path;
  }

  static Future<File> _localFile(String id) async {
    final String dir = await directory;
    return File('$dir/$id');
  }

  static Future<void> store(String id, String content) async {
    final File file = await _localFile(id);
    await file.writeAsString(content);
  }

  static Future<String> load(String id) async {
    try {
      final File file = await _localFile(id);
      if (file.existsSync()) {
        return await file.readAsString();
      } else {
        return '';
      }
    } catch (e) {
      print(e);
      return 'Error: $e';
    }
  }
}
