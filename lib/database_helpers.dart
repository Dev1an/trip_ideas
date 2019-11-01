import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// Destinations database table and column names
final String tableDestinations = 'destinations';
final String columnId = '_id';
final String columnDestinationCity = 'destination';
final String columnDestinationCountry = 'country';
final String columnLocation = 'location';
final String columnDescription = 'description';

final String tableFavorites = 'favorites';

final String tableVisited = 'visited';

// data model class
class Destination {

  int id;
  String destination;
  String country;
  String location;
  String description;

  Destination();

  // convenience constructor to create a Destination object from a Map
  Destination.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    destination = map[columnDestinationCity];
    country = map[columnDestinationCountry];
    location = map[columnLocation];
    description = map[columnDescription];
  }

  // convenience method to create a Map from this Destination object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDestinationCity: destination,
      columnDestinationCountry: country,
      columnLocation: location,
      columnDescription: description
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

class FavoriteOrVisited {

  int id;
  String destination;
  String country;

  FavoriteOrVisited();

  // convenience constructor to create a Favorite object from a Map
  FavoriteOrVisited.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    destination = map[columnDestinationCity];
    country = map[columnDestinationCountry];
  }

  // convenience method to create a Map from this Favorite object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDestinationCity: destination,
      columnDestinationCountry: country
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}



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
    //Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //String path = join(documentsDirectory.path, _databaseName);

    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath,_databaseName);

// Make sure the directory exists
    try {

      await Directory(databasesPath).create(recursive: true);
    } catch (e) {print(e);}

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
                $columnDestinationCountry TEXT NOT NULL,
                $columnLocation TEXT NOT NULL,
                $columnDescription TEXT NOT NULL
              )
              ''');
    await db.execute('''
       CREATE TABLE $tableFavorites (
        $columnId INTEGER PRIMARY KEY,
        $columnDestinationCity TEXT NOT NULL,
        $columnDestinationCountry TEXT NOT NULL
       )''');
    await db.execute('''
       CREATE TABLE $tableVisited (
        $columnId INTEGER PRIMARY KEY,
        $columnDestinationCity TEXT NOT NULL,
        $columnDestinationCountry TEXT NOT NULL
       )''');
  }

  // Database helper methods:
  // -------- DESTINATIONS --------
  // INSERT
  Future<int> insertDestination(Destination dest) async {
    Database db = await database;
    int id = await db.insert(tableDestinations, dest.toMap());
    return id;
  }

  // QUERY DESTINATION
  Future<Destination> queryDestination(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableDestinations,
        columns: [columnId, columnDestinationCity, columnDestinationCountry,columnLocation,columnDescription],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Destination.fromMap(maps.first);
    }
    return null;
  }

  // CHECK IF EXISTS
  Future<bool> checkIfExistsDestination(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableDestinations,
        columns: [columnId],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return true;
    }
    return false;
  }

// TO DO: queryAllDestinations()
// TO DO: delete(int id)
// TO DO: update(Destination destination)

  // -------- FAVORITE OR VISITED --------
  // INSERT
  Future<int> insertFavorite(FavoriteOrVisited favOrVis) async {
    return insertFavoriteOrVisited(favOrVis, tableFavorites);
  }

  Future<int> insertVisited(FavoriteOrVisited favOrVis) async {
    return insertFavoriteOrVisited(favOrVis, tableVisited);
  }

  Future<int> insertFavoriteOrVisited(FavoriteOrVisited favOrVis, String table) async {
    Database db = await database;
    int id = await db.insert(table, favOrVis.toMap());
    return id;
  }

  // DELETE
  Future<int> deleteFavorite(int id) async {
    return deleteFavoriteOrVisited(id, tableFavorites);
  }

  Future<int> deleteVisited(int id) async {
    return deleteFavoriteOrVisited(id, tableVisited);
  }

  Future<int> deleteFavoriteOrVisited(int id,String table) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // CHECK IF EXISTS
  Future<bool> checkIfExistsFavorite(int id) async {
    return checkIfExists(id, tableFavorites);
  }

  Future<bool> checkIfExistsVisited(int id) async {
    return checkIfExists(id, tableVisited);
  }

  Future<bool> checkIfExists(int id, String table) async {
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

  // QUERY ALL
  Future<List<FavoriteOrVisited>> queryAllFavorites() async {
    return queryAllFavoriteOrVisited(tableFavorites);
  }
  Future<List<FavoriteOrVisited>> queryAllVisited() async {
    return queryAllFavoriteOrVisited(tableVisited);
  }

  Future<List<FavoriteOrVisited>> queryAllFavoriteOrVisited(String table) async {
    Database db = await database;
    List<Map> maps = await db.query(table); //SELECT *
    if (maps.length > 0) {
      return maps.map((favOrVis) => FavoriteOrVisited.fromMap(favOrVis)).toList();
    }
    return null;
  }



}

