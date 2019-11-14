import '../Database.dart';
import '../model/Destination.dart';
import '../model/DestinationSimple.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

const bool LOCALHOST = true; // Use localhost or Heroku for details lookup

// ==================== ADD ====================
addDestinationToCache(Destination dest) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  await helper.insertDestination(dest);
  print('inserted ' + dest.destination + ' in cache');
}

addFavorite(Destination dest) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  DestinationSimple fv = new DestinationSimple();
  fv.id = dest.id;
  fv.destination = dest.destination;
  fv.country = dest.country;
  await helper.insertFavorite(fv);
  print('inserted ' + dest.destination + ' as favorite');
}

addVisited(Destination dest) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  DestinationSimple fv = new DestinationSimple();
  fv.id = dest.id;
  fv.destination = dest.destination;
  fv.country = dest.country;
  int id = await helper.insertVisited(fv);
  print('inserted visited row: $id');
}

// ==================== DELETE ====================
deleteFavorite(Destination dest) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  await helper.deleteFavorite(dest.id);
  print('deleted ' + dest.destination + " as favorite");
}

deleteVisited(Destination dest) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  await helper.deleteVisited(dest.id);
  print('deleted ' + dest.destination + " as visited");
}

// ==================== CHECK IF ... ====================
Future<bool> checkIfFavorite(Destination dest) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  bool exists = await helper.checkIfExistsFavorite(dest.id);
  print(exists
      ? dest.destination + " is favorite"
      : dest.destination + " is not favorite");

  return exists;
}

Future<bool> checkIfVisited(Destination dest) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  bool exists = await helper.checkIfExistsVisited(dest.id);
  print(exists
      ? dest.destination + " is visited"
      : dest.destination + " is not visited");

  return exists;
}

// ==================== GET ====================
/// Searches for the destination in the cache. If not found, an API call
/// is performed to the backend, and the result is added to the cache.
Future<Destination> getDetailsOfDestination(int destID) async {
  // CHECK IF AVAILABLE IN CACHE
  DatabaseHelper helper = DatabaseHelper.instance;
  bool exists = await helper.checkIfExistsDestination(destID);
  if (exists) return readDestinationFromCache(destID);

  // NOT IN CACHE
  Destination destination = new Destination();
  // URL
  String host;
  if (LOCALHOST)
    host = "localhost:5000";
  else
    host = "http://tripideas.heroku.com";
  String url = 'http://' + host + '/destination/?id=' + destID.toString();
  // GET REQUEST
  var response = await http.get(url); // sample info available in response

  // PARSE RESPONSE
  int statusCode = response.statusCode;
  if (statusCode == HttpStatus.ok) {
    var data = json.decode(response.body);
    print(data);
    var raw_destination = data[0];
    destination = new Destination();
    destination.id = destID;
    destination.country = raw_destination['Country'];
    destination.destination = raw_destination['Destination'];
    destination.description = raw_destination['Description'];
    destination.location = raw_destination['Location'];
    String images = raw_destination['Other images'];
    List<String> imagesList = images.substring(1, images.length - 1).split("1");
    imagesList.add(raw_destination['Front image']);
    destination.otherImagesJSON = jsonEncode(imagesList);
    destination.scoreBeach = raw_destination['Beach score'];
    destination.scoreNature = raw_destination['Nature score'];
    destination.scoreCulture = raw_destination['Culture score'];
    destination.scoreShopping = raw_destination['Shopping score'];
    destination.scoreNightlife = raw_destination['Nightlife score'];
    // ADD TO CACHE
    addDestinationToCache(destination);

    return destination;
  } else {
    // ?
  }

  return destination;
}

/// Retrieve the destination from the cache by id.
Future<Destination> readDestinationFromCache(int destID) async {
  DatabaseHelper helper = DatabaseHelper.instance;
  Destination dest = await helper.readDestination(destID);
  if (dest == null) {
    print('read row $destID: empty');
    return null;
  } else {
    print(
        'found in cache: $destID ${dest.destination} ${dest.location} ${dest.otherImagesJSON} ');
    return dest;
  }
}
