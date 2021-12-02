import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';
import 'database.dart';
import 'storage.dart';
import 'category_domain.dart';
import 'category_service.dart';
import 'student_domain.dart';
import 'observation_domain.dart';

class ObservationService {
  static const table = 'observations';

  static final _dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss.mmm');

  final _categoryService = CategoryService();

  Future<List<Observation>> listByStudent(Student student) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table,
        where: 'studentId = ? AND deleted = FALSE', whereArgs: [student.id], orderBy: 'updatedAt DESC');
    final List<Observation> results = [];
    for (Map<String, dynamic> map in maps) {
      final category = await _categoryService.getByIdOrEmpty(map['categoryId'], includeDeleted: true);
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

  /// Loades or creates a list of [Observation] instances for every category
  Future<List<Observation>> prepareAllByStudent(Student student) async {
    final currentObservations = await listByStudent(student);
    final categories = _mergeCategories(await _categoryService.listAll(), currentObservations);
    final observations = _mergeObservations(categories, currentObservations, student.id);
    return observations;
  }

  /// Merges current categories with historical categories from observations
  static List<Category> _mergeCategories(List<Category> categories, List<Observation> observations) {
    final List<Category> results = [];
    results.addAll(categories);
    observations
        .map((o) => o.category)
        .where((c) => categories.indexWhere((c_) => c_.id == c.id) == -1)
        .forEach((c) => results.add(c));
    return results;
  }

  /// Finds or create a list of [Observation] for all categories
  static List<Observation> _mergeObservations(
      List<Category> categories, List<Observation> observations, String studentId) {
    return categories
        .map((c) => observations.firstWhere(
              (o) => o.category.id == c.id,
              orElse: () => Observation(
                id: const Uuid().v4(),
                category: c,
                studentId: studentId,
                updatedAt: DateTime.now(),
                content: c.template,
              ),
            ))
        .toList();
  }

  Future<Observation?> getById(String observationId) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, where: 'id = ? AND deleted = FALSE', whereArgs: [observationId]);
    if (maps.isNotEmpty) {
      final map = maps.first;
      final category = await _categoryService.getByIdOrEmpty(map['categoryId'], includeDeleted: true);
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
