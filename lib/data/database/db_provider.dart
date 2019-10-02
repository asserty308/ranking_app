import 'package:path/path.dart';
import 'package:ranking_app/data/models/list.dart';
import 'package:sqflite/sqflite.dart';

class RankingDatabaseProvider {
  // private constructor
  RankingDatabaseProvider._();

  // static access
  static final RankingDatabaseProvider db = RankingDatabaseProvider._();

  // private members
  Database _database;
  final int _version = 1;

  // Singleton
  Future<Database> get database async {
    if (_database != null)
      return _database;

    _database = await createDatabaseInstance();
    return _database;
  }

  Future<Database> createDatabaseInstance() async {
    String path = join(await getDatabasesPath(), 'ranking_db.db');
    
    return await openDatabase(
      path,
      // When the database is first created, create the necessary tables.
      onCreate: (db, version) async {
        // create table for Lists
        await db.execute("CREATE TABLE Lists(key TEXT PRIMARY KEY, title TEXT, subtitle TEXT, position INTEGER)");

        // create another table for ListEntrys
        await db.execute("CREATE TABLE ListEntries(key TEXT PRIMARY KEY, title TEXT, subtitle TEXT, body TEXT, position INTEGER)");
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: _version,
    );
  }

  insertNewList(ListDM list) async {
    final db = await database;
    db.insert(
      'Lists', 
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort
    );
  }

  Future<ListDM> getListWithKey(String key) async {
    final db = await database;
    var response = await db.query('Lists', where: 'key = ?', whereArgs: [key]);
    return response.isNotEmpty ? ListDM.fromMap(response.first) : null;
  }

  Future<List<ListDM>> getAllLists() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('Lists');

    return List.generate(maps.length, (i) {
      return ListDM(
        key: maps[i]['key'],
        title: maps[i]['title'],
        subtitle: maps[i]['subtitle'],
        position: maps[i]['index'],
      );
    });
  }

  Future<int> getListsLength() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Lists'));
  }
}