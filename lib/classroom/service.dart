import 'package:observations/student/domain.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import '../persistence/database.dart';
import 'domain.dart';
import '../student/service.dart';

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

  Future<bool> add(Classroom classroom) async {
    final Database db = await DatabaseHolder.database;
    return 0 != await db.insert(table, _toMap(classroom), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> edit(Classroom classroom) async {
    final Database db = await DatabaseHolder.database;
    return 0 != await db.update(table, _toMap(classroom), where: 'id = ?', whereArgs: [classroom.id]);
  }

  Future<bool> remove(Classroom classroom) async {
    final Database db = await DatabaseHolder.database;
    await _studentService.removeAllByClassroomId(classroom.id);
    await db.execute('UPDATE $table SET deleted = TRUE WHERE id = ?', [classroom.id]);
    return true;
  }

  Future<Classroom> copyWithStudents(Classroom classroom) async {
    final classroomId = const Uuid().v4();
    final newClassroom = Classroom(
        id: classroomId, name: classroom.name, description: '(Copy) ${classroom.description}', year: classroom.year);
    await add(newClassroom);
    final students = await _studentService.listByClassroom(classroom);
    for (var s in students) {
      final student =
          Student(id: const Uuid().v4(), givenName: s.givenName, familyName: s.familyName, classroomId: classroomId);
      await _studentService.add(student);
    }
    return newClassroom;
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
