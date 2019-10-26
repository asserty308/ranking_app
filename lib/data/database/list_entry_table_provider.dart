import 'package:ranking_app/data/database/db_provider.dart';
import 'package:ranking_app/data/models/list_entry.dart';
import 'package:sqflite/sqflite.dart';

class ListEntryTableProvider {
  // private constructor
  ListEntryTableProvider._();

  // static access
  static final ListEntryTableProvider table = ListEntryTableProvider._();

  /// Adds a new [entry] to the table [ListEntries].
  Future<void> insert(ListEntryDM entry) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.insert(
      'ListEntries', 
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort
    );
  }

  /// Fetches the entry with key [key] from the table [ListEntries].
  Future<ListEntryDM> getWithKey(String key) async {
    final db = await RankingDatabaseProvider.db.database;
    var response = await db.query('ListEntries', where: 'key = ?', whereArgs: [key]);
    return response.isNotEmpty ? ListEntryDM.fromMap(response.first) : null;
  }

  /// Fetches all entries from the table [ListEntries].
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

  /// Fetches all entries belonging to the list with key [listKey].
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

  /// Returns the number of entries of the list with key [listKey].
  Future<int> listCount(String listKey) async {
    final db = await RankingDatabaseProvider.db.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ListEntries WHERE list_fk = ?', [listKey]));
  }

  /// Returns the number of entries inside the table [ListEntries].
  Future<int> tableCount() async {
    final db = await RankingDatabaseProvider.db.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ListEntries'));
  }

  /// Updates the entry with key [entry.key] to the new values of [entry].
  Future<void> update(ListEntryDM entry) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.update(
      'ListEntries', 
      entry.toMap(),
      where: 'key = ?',
      whereArgs: [entry.key]
    );
  }

  /// Deletes the entry with key [key] from the table [ListEntries].
  Future<void> delete(String key) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.delete(
      'ListEntries',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// Removes all entries belonging to the list with key [listKey].
  Future<void> deleteAllInList(String listKey) async {
    final db = await RankingDatabaseProvider.db.database;
    await db.delete(
      'ListEntries',
      where: 'list_fk = ?',
      whereArgs: [listKey],
    );
  }
}