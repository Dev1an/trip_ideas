import 'package:trip_ideas/model/Destination.dart';
import 'package:trip_ideas/model/Parameters.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Destination>> getRecommendations(List<Parameter> parameters, Set<int> favorites) async {
  bool LOCALHOST = true;
  String baseURL;
  if (LOCALHOST)
    baseURL = "http://localhost:5000";
  else
    baseURL = "https://tripideas.herokuapp.com";
  String url = baseURL + '/recommendations/';
  int     beachScore = (parameters.elementAt(0).value * 100).toInt();
  int    natureScore = (parameters.elementAt(1).value * 100).toInt();
  int   cultureScore = (parameters.elementAt(2).value * 100).toInt();
  int  shoppingScore = (parameters.elementAt(3).value * 100).toInt();
  int nightLifeScore = (parameters.elementAt(4).value * 100).toInt();

  var prefs = [beachScore, natureScore, cultureScore, shoppingScore, nightLifeScore];
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

