import 'package:trip_ideas/model/DestinationSimple.dart';

import '../Database.dart';

/// Class with all the details of a Destination
class Destination {

  int id;
  String destination;
  String country;
  String location;
  String description;
  String pictureURL; // not directly persisted, but included in otherImagesJSON by DetailCacheUtil
  String otherImagesJSON;
  int scoreBeach;
  int scoreNature;
  int scoreCulture;
  int scoreShopping;
  int scoreNightlife;
  bool isFavorite = false;
  bool isVisited = false;

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

  // Convert JSON to Destination
  static Destination parseDestinationFromJSON(Map<String, dynamic> json) {
    Destination destination = new Destination();
    destination.id = json['id'];
    destination.destination = json['Destination'];
    destination.country = json['Country'];
    destination.pictureURL = json['Front image'];
    destination.location = json['Location'];
    destination.scoreBeach = json['Beach score'];
    destination.scoreNature = json['Nature score'];
    destination.scoreCulture = json['Culture score'];
    destination.scoreShopping = json['Shopping score'];
    destination.scoreNightlife = json['Nightlife score'];

    return destination;
  }

  DestinationSimple reduced() {
    return DestinationSimple.init(
      id: id,
      destination: destination,
      country: country
    );
  }
}