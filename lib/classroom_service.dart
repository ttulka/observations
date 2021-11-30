import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sql.dart';
import 'database.dart';
import 'classroom_domain.dart';
import 'student_service.dart';

typedef ClassroomPerYear = Map<int, List<Classroom>>;

class ClassroomService {
  static const table = 'classrooms';

  final _studentService = StudentService();

  Future<ClassroomPerYear> listAll() async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table, where: 'deleted = FALSE', orderBy: 'year DESC, name');
    final classrooms = List.generate(maps.length, (i) {
      return Classroom(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        year: maps[i]['year'],
      );
    });
    final years = classrooms.map((c) => c.year).toSet();
    return {for (var y in years) y: classrooms.where((c) => c.year == y).toList()};
  }

  Future<void> add(Classroom classroom) async {
    final Database db = await DatabaseHolder.database;
    await db.insert(table, _toMap(classroom), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> edit(Classroom classroom) async {
    final Database db = await DatabaseHolder.database;
    await db.update(table, _toMap(classroom), where: 'id = ?', whereArgs: [classroom.id]);
  }

  Future<void> remove(Classroom classroom) async {
    final Database db = await DatabaseHolder.database;
    await _studentService.removeAllByClassroomId(classroom.id);
    await db.execute('UPDATE $table SET deleted = TRUE WHERE id = ?', [classroom.id]);
  }

  static Map<String, dynamic> _toMap(Classroom classroom) {
    return {
      'id': classroom.id,
      'name': classroom.name,
      'description': classroom.description,
      'year': classroom.year,
      'deleted': 0,
    };
  }
}
