import 'package:flutter/material.dart';
import 'package:trip_ideas/Database.dart';
import 'package:trip_ideas/detailScreen/Detail.dart';
import 'package:trip_ideas/bubbleScreen/RecommendationUtil.dart';
import 'package:trip_ideas/model/Parameters.dart';
import 'package:trip_ideas/model/Destination.dart';
import 'package:trip_ideas/FireStore.dart';

import '../favoriteOrVisitedScreen.dart';
import 'Bubbles.dart';
import 'Parameters.dart';

class BubbleScreenState extends State<BubbleScreen> {
  final List<Destination> selectedDestinations = [];
  final List<Parameter> parameters = Parameter.exampleParameters;
  int page = 0;
  DateTime showingStart; // start timestamp that screen is showing

  final Set<int> favorites = Set.of([]);
  final Set<int> visited = Set.of([]);

  BubbleScreenState() {
    showingStart = new DateTime.now();
    loadRecommendations();
    loadFavorites();
    loadVisited();
  }

  void loadFavorites() {
    DatabaseHelper.instance.queryAllFavorites().then((favorites) {
      setState(() {
        this.favorites.clear();
        this.favorites.addAll(favorites.map((destination) => destination.id));
      });
    });
  }

  void loadVisited() {
    DatabaseHelper.instance.queryAllVisited().then((visited) {
      setState(() {
        this.visited.clear();
        this.visited.addAll(visited.map((destination) => destination.id));
      });
    });
  }
/*
  Future<Set<int>> getShown() async {
    return (await DatabaseHelper.instance.queryAllShown()).map((destination) => destination.id).toSet();
  }
  */
  void loadRecommendations() {
    //getShown().then((shownDestinations) {
      getRecommendations(parameters, favorites.union(visited),page).then((destinations) {
        setState(() {
          selectedDestinations.clear();
          selectedDestinations.addAll(destinations);
        });
        //destinations.forEach((destination) {
        //  DatabaseHelper.instance.insertShown(destination.reduced());
        //});
      });
    //});
  }

  void addFavorite(Destination destination) {
    logAction("Mr. User",MSG_MARK_FAVORITE_HOME, "BubblesScreen");
    // Update state
    setState(() {
      favorites.add(destination.id);
    });

    // Save record to local DataBase
    DatabaseHelper.instance.insertFavorite(destination.reduced());
  }
  void addVisited(Destination destination) {
    logAction("Mr. User",MSG_MARK_VISITED_HOME, "BubblesScreen");
    // Update state
    setState(() {
      visited.add(destination.id);
    });

    // Save record to local DataBase
    DatabaseHelper.instance.insertVisited(destination.reduced());
  }

  static Parameter highlightedParameter;

  @override
  Widget build(BuildContext context) {
    selectedDestinations.forEach((destination) {
      destination.isFavorite = favorites.contains(destination.id);
      destination.isVisited = visited.contains(destination.id);
    });

    final components = [
      Circles(
        bubbles: selectedDestinations,
        markFavorite: (index) {
          addFavorite(selectedDestinations[index]);
        },
        markVisited: (index) {
          addVisited(selectedDestinations[index]);
        },
        openDetail: (index) {
          int screenTime = (new DateTime.now()).difference(showingStart).inSeconds;
          logAction("Mr. User",MSG_TIME_ON_HOME+screenTime.toString(),"BubbleScreen");
          logAction("Mr. User",MSG_NAVIGATE_TO_DETAIL, "BubbleScreen");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DetailWidget(dest: selectedDestinations[index])
            ),
          ).then((value) {
            // Favorites might have changed while browsing the detail pages
            // so we refresh the favorites when we get back to the overview
            showingStart = new DateTime.now();
            int screenTime = (new DateTime.now()).difference(DetailWidget.showingStart).inSeconds;
            logAction("Mr. User",MSG_TIME_ON_DETAIL+screenTime.toString(),"BubbleScreen");
            logAction("Mr. User",MSG_NAVIGATE_TO_HOME, "BubbleScreen");
            loadFavorites();
            loadVisited();
          });
        },
        onRefresh: () {
          page = (page + 1) % 4;
          loadRecommendations();

          print("Load bubbles with settings:");
          parameters.forEach((parameter) => print("\t- ${parameter.description}:\t${parameter.value}"));
          logAction("Mr. User",MSG_MORE_BUTTON, "BubbleScreen");
        },
        highlightedParameter: highlightedParameter,
      ),
      Flexible(
        child: Container(
          child: ParameterSliders(
            parameters: parameters,
            changeCallback: (changeParameter) {
              setState(changeParameter);
            },
            changeStartCallback: (parameter) {
              setState(() {
                highlightedParameter = parameter;
              });
            },
            changeEndCallback: (parameter) {
              loadRecommendations();
              setState(() {
                highlightedParameter = null;
              });
            },
            highlightParameter: (parameter) => setState(() {highlightedParameter = parameter;})
          ),
          padding: EdgeInsets.only(top: 20),
        ),
      )
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text('Trip Ideas'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.assignment_turned_in),
              onPressed: () {
                int screenTime = (new DateTime.now()).difference(showingStart).inSeconds;
                logAction("Mr. User",MSG_TIME_ON_HOME+screenTime.toString(),"BubbleScreen");
                logAction("Mr. User",MSG_NAVIGATE_TO_VISITED, "BubbleScreen");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteOrVisitedList(type: FavOrVisEnum.visited)),
                ).then((e) {
                  showingStart = new DateTime.now();
                  logAction("Mr. User",MSG_NAVIGATE_TO_HOME, "BubbleScreen");
                  loadFavorites();
                  loadVisited();
                });
              },
            ),
            new IconButton(
              icon: new Icon(Icons.favorite),
              onPressed: () {
                int screenTime = (new DateTime.now()).difference(showingStart).inSeconds;
                logAction("Mr. User",MSG_TIME_ON_HOME+screenTime.toString(),"BubbleScreen");
                logAction("Mr. User",MSG_NAVIGATE_TO_FAVORITES, "BubbleScreen");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteOrVisitedList(type: FavOrVisEnum.favorite)),
                ).then((e) {
                  showingStart = new DateTime.now();
                  logAction("Mr. User",MSG_NAVIGATE_TO_HOME, "BubbleScreen");
                  loadFavorites();
                  loadVisited();
                }); // Refresh on back
              },
            ),
          ],
        ),
        body: MediaQuery.of(context).orientation == Orientation.portrait ?
          Column(children: components) : Row(children: components,)
    );
  }
}

class BubbleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BubbleScreenState();
}