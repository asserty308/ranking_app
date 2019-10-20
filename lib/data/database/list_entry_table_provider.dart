import 'package:ranking_app/data/database/db_provider.dart';
import 'package:ranking_app/data/models/list_entry.dart';
import 'package:sqflite/sqflite.dart';

class ListEntryTableProvider {
  // private constructor
  ListEntryTableProvider._();

  // static access
  static final ListEntryTableProvider table = ListEntryTableProvider._();

  Future<void> insert(ListEntryDM list) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.insert(
      'ListEntries', 
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort
    );
  }

  Future<ListEntryDM> getWithKey(String key) async {
    final db = await RankingDatabaseProvider.db.database;
    var response = await db.query('ListEntries', where: 'key = ?', whereArgs: [key]);
    return response.isNotEmpty ? ListEntryDM.fromMap(response.first) : null;
  }

  Future<List<ListEntryDM>> getAll() async {
    final db = await RankingDatabaseProvider.db.database;

    final List<Map<String, dynamic>> maps = await db.query('ListEntries');

    return List.generate(maps.length, (i) {
      return ListEntryDM(
        key: maps[i]['key'],
        title: maps[i]['title'],
        subtitle: maps[i]['subtitle'],
        position: maps[i]['position'],
        listKey: maps[i]['list_fk'],
      );
    });
  }

  Future<List<ListEntryDM>> getAllFromList(String listKey) async {
    final db = await RankingDatabaseProvider.db.database;

    final maps = await db.query('ListEntries', where: 'list_fk = ?', whereArgs: [listKey]);

    return List.generate(maps.length, (i) {
      return ListEntryDM(
        key: maps[i]['key'],
        title: maps[i]['title'],
        subtitle: maps[i]['subtitle'],
        position: maps[i]['position'],
        listKey: maps[i]['list_fk'],
      );
    });
  }

  Future<int> listCount(String listKey) async {
    final db = await RankingDatabaseProvider.db.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ListEntries WHERE list_fk = ?', [listKey]));
  }

  Future<int> tableCount() async {
    final db = await RankingDatabaseProvider.db.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ListEntries'));
  }

  Future<void> update(ListEntryDM list) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.update(
      'ListEntries', 
      list.toMap(),
      where: 'key = ?',
      whereArgs: [list.key]
    );
  }

  Future<void> delete(String key) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.delete(
      'ListEntries',
      where: 'key = ?',
      whereArgs: [key],
    );
  }
}