import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';

class FileStorage {
  static String? _directory;

  static get directory async => _directory ??= await _getDirectory();

  static Future<String> _getDirectory() async {
    Directory dir = await getLibraryDirectory();
    Logger.info("storage path: " + dir.path);
    return dir.path;
  }

  static Future<File> _localFile(String id) async {
    final String dir = await directory;
    return File('$dir/$id');
  }

  static Future<bool> store(String id, String content) async {
    Logger.debug('store content: $content');
    try {
      final File file = await _localFile(id);
      file.writeAsStringSync(content);
      return true;
    } catch (e) {
      Logger.error('Cannot store the file: $id', e);
      return false;
    }
  }

  static Future<String> load(String id) async {
    try {
      final File file = await _localFile(id);
      if (file.existsSync()) {
        return file.readAsStringSync();
      } else {
        return '';
      }
    } catch (e) {
      Logger.error('Cannot load the file: $id', e);
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
      Logger.error('Cannot delete the file: $id', e);
      return false;
    }
  }
}
