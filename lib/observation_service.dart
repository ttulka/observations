import 'package:intl/intl.dart';
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';
import 'database.dart';
import 'storage.dart';
import 'category_service.dart';
import 'student_domain.dart';
import 'observation_domain.dart';

class ObservationService {
  static const table = 'observations';

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  final _categoryService = CategoryService();

  Future<List<Observation>> listByStudent(Student student) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table,
        where: 'studentId = ? AND deleted = FALSE', whereArgs: [student.id], orderBy: 'updatedAt DESC');
    final List<Observation> results = [];
    for (Map<String, dynamic> map in maps) {
      final category = await _categoryService.getByIdOrEmpty(map['categoryId']);
      results.add(Observation(
        id: map['id'],
        category: category,
        studentId: student.id,
        updatedAt: _dateFormat.parse(map['updatedAt']),
        content: await _loadContent(map['id']),
      ));
    }
    return results;
  }

  Future<Observation?> getById(String observationId) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, where: 'id = ? AND deleted = FALSE', whereArgs: [observationId]);
    if (maps.isNotEmpty) {
      final map = maps.first;
      final category = await _categoryService.getByIdOrEmpty(map['categoryId']);
      return Observation(
        id: map['id'],
        category: category,
        studentId: map['studentId'],
        updatedAt: _dateFormat.parse(map['updatedAt']),
        content: await _loadContent(map['id']),
      );
    }
  }

  Future<void> save(Observation observation) async {
    final Database db = await DatabaseHolder.database;
    final found = await getById(observation.id);
    if (found != null) {
      await db.update(table, _toMap(observation), where: 'id = ?', whereArgs: [observation.id]);
    } else {
      await db.insert(table, _toMap(observation), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    _storeContent(observation.id, observation.content);
  }

  Future<void> remove(Observation observation) async {
    final db = await DatabaseHolder.database;
    await db.execute('UPDATE $table SET deleted = TRUE WHERE id = ?', [observation.id]);
  }

  Future<void> removeAllByStudentId(String studentId) async {
    final db = await DatabaseHolder.database;
    await db.execute('UPDATE $table SET deleted = TRUE WHERE studentId = ?', [studentId]);
  }

  Future<void> _storeContent(String id, String content) => FileStorage.store(id, content);

  Future<String> _loadContent(String id) => FileStorage.load(id);

  static Map<String, dynamic> _toMap(Observation observation) {
    return {
      'id': observation.id,
      'categoryId': observation.category.id,
      'studentId': observation.studentId,
      'updatedAt': _dateFormat.format(observation.updatedAt),
      'deleted': 0,
    };
  }
}
