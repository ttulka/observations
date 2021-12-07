import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sql.dart';
import '../persistence/database.dart';
import 'domain.dart';

class CategoryService {
  static const table = 'categories';

  Future<List<Category>> listAll() async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table, where: 'deleted = FALSE', orderBy: 'priority');
    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        template: maps[i]['template'],
        priority: maps[i]['priority'],
      );
    });
  }

  Future<Category> getByIdOrEmpty(String categoryId, {bool includeDeleted = false}) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, where: 'id = ? ${!includeDeleted ? 'AND deleted = FALSE' : ''}', whereArgs: [categoryId]);
    if (maps.isNotEmpty) {
      final record = maps.first;
      return Category(
        id: record['id'],
        name: record['name'],
        template: record['template'],
        priority: record['priority'],
      );
    }
    return Category(id: categoryId, name: '???', template: '', priority: 999999);
  }

  Future<bool> add(Category category) async {
    final Database db = await DatabaseHolder.database;
    final prio = await _getMaxPriority() + 1;
    return 0 != await db.insert(table, _toMap(category, prio), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> edit(Category category) async {
    final Database db = await DatabaseHolder.database;
    final prio = await _getPriority(category);
    return 0 != await db.update(table, _toMap(category, prio), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<bool> remove(Category category) async {
    final Database db = await DatabaseHolder.database;
    final prio = await _getPriority(category);
    await db.execute('UPDATE $table SET deleted = TRUE WHERE id = ?', [category.id]);
    await db.execute('UPDATE $table SET priority = priority - 1 WHERE priority > ?', [prio]);
    return true;
  }

  Future<bool> up(Category category) async {
    final Database db = await DatabaseHolder.database;
    final prio = await _getPriority(category) - 1;
    if (prio >= 0) {
      await db.execute('UPDATE $table SET priority = priority + 1 WHERE priority = ?', [prio]);
      await db.execute('UPDATE $table SET priority = priority - 1 WHERE id = ?', [category.id]);
      return true;
    }
    return false;
  }

  Future<bool> down(Category category) async {
    final Database db = await DatabaseHolder.database;
    final maxPrio = await _getMaxPriority();
    final prio = await _getPriority(category) + 1;
    if (prio <= maxPrio) {
      await db.execute('UPDATE $table SET priority = priority - 1 WHERE priority = ?', [prio]);
      await db.execute('UPDATE $table SET priority = priority + 1 WHERE id = ?', [category.id]);
      return true;
    }
    return false;
  }

  Future<int> _getPriority(Category category) async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, columns: ['priority'], where: 'id = ?', whereArgs: [category.id]);
    final result = maps.isNotEmpty ? maps.first['priority'] : 1;
    return result;
  }

  Future<int> _getMaxPriority() async {
    final Database db = await DatabaseHolder.database;
    final List<Map<String, dynamic>> maps = await db.query(table, columns: ['MAX(priority) as priority']);
    final result = maps.isNotEmpty ? maps.first['priority'] : 1;
    return result;
  }

  static Map<String, dynamic> _toMap(Category category, int priority) {
    return {
      'id': category.id,
      'name': category.name,
      'template': category.template,
      'priority': priority,
      'deleted': 0,
    };
  }
}
