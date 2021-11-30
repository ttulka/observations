import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseHolder {
  static Database? _database;

  static get database async => _database ??= await _connectDatabase();

  static Future<Database> _connectDatabase() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'observations.db'),
      version: 1,
      onCreate: (db, version) {
        db.execute(
            r'CREATE TABLE classrooms(id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, description TEXT, year INTEGER NOT NULL, deleted INTEGER NOT NULL DEFAULT 0)');
        db.execute(
            r'CREATE TABLE students(id TEXT NOT NULL PRIMARY KEY, familyName TEXT NOT NULL, givenName TEXT NOT NULL, classroomId TEXT NOT NULL, deleted INTEGER NOT NULL DEFAULT 0, FOREIGN KEY(classroomId) REFERENCES classrooms(id))');
        db.execute(
            r'CREATE TABLE categories(id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, template TEXT NOT NULL, priority INTEGER NOT NULL, deleted INTEGER NOT NULL DEFAULT 0)');
        db.execute(
            r'CREATE TABLE observations(id TEXT NOT NULL PRIMARY KEY, updatedAt TEXT NOT NULL, studentId TEXT NOT NULL, categoryId TEXT NOT NULL, deleted INTEGER NOT NULL DEFAULT 0, FOREIGN KEY(studentId) REFERENCES students(id), FOREIGN KEY(categoryId) REFERENCES categories(id))');

        db.execute(
            "INSERT INTO categories VALUES ('${const Uuid().v4()}', '#social', '', 0, FALSE), ('${const Uuid().v4()}', '#work', '', 1, FALSE)");
      },
    );
    print("=== DATABASE PATH: " + db.path);
    return db;
  }
}
