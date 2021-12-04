import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../utils/logger.dart';
import 'storage.dart';

class DatabaseHolder {
  static Database? _database;

  static get database async => _database ??= await _connectDatabase();

  static Future<Database> _connectDatabase() async {
    databaseFactory = databaseFactoryFfi;
    final db = await openDatabase(
      join((await getApplicationSupportDirectory()).path, 'observations.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            r'CREATE TABLE classrooms(id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, description TEXT, year INTEGER NOT NULL, deleted INTEGER NOT NULL DEFAULT 0)');
        await db.execute(
            r'CREATE INDEX classrooms_deletedIdx ON classrooms (deleted)');
        await db.execute(
            r'CREATE TABLE students(id TEXT NOT NULL PRIMARY KEY, familyName TEXT NOT NULL, givenName TEXT NOT NULL, classroomId TEXT NOT NULL, deleted INTEGER NOT NULL DEFAULT 0, FOREIGN KEY(classroomId) REFERENCES classrooms(id))');
        await db
            .execute(r'CREATE INDEX students_deletedIdx ON students (deleted)');
        await db.execute(
            r'CREATE INDEX students_classroomIdx ON students (classroomId)');
        await db.execute(
            r'CREATE TABLE categories(id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, template TEXT NOT NULL, priority INTEGER NOT NULL, deleted INTEGER NOT NULL DEFAULT 0)');
        await db.execute(
            r'CREATE INDEX categories_deletedIdx ON categories (deleted)');
        await db.execute(
            r'CREATE TABLE observations(id TEXT NOT NULL PRIMARY KEY, updatedAt TEXT NOT NULL, studentId TEXT NOT NULL, categoryId TEXT NOT NULL, deleted INTEGER NOT NULL DEFAULT 0, FOREIGN KEY(studentId) REFERENCES students(id), FOREIGN KEY(categoryId) REFERENCES categories(id))');
        await db.execute(
            r'CREATE INDEX observations_deletedIdx ON observations (deleted)');
        await db.execute(
            r'CREATE INDEX observations_studentIdx ON observations (categoryId)');
        await db.execute(
            r'CREATE INDEX observations_categoryIdx ON observations (categoryId)');
        await db.execute(
            r'CREATE TABLE properties(key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)');

        await db.execute(
            "INSERT INTO categories VALUES ('${const Uuid().v4()}', '#social', '', 0, FALSE), ('${const Uuid().v4()}', '#work', '', 1, FALSE)");
        await db.execute("INSERT INTO properties VALUES ('version', '0')");
        await db.execute("INSERT INTO properties VALUES ('autosave', '1')");
        await db.execute("INSERT INTO properties VALUES ('headers', '1')");

        if (!kReleaseMode) {
          await generateFakeData(db);
        }
      },
    );
    Logger.info("Database path: " + db.path);
    return db;
  }
}

Future<void> updateProperty(String key, String value) async {
  final Database db = await DatabaseHolder.database;
  db.update('properties', {'value': value}, where: 'key = ?', whereArgs: [key]);
}

/// Restore all soft-deleted data
Future<void> restore() async {
  final Database db = await DatabaseHolder.database;
  db.update('observations', {'deleted': 0}, where: 'deleted = TRUE');
  db.update('students', {'deleted': 0}, where: 'deleted = TRUE');
  db.update('classrooms', {'deleted': 0}, where: 'deleted = TRUE');
}

/// Purge all soft-deleted data and erase soft-deleted stored files.
Future<void> purge() async {
  final Database db = await DatabaseHolder.database;
  final results =
      await db.query('observations', columns: ['id'], where: 'deleted = TRUE');
  for (Map<String, Object?> m in results) {
    await FileStorage.delete(m['id'].toString());
  }
  await db.delete('observations', where: 'deleted = TRUE');
  await db.delete('students', where: 'deleted = TRUE');
  await db.delete('classrooms', where: 'deleted = TRUE');
}

Future<void> generateFakeData(Database db) async {
  final now = DateTime.now();
  await db.execute(
      "INSERT INTO categories VALUES ('${const Uuid().v4()}', 'Math', '', 2, FALSE), ('${const Uuid().v4()}', 'English', '', 3, FALSE)");
  final bartsClassId = const Uuid().v4();
  await db.execute(
      "INSERT INTO classrooms VALUES ('$bartsClassId', '4A', 'Bart\'\'s class', '${now.year}', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Simpson', 'Bart', '$bartsClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Muntz', 'Nelson', '$bartsClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Prince', 'Martin', '$bartsClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Van Houten', 'Milhouse', '$bartsClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Borton', 'Wendell', '$bartsClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Clark', 'Lewis', '$bartsClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Mackleberry', 'Sherri', '$bartsClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Mackleberry', 'Terri', '$bartsClassId', FALSE)");
  final lisasClassId = const Uuid().v4();
  await db.execute(
      "INSERT INTO classrooms VALUES ('$lisasClassId', '3A', 'Lisa\'\'s class', '${now.year}', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Simpson', 'Lisa', '$lisasClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Wiggum', 'Ralph', '$lisasClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Powell', 'Janey', '$lisasClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Taylor', 'Allison', '$lisasClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Whitney', 'Alex', '$lisasClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Weasel', 'Black', '$lisasClassId', FALSE)");
  await db.execute(
      "INSERT INTO students VALUES ('${const Uuid().v4()}', 'Weasel', 'Yellow', '$lisasClassId', FALSE)");
}
