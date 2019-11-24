import '../Database.dart';
import 'Destination.dart';

/// Light representation of a Destination. Used for Favorites, Visited and Shown.
class DestinationSimple {

  int id;
  String destination;
  String country;
  String pictureURL;

  DestinationSimple();
  DestinationSimple.init({this.id, this.destination, this.country,this.pictureURL});

  // convenience constructor to create a DestinationSimple object from a Map
  DestinationSimple.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    destination = map[columnDestinationCity];
    country = map[columnDestinationCountry];
    pictureURL = map[columnImage];
  }

  // convenience method to create a Map from this DestinationSimple object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDestinationCity: destination,
      columnDestinationCountry: country,
      columnImage: pictureURL
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Destination toDestination() {
    Destination dest = Destination();
    dest.destination = destination;
    dest.pictureURL = pictureURL;
    dest.country = country;
    dest.id = id;
    return dest;
  }
}