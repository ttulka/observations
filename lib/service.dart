import 'package:observations/database.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'domain.dart';

final CLASSROOMS = [
  Classroom(id: const Uuid().v4(), name: 'A1', description: 'First class A', year: 2021),
  Classroom(id: const Uuid().v4(), name: 'A2', description: 'Second class A', year: 2020),
  Classroom(id: const Uuid().v4(), name: 'B2', description: 'Second class B', year: 2020),
];

class ClassroomService {
  Map<int, List<Classroom>> listAll() {
    final years = CLASSROOMS.map((c) => c.year).toSet();
    return {for (var y in years) y: CLASSROOMS.where((c) => c.year == y).toList()};
  }

  void add(Classroom classroom) {
    CLASSROOMS.add(classroom);
  }

  void edit(Classroom classroom) {
    final i = CLASSROOMS.indexWhere((c) => c.id == classroom.id);
    if (i != -1) {
      CLASSROOMS.removeAt(i);
      CLASSROOMS.insert(i, classroom);
    }
  }

  void remove(Classroom classroom) {
    CLASSROOMS.remove(classroom);
  }
}

final STUDENTS = [
  Student(id: const Uuid().v4(), givenName: 'Bart', familyName: 'Simpson'),
  Student(id: const Uuid().v4(), givenName: 'Milhouse', familyName: 'Van Houten'),
  Student(id: const Uuid().v4(), givenName: 'Martin', familyName: 'Prince'),
  Student(id: const Uuid().v4(), givenName: 'Nelson', familyName: 'Muntz'),
];

class StudentService {
  List<Student> listByClassroom(Classroom classroom) {
    STUDENTS.sort((a, b) => a.familyName.compareTo(b.familyName));
    return STUDENTS;
  }

  void add(Student student) {
    STUDENTS.add(student);
  }

  void edit(Student oldStudent, Student newStudent) {
    final i = STUDENTS.indexOf(oldStudent);
    if (i != -1) {
      STUDENTS.remove(oldStudent);
      STUDENTS.insert(i, newStudent);
    }
  }

  void remove(Student student) {
    STUDENTS.remove(student);
  }
}

class CategoryService {
  static const table = 'categories';

  Future<List<Category>> listAll() async {
    final db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table, where: 'deleted = FALSE', orderBy: 'priority');
    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        template: maps[i]['template'],
      );
    });
  }

  Future<void> add(Category category) async {
    final db = await DatabaseHolder.database;
    final prio = await _getMaxPriority() + 1;
    await db.insert(
      table,
      _toMap(category, prio),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> edit(Category category) async {
    final db = await DatabaseHolder.database;
    final prio = await _getPriority(category);
    await db.update(table, _toMap(category, prio), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<void> remove(Category category) async {
    final db = await DatabaseHolder.database;
    final prio = await _getPriority(category);
    await db.execute('UPDATE $table SET deleted = TRUE WHERE id = ?', [category.id]);
    await db.execute('UPDATE $table SET priority = priority - 1 WHERE priority > ?', [prio]);
  }

  Future<void> up(Category category) async {
    final db = await DatabaseHolder.database;
    final prio = await _getPriority(category) - 1;
    if (prio >= 0) {
      await db.execute('UPDATE $table SET priority = priority + 1 WHERE priority = ?', [prio]);
      await db.execute('UPDATE $table SET priority = priority - 1 WHERE id = ?', [category.id]);
    }
  }

  Future<void> down(Category category) async {
    final db = await DatabaseHolder.database;
    final maxPrio = await _getMaxPriority();
    final prio = await _getPriority(category) + 1;
    if (prio <= maxPrio) {
      await db.execute('UPDATE $table SET priority = priority - 1 WHERE priority = ?', [prio]);
      await db.execute('UPDATE $table SET priority = priority + 1 WHERE id = ?', [category.id]);
    }
  }

  Future<int> _getPriority(Category category) async {
    final db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, columns: ['priority'], where: 'id = ?', whereArgs: [category.id]);
    return maps.first.values.first;
  }

  Future<int> _getMaxPriority() async {
    final db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table, columns: ['MAX(priority)']);
    return maps.first.values.first;
  }

  static Map<String, dynamic> _toMap(Category category, int priority) {
    return {
      'id': category.id,
      'name': category.name,
      'template': category.template,
      'priority': priority,
      'deleted': false,
    };
  }
}

final OBSERVATIONS = [
  Observation(
      id: const Uuid().v4(),
      category: Category(id: "1", name: "Category 1", template: ""),
      updatedAt: DateTime.now(),
      content:
          r'[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n"}]'),
  Observation(
      id: const Uuid().v4(),
      category: Category(id: "2", name: "Category 2", template: ""),
      updatedAt: DateTime.now(),
      content:
          r'[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n"}]'),
];

class ObservationService {
  List<Observation> listByStudent(Student student) {
    return OBSERVATIONS;
  }

  void save(Observation observation) {
    final i = OBSERVATIONS.indexWhere((o) => o.id == observation.id);
    if (i != -1) {
      OBSERVATIONS.removeAt(i);
      OBSERVATIONS.insert(i, observation);
    } else {
      OBSERVATIONS.add(observation);
    }
  }

  void remove(Observation observation) {
    OBSERVATIONS.remove(observation);
  }
}
