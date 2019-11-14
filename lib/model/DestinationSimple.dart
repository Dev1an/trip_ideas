import '../Database.dart';

/// Light representation of a Destination. Used for Favorites, Visited and Shown.
class DestinationSimple {

  int id;
  String destination;
  String country;

  DestinationSimple();

  // convenience constructor to create a DestinationSimple object from a Map
  DestinationSimple.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    destination = map[columnDestinationCity];
    country = map[columnDestinationCountry];
  }

  // convenience method to create a Map from this DestinationSimple object
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