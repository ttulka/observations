import 'package:intl/intl.dart';
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';
import '../persistence/database.dart';
import '../persistence/storage.dart';
import '../student/domain.dart';
import 'domain.dart';

class MeetingService {
  static const table = 'meetings';

  static final _dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss.mmm');

  Future<List<Meeting>> listByStudent(Student student, [bool loadContent = false]) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table,
        columns: ['id', 'at', 'subject'],
        where: 'studentId = ? AND deleted = FALSE',
        whereArgs: [student.id],
        orderBy: 'at DESC');
    final List<Meeting> results = [];
    for (Map<String, dynamic> map in maps) {
      results.add(Meeting(
        id: map['id'],
        at: _dateFormat.parse(map['at']),
        subject: map['subject'],
        studentId: student.id,
        content: loadContent ? await _loadContent(map['id']) : null,
      ));
    }
    return results;
  }

  // Loads a full meeting with its content
  Future<Meeting?> getById(String meetingId, [bool loadContent = true]) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table,
        columns: ['id', 'at', 'subject', 'studentId'], where: 'id = ? AND deleted = FALSE', whereArgs: [meetingId]);
    if (maps.isNotEmpty) {
      final map = maps.first;
      return Meeting(
        id: map['id'],
        at: _dateFormat.parse(map['at']),
        subject: map['subject'],
        studentId: map['studentId'],
        content: loadContent ? await _loadContent(map['id']) : null,
      );
    }
  }

  Future<bool> save(Meeting meeting) async {
    final Database db = await DatabaseHolder.database;
    final found = await getById(meeting.id, false);
    final result = found != null
        ? await db.update(table, _toMap(meeting), where: 'id = ?', whereArgs: [meeting.id])
        : await db.insert(table, _toMap(meeting), conflictAlgorithm: ConflictAlgorithm.replace);
    await _storeContent(meeting.id, meeting.content!);
    return 0 != result;
  }

  Future<bool> remove(Meeting meeting) async {
    final Database db = await DatabaseHolder.database;
    await db.execute('UPDATE $table SET deleted = TRUE WHERE id = ?', [meeting.id]);
    return true;
  }

  Future<bool> removeAllByStudentId(String studentId) async {
    final Database db = await DatabaseHolder.database;
    await db.execute('UPDATE $table SET deleted = TRUE WHERE studentId = ?', [studentId]);
    return true;
  }

  Future<void> _storeContent(String id, String content) => FileStorage.store(id, content);

  Future<String> _loadContent(String id) => FileStorage.load(id);

  static Map<String, dynamic> _toMap(Meeting meeting) {
    return {
      'id': meeting.id,
      'at': _dateFormat.format(meeting.at),
      'subject': meeting.subject,
      'studentId': meeting.studentId,
      'deleted': 0,
    };
  }
}
