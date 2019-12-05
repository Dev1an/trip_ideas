import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:trip_ideas/Database.dart';
import 'package:trip_ideas/configScreen.dart';
import 'package:trip_ideas/detailScreen/Detail.dart';
import 'package:trip_ideas/bubbleScreen/RecommendationUtil.dart';
import 'package:trip_ideas/main.dart';
import 'package:trip_ideas/model/Parameters.dart';
import 'package:trip_ideas/model/Destination.dart';
import 'package:trip_ideas/FireStore.dart';

import '../favoriteOrVisitedScreen.dart';
import 'Bubbles.dart';
import 'Parameters.dart';

class BubbleScreenState extends State<BubbleScreen> {
  final List<Destination> selectedDestinations = [];
  final List<Parameter> parameters = Parameter.exampleParameters;
  int page = 1;

  final Set<int> favorites = Set.of([]);
  final Set<int> visited = Set.of([]);

  BubbleScreenState() {
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
    // Update state
    setState(() {
      favorites.add(destination.id);
    });

    // Save record to local DataBase
    DatabaseHelper.instance.insertFavorite(destination.reduced());
  }
  void addVisited(Destination destination) {
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
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DetailWidget(dest: selectedDestinations[index])
            ),
          ).then((value) {
            // Favorites might have changed while browsing the detail pages
            // so we refresh the favorites when we get back to the overview
            loadFavorites();
            loadVisited();
          });
        },
        onRefresh: () {
          loadRecommendations();
          page = (page + 1) % 4 ;
          print("Load bubbles with settings:");
          parameters.forEach((parameter) => print("\t- ${parameter.description}:\t${parameter.value}"));
          logAction("Mr. User","More button clicked", "BubbleScreen");
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteOrVisitedList(type: FavOrVisEnum.visited)),
                ).then((e) {
                  loadFavorites();
                  loadVisited();
                });
              },
            ),
            new IconButton(
              icon: new Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteOrVisitedList(type: FavOrVisEnum.favorite)),
                ).then((e) {
                  loadFavorites();
                  loadVisited();
                }); // Refresh on back
              },
            ),
            widget.configButton
          ],
        ),
        body: MediaQuery.of(context).orientation == Orientation.portrait ?
          Column(children: components) : Row(children: components,)
    );
  }
}

class BubbleScreen extends StatefulWidget {
  final Widget configButton;

  const BubbleScreen({Key key, this.configButton}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BubbleScreenState();
}