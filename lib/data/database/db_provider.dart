import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Provides acces to the app's database.
/// 
/// You can access the [database] from everywhere by calling [RankingDatabaseProvider.db.database].
/// Use this class to update and upgrade the database.
class RankingDatabaseProvider {
  // private constructor
  RankingDatabaseProvider._();

  // static access
  static final RankingDatabaseProvider db = RankingDatabaseProvider._();

  // private members
  Database _database;
  final int _version = 2;

  /// Singleton access to the database instance
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

        // create another table for ListEntries
        await db.execute("CREATE TABLE ListEntries(key TEXT PRIMARY KEY, title TEXT, subtitle TEXT, body TEXT, position INTEGER, list_fk TEXT)");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          // v1 to v2: add list_fk to ListEntries
          await db.execute('ALTER TABLE ListEntries ADD COLUMN list_fk TEXT;');
        }
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: _version,
    );
  }
}