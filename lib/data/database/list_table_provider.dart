import 'package:ranking_app/data/database/db_provider.dart';
import 'package:ranking_app/data/models/list.dart';
import 'package:sqflite/sqflite.dart';

class ListTableProvider {
  // private constructor
  ListTableProvider._();

  // static access
  static final ListTableProvider table = ListTableProvider._();

  Future<void> insert(ListDM list) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.insert(
      'Lists', 
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort
    );
  }

  Future<ListDM> getWithKey(String key) async {
    final db = await RankingDatabaseProvider.db.database;
    var response = await db.query('Lists', where: 'key = ?', whereArgs: [key]);
    return response.isNotEmpty ? ListDM.fromMap(response.first) : null;
  }

  Future<List<ListDM>> getAll() async {
    final db = await RankingDatabaseProvider.db.database;

    final List<Map<String, dynamic>> maps = await db.query('Lists');

    return List.generate(maps.length, (i) {
      return ListDM(
        key: maps[i]['key'],
        title: maps[i]['title'],
        subtitle: maps[i]['subtitle'],
        position: maps[i]['position'],
      );
    });
  }

  Future<int> tableCount() async {
    final db = await RankingDatabaseProvider.db.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Lists'));
  }

  Future<void> update(ListDM list) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.update(
      'Lists', 
      list.toMap(),
      where: 'key = ?',
      whereArgs: [list.key]
    );
  }

  Future<void> delete(String key) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.delete(
      'Lists',
      where: 'id = ?',
      whereArgs: [key],
    );
  }
}