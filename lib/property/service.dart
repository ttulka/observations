import 'package:sqflite/sqlite_api.dart';
import '../persistence/database.dart';

class PropertyService {
  static const table = 'properties';

  Future<bool> autosaveActive() async => await _getValue('autosave') == '1';

  Future<bool> headersActive() async => await _getValue('headers') == '1';

  Future<bool> printingConvertToHtmlActive() async => await _getValue('printing_convert_html') == '1';

  Future<String> meetingTemplate() => _getValue('meeting_template');

  Future<bool> saveMeetingTemplate(String template) => _saveValue('meeting_template', template);

  Future<String> _getValue(String key) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, columns: ['value'], where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) {
      final map = maps.first;
      return map['value'];
    }
    return '';
  }

  Future<bool> _saveValue(String key, String value) async {
    final Database db = await DatabaseHolder.database;
    await db.execute('UPDATE $table SET value = ? WHERE key = ?', [value, key]);
    return true;
  }
}
