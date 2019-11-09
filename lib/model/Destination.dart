import '../database_helpers.dart';

/// Class with all the details of a Destination
class Destination {

  int id;
  String destination;
  String country;
  String location;
  String description;
  String otherImagesJSON;
  int scoreBeach;
  int scoreNature;
  int scoreCulture;
  int scoreShopping;
  int scoreNightlife;

  Destination();

  // convenience constructor to create a Destination object from a Map
  Destination.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    destination = map[columnDestinationCity];
    country = map[columnDestinationCountry];
    location = map[columnLocation];
    description = map[columnDescription];
    otherImagesJSON = map[columnOtherImages];
    scoreBeach = map[columnScoreBeach];
    scoreNature = map[columnScoreNature];
    scoreCulture = map[columnScoreCulture];
    scoreShopping = map[columnScoreShopping];
    scoreNightlife = map[columnScoreNightlife];
  }

  // convenience method to create a Map from this Destination object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDestinationCity: destination,
      columnDestinationCountry: country,
      columnLocation: location,
      columnDescription: description,
      columnOtherImages: otherImagesJSON,
      columnScoreBeach: scoreBeach,
      columnScoreNature: scoreNature,
      columnScoreCulture: scoreCulture,
      columnScoreShopping: scoreShopping,
      columnScoreNightlife: scoreNightlife
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}