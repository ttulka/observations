import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static String? _directory;

  static get directory async => _directory ??= await _getDirectory();

  static Future<String> _getDirectory() async {
    Directory dir = await getLibraryDirectory();
    print("=== STORAGE PATH: " + dir.path);
    return dir.path;
  }

  static Future<File> _localFile(String id) async {
    final String dir = await directory;
    return File('$dir/$id');
  }

  static Future<bool> store(String id, String content) async {
    print('=== STORE CONTENT: $content');
    try {
      final File file = await _localFile(id);
      await file.writeAsString(content);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
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
      return '[{"insert":"Error: ${e.toString().replaceAll('"', "'")}","attributes":{"color":"#ff0000"}},{"insert":"\\n"}]';
    }
  }

  static Future<bool> delete(String id) async {
    try {
      final File file = await _localFile(id);
      if (file.existsSync()) {
        await file.delete();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<void> storeAsPdf(String id, String content) async {
    final File file = await _localFile(id);
    await file.writeAsString(content);
  }
}
