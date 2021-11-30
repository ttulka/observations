import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseHolder {
  static late Future<Database> database;

  static Future<void> connectDatabase() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'observations.db'),
      version: 1,
      onCreate: (db, version) {
        db.execute(r'CREATE TABLE classrooms(id TEXT PRIMARY KEY, name TEXT, description TEXT, year INTEGER)');
        db.execute(r'CREATE TABLE students(id TEXT PRIMARY KEY, familyName TEXT, givenName TEXT, template TEXT)');
        db.execute(
            r'CREATE TABLE categories(id TEXT PRIMARY KEY, name TEXT, template TEXT, priority INTEGER, deleted INTEGER DEFAULT 0)');
        db.execute(
            r'CREATE TABLE observations(id TEXT PRIMARY KEY, categoryId TEXT, updatedAt TEXT, FOREIGN KEY(categoryId) REFERENCES categories(id))');

        db.execute(
            "INSERT INTO categories VALUES ('${const Uuid().v4()}', '#social', '', 0, FALSE), ('${const Uuid().v4()}', '#work', '', 1, FALSE)");
      },
    );
    print("=== DATABASE PATH: " + (await database).path);
  }
}
