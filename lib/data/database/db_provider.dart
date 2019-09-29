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
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute("CREATE TABLE Lists(key TEXT PRIMARY KEY, title TEXT, subtitle TEXT)");
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: _version,
    );
  }

  addNewList(ListDM list) async {
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
}