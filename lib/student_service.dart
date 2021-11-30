import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sql.dart';
import 'database.dart';
import 'classroom_domain.dart';
import 'student_domain.dart';
import 'observation_service.dart';

class StudentService {
  static const table = 'students';

  final _observationService = ObservationService();

  Future<List<Student>> listByClassroom(Classroom classroom) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table,
        where: 'classroomId = ? AND deleted = FALSE', whereArgs: [classroom.id], orderBy: 'familyName, givenName');
    return List.generate(maps.length, (i) {
      return Student(
        id: maps[i]['id'],
        familyName: maps[i]['familyName'],
        givenName: maps[i]['givenName'],
        classroomId: maps[i]['classroomId'],
      );
    });
  }

  Future<Student?> getById(String studentId) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, where: 'id = ? AND deleted = FALSE', whereArgs: [studentId]);
    if (maps.isNotEmpty) {
      final map = maps.first;
      return Student(
        id: map['id'],
        familyName: map['familyName'],
        givenName: map['givenName'],
        classroomId: map['classroomId'],
      );
    }
  }

  Future<void> add(Student student) async {
    final Database db = await DatabaseHolder.database;
    await db.insert(table, _toMap(student), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> edit(Student student) async {
    final Database db = await DatabaseHolder.database;
    await db.update(table, _toMap(student), where: 'id = ?', whereArgs: [student.id]);
  }

  Future<void> remove(Student student) async {
    final Database db = await DatabaseHolder.database;
    await _observationService.removeAllByStudentId(student.id);
    await db.execute('UPDATE $table SET deleted = TRUE WHERE id = ?', [student.id]);
  }

  Future<void> removeAllByClassroomId(String classroomId) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, columns: ['id'], where: 'classroomId = ? AND deleted = FALSE', whereArgs: [classroomId]);
    for (Map<String, dynamic> map in maps) {
      final studentId = map['id'];
      await _observationService.removeAllByStudentId(studentId);
    }
    await db.execute('UPDATE $table SET deleted = TRUE WHERE classroomId = ?', [classroomId]);
  }

  static Map<String, dynamic> _toMap(Student student) {
    return {
      'id': student.id,
      'familyName': student.familyName,
      'givenName': student.givenName,
      'classroomId': student.classroomId,
      'deleted': 0,
    };
  }
}
