import 'package:trip_ideas/model/Destination.dart';
import 'package:trip_ideas/model/Parameters.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Destination>> getRecommendations(List<Parameter> parameters, Set<int> favorites) async {
  bool LOCALHOST = true;
  String host;
  if (LOCALHOST)
    host = "localhost:5000";
  else
    host = "http://tripideas.heroku.com";
  String url = 'http://' + host + '/recommendations/';
  int beachScore = (parameters.elementAt(0).value * 100).toInt();
  int natureScore = (parameters.elementAt(1).value * 100).toInt();
  int cultureScore = (parameters.elementAt(2).value * 100).toInt();

  var prefs = [beachScore, natureScore, cultureScore, 0, 5];
  var resp = await http.post(
    url,
    body: {
      'preferences': prefs.toString(),
      'removed': json.encode(favorites.toList())
    }
  );
  //print('Response status: ${resp.statusCode}');
  print('Response body: ${resp.body}');
  String jsonDestinations = resp.body;

  return parseDestinationsFromJSON(jsonDestinations);
}

List<Destination> parseDestinationsFromJSON(String jsonDestinations) {
  Iterable l = json.decode(jsonDestinations);
  List<Destination> destinations = l.map((dest)=> Destination.parseDestinationFromJSON(dest)).toList();

  return destinations;
}

