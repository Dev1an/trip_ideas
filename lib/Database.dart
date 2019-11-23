import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'model/Destination.dart';
import 'model/DestinationSimple.dart';

// Destinations database table and column names
final String tableDestinations = 'destinations';
final String columnId = '_id';
final String columnDestinationCity = 'destination';
final String columnDestinationCountry = 'country';
final String columnLocation = 'location';
final String columnDescription = 'description';
final String columnOtherImages = 'otherimages';
final String columnScoreBeach = 'scorebeach';
final String columnScoreNature = 'scorenature';
final String columnScoreCulture = 'scoreculture';
final String columnScoreShopping = 'scoreshopping';
final String columnScoreNightlife = 'scorenightlife';
final String columnImage = 'image';

final String tableFavorites = 'favorites';
final String tableVisited = 'visited';
final String tablePreferences = 'preferences';
List<DestinationSimple> shownList = new List<DestinationSimple>();

// singleton class to manage the database
class DatabaseHelper {

  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "TripIdeasDatabase.db";

  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, _databaseName);

  // Make sure the directory exists
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (e) {
      print(e);
    }

    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableDestinations (
                $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
                $columnDestinationCity TEXT NOT NULL,
                $columnDestinationCountry TEXT,
                $columnLocation TEXT NOT NULL,
                $columnDescription TEXT NOT NULL,
                $columnOtherImages TEXT NOT NULL,
                $columnScoreBeach INTEGER NOT NULL,
                $columnScoreNature INTEGER NOT NULL,
                $columnScoreCulture INTEGER NOT NULL,
                $columnScoreShopping INTEGER NOT NULL,
                $columnScoreNightlife INTEGER NOT NULL
              )
              ''');
    await db.execute('''
       CREATE TABLE $tableFavorites (
        $columnId INTEGER PRIMARY KEY,
        $columnDestinationCity TEXT NOT NULL,
        $columnDestinationCountry TEXT,
        $columnImage TEXT
       )''');
    await db.execute('''
       CREATE TABLE $tableVisited (
        $columnId INTEGER PRIMARY KEY,
        $columnDestinationCity TEXT NOT NULL,
        $columnDestinationCountry TEXT,
        $columnImage TEXT
       )''');
  }

  // __________________________________________________________
  //                       HELPER METHODS
  // __________________________________________________________
  // ================== DESTINATIONS ==================
  // ----------------- INSERT -----------------
  Future<int> insertDestination(Destination dest) async {
    Database db = await database;
    int id = await db.insert(tableDestinations, dest.toMap());
    return id;
  }

  // ----------------- QUERY DESTINATION -----------------
  Future<Destination> readDestination(int id) async {
    print('queryDestination with id '+id.toString());
    Database db = await database;
    List<Map> maps = await db.query(tableDestinations,
        columns: [columnId, columnDestinationCity, columnDestinationCountry,
          columnLocation,columnDescription,columnOtherImages,
          columnScoreBeach,columnScoreNature,columnScoreCulture,columnScoreShopping,columnScoreNightlife],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Destination.fromMap(maps.first);
    }
    return null;
  }

  // ================== FAVORITE OR VISITED OR SHOWN ==================
  // ----------------- INSERT -----------------
  Future<int> insertFavorite(DestinationSimple fav) async {
    return _insertDestinationSimpleInTable(fav, tableFavorites);
  }

  Future<int> insertVisited(DestinationSimple vis) async {
    return _insertDestinationSimpleInTable(vis, tableVisited);
  }

  Future<int> insertShown(DestinationSimple shown) async {
    shownList.add(shown);
    return -666;
    //return _insertDestinationSimpleInTable(shown, tableShown);
  }

  Future<int> _insertDestinationSimpleInTable(DestinationSimple destSimple, String table) async {
    Database db = await database;
    int id = await db.insert(table, destSimple.toMap());
    return id;
  }

  // -----------------  DELETE -----------------
  Future<int> deleteFavorite(int id) async {
    return _deleteDestinationSimpleInTable(id, tableFavorites);
  }

  Future<int> deleteVisited(int id) async {
    return _deleteDestinationSimpleInTable(id, tableVisited);
  }

  Future<int> deleteShown(int id) async {
    shownList.removeWhere((dest) => dest.id == id);
    return -777;
  }

  Future<int> _deleteDestinationSimpleInTable(int id,String table) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // ----------------- CHECK IF EXISTS -----------------
  Future<bool> checkIfExistsFavorite(int id) async {
    return _checkIfExistsInTable(id, tableFavorites);
  }

  Future<bool> checkIfExistsVisited(int id) async {
    return _checkIfExistsInTable(id, tableVisited);
  }

  Future<bool> checkIfExistsDestination(int id) async {
    return _checkIfExistsInTable(id, tableDestinations);
  }


  Future<bool> _checkIfExistsInTable(int id, String table) async {
    Database db = await database;
    List<Map> maps = await db.query(table,
        columns: [columnId],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return true;
    }
    return false;
  }

  // -----------------  QUERY ALL -----------------
  Future<List<DestinationSimple>> queryAllFavorites() async {
    return _queryAllDestinationSimpleInTable(tableFavorites);
  }
  Future<List<DestinationSimple>> queryAllVisited() async {
    return _queryAllDestinationSimpleInTable(tableVisited);
  }

  Future<List<DestinationSimple>> queryAllShown() async {
    return shownList;
    //return _queryAllDestinationSimpleInTable(tableShown);
  }

  Future<List<DestinationSimple>> _queryAllDestinationSimpleInTable(String table) async {
    Database db = await database;
    List<Map> maps = await db.query(table); //SELECT *
    if (maps.length > 0) {
      return maps.map((favOrVis) => DestinationSimple.fromMap(favOrVis)).toList();
    }
    return [];
  }
}
