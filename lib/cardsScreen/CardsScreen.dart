import 'package:flutter/material.dart';
import 'package:trip_ideas/FireStore.dart';
import 'package:trip_ideas/bubbleScreen/Parameters.dart';
import 'package:trip_ideas/bubbleScreen/RecommendationUtil.dart';
import 'package:trip_ideas/detailScreen/Detail.dart';
import 'package:trip_ideas/detailScreen/DetailCacheUtil.dart';
import 'package:trip_ideas/model/Parameters.dart';
import 'package:trip_ideas/model/Destination.dart';
import 'package:trip_ideas/Database.dart';
import 'package:trip_ideas/model/config.dart';

import '../favoriteOrVisitedScreen.dart';

class CardsScreen extends StatefulWidget {
  final Widget configButton;

  const CardsScreen({Key key, this.configButton}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CardsScreenState();
}

class CardsScreenState extends State<CardsScreen> {
  final List<Destination> selectedDestinations = [];
  final List<Parameter> parameters = Parameter.exampleParameters;
  int page = 0;

  final Set<int> favorites = Set.of([]);
  final Set<int> visited = Set.of([]);
  Color scoreColor;
  Parameter characteristicHighlighted;

  CardsScreenState() {
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
    DatabaseHelper.instance.queryAllVisited().then((visiteds) {
      setState(() {
        this.visited.clear();
        this.visited.addAll(visiteds.map((destination) => destination.id));
      });
    });
  }

  void loadRecommendations() {
    getRecommendations(parameters, favorites,page).then((destinations) {
      setState(() {
        selectedDestinations.clear();
        selectedDestinations.addAll(destinations);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    selectedDestinations.forEach((destination) {
      destination.isFavorite = favorites.contains(destination.id);
      destination.isVisited = visited.contains(destination.id);
    });

    final components = [
      Expanded(
        flex: 7,
        child: (selectedDestinations == null || selectedDestinations.isEmpty)
            ? Center(child: Text('Loading...')) :
        ListView.builder(
          itemCount: 4,
          itemBuilder: _buildItemsForListView,
        ),
      ),
      Expanded(
        flex: 3,
        child: Column(
          children: <Widget>[
            RaisedButton.icon(
              color: Colors.lightBlueAccent,
              icon: Icon(Icons.refresh),
              label: Text("More..."),
              onPressed: () {
                page = (page + 1) % 4 ;
                loadRecommendations();
                logAction("Mr. User",MSG_MORE_BUTTON, "CardsScreen");
              },
            ),
            Expanded(
              child: Container(
                child: ParameterSliders(
                  parameters: parameters,
                  changeCallback: (changeParameter) {
                    setState(changeParameter);
                  },
                  changeStartCallback: (parameter) {
                    setState(() {
                      characteristicHighlighted = parameter;
                    });
                  },
                  changeEndCallback: (parameter) {
                    setState(() {
                      characteristicHighlighted = null;
                      loadRecommendations();
                    });
                  },
                  highlightParameter: (parameter) =>
                      setState(() {
                        characteristicHighlighted = parameter;
                      }),
                ),
                //padding: EdgeInsets.only(top: 10),
              ),
            )
          ],
        )

      )
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text('Trip Ideas'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.assignment_turned_in),
              onPressed: () {
                logAction("Mr. User",MSG_NAVIGATE_TO_VISITED, "CardsScreen");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteOrVisitedList(type: FavOrVisEnum.visited)),
                ).then((e) => {
                  logAction("Mr. User",MSG_NAVIGATE_TO_HOME, "CardsScreen"),
                  loadRecommendations()
                }); // Refresh on back
              },
            ),
            new IconButton(
              icon: new Icon(Icons.favorite),
              onPressed: () {
                logAction("Mr. User",MSG_NAVIGATE_TO_FAVORITES, "CardsScreen");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteOrVisitedList(type: FavOrVisEnum.favorite)),
                ).then((e) => {
                  logAction("Mr. User",MSG_NAVIGATE_TO_HOME, "CardsScreen"),
                  loadRecommendations()
                }); // Refresh on back
              },
            ),
            widget.configButton
          ],
        ),
        body:
          Container(
            child: MediaQuery.of(context).orientation == Orientation.portrait ?
              Column(children: components) : Row(children: components,),
            color: Color(0x3f81D4FA),
          )

    );
  }

  Card _buildItemsForListView(BuildContext context, int index) {
    return Card(
        elevation: 5.0,
        child: new InkWell(
          onTap: () {
            logAction("Mr. User",MSG_NAVIGATE_TO_DETAIL, "CardsScreen");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailWidget(dest:selectedDestinations[index])),
            ).then((e) => {
            logAction("Mr. User",MSG_NAVIGATE_TO_HOME, "BubbleScreen"),
              loadRecommendations()
            });
          },
          child: new Row(
            children: <Widget>[
              Container(
                height: 125,
                width: 325,
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: FractionalOffset.topLeft,
                      image: new NetworkImage(
                          selectedDestinations[index].pictureURL),
                    )
                ),
                child: Padding(
                  padding: new EdgeInsets.all(10.0),
                  child: Stack(
                    children: <Widget>[
                      Text(
                        selectedDestinations[index].destination,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            shadows: [
                              Shadow(blurRadius: 3, color: Colors.black),
                              Shadow(blurRadius: 7, color: Colors.black),
                            ]
                        )),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: characteristicHighlighted!= null ?
                          LinearProgressIndicator(
                            value: getScoreValue(selectedDestinations[index]),
                            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                            backgroundColor: Colors.white30,
                          ) : Container()
                      )],
                  ),

                  ),),
              Column(
                children: <Widget>[
                  FavoriteOrVisitedWidget(destination: selectedDestinations[index], type: FavOrVisEnum.favorite,onChanged: _handleFavoriteChanged),
                  FavoriteOrVisitedWidget(destination: selectedDestinations[index], type: FavOrVisEnum.visited,onChanged: _handleVisitedChanged)
              ])
              //FavoriteOrVisitedWidget(destination: selectedDestinations[index], type: FavOrVisEnum.favorite,onChanged: _handleFavoriteChanged)
            ],
          ),
        ),
        margin: EdgeInsets.all(5.0)
    );
  }

  double getScoreValue(Destination destination){
    double score;
    switch (characteristicHighlighted.description) {
      case "Beach":     score = destination.scoreBeach.toDouble()/100; scoreColor = colorBeach; break;
      case "Nature":    score = destination.scoreNature.toDouble()/100; scoreColor = colorNature;   break;
      case "Culture":   score = destination.scoreCulture.toDouble()/100; scoreColor = colorCulture;  break;
      case "Shopping":  score = destination.scoreShopping.toDouble()/100; scoreColor = colorShopping;  break;
      case "Nightlife": score = destination.scoreNightlife.toDouble()/100; scoreColor = colorNightlife;  break;
    }
    return score;
  }

  void _handleFavoriteChanged(Destination dest) {
    setState(() {
      int destinationID = dest.id;
      if(favorites.contains(destinationID)) { // was favorite
        favorites.remove(destinationID);
        deleteFavorite(dest);
      } else { // wasn't favorite
        favorites.add(destinationID);
        addFavorite(dest);
      }
      logAction("Mr. User",MSG_MARK_FAVORITE_HOME, "CardsScreen");
    });
  }

  void _handleVisitedChanged(Destination dest) {
    setState(() {
      int destinationID = dest.id;
      if(visited.contains(destinationID)) { // was visited
        visited.remove(destinationID);
        deleteVisited(dest);
      } else { // wasn't visited
        visited.add(destinationID);
        addVisited(dest);
      }
      logAction("Mr. User",MSG_MARK_VISITED_HOME, "CardsScreen");
    });
  }
}

class FavoriteOrVisitedWidget extends StatelessWidget {
  FavoriteOrVisitedWidget({Key key, this.destination, @required this.type,@required this.onChanged})
      : super(key: key);

  final FavOrVisEnum type;
  final Destination destination;
  final ValueChanged<Destination> onChanged;

  void _handleTap() {
    onChanged(destination);
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return IconButton(
      icon: Icon(
          type == FavOrVisEnum.favorite ?
            destination.isFavorite ? Icons.favorite : Icons.favorite_border :
            destination.isVisited ? Icons.check_box : Icons.check_box_outline_blank),
      color: color,
      onPressed: _handleTap,
    );
  }
}