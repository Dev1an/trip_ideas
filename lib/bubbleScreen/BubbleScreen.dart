import 'package:flutter/material.dart';
import 'package:trip_ideas/Database.dart';
import 'package:trip_ideas/detailScreen/Detail.dart';
import 'package:trip_ideas/model/BubbleData.dart';
import 'package:trip_ideas/bubbleScreen/RecommendationUtil.dart';
import 'package:trip_ideas/model/Parameters.dart';
import 'package:trip_ideas/model/Destination.dart';

import 'Bubbles.dart';
import 'Parameters.dart';

class BubbleScreenState extends State<BubbleScreen> {
  final List<DestinationBubbleData> data = [];
  final List<Destination> selectedDestinations = [];
  final List<Parameter> parameters = [
    Parameter('Beach', 0.20),
    Parameter('Nature', 0.90),
    Parameter('Culture', 0.70),
    Parameter('Shopping', 0.10),
    Parameter('Nightlife', 0.30)
  ];

  final Set<int> favorites = Set.of([]);

  BubbleScreenState() {
    loadRecommendations();
    loadFavorites();
  }

  void loadFavorites() {
    DatabaseHelper.instance.queryAllFavorites().then((favorites) {
      setState(() {
        this.favorites.clear();
        this.favorites.addAll(favorites.map((destination) => destination.id));
      });
    });
  }

  Future<Set<int>> getShown() async {
    return (await DatabaseHelper.instance.queryAllShown()).map((destination) => destination.id).toSet();
  }
  
  void loadRecommendations() {
    getShown().then((shownDestinations) {
      getRecommendations(parameters, favorites.union(shownDestinations)).then((destinations) {
        setState(() {
          selectedDestinations.clear();
          selectedDestinations.addAll(destinations);
        });
        destinations.forEach((destination) {
          DatabaseHelper.instance.insertShown(destination.reduced());
        });
      });
    });
  }

  void addFavorite(Destination destination) {
    // Update state
    setState(() {
      favorites.add(destination.id);
    });

    // Save record to local DataBase
    DatabaseHelper.instance.insertFavorite(destination.reduced());
  }
  
  static String radioValue1;
  void _handleRadioValueChange(String value) {
    setState(() {
      radioValue1 = value;

      switch (radioValue1) {
        case "Beach":
          print("you toggled beach");
          break;
        case "Nature":
          print("you toggled nature");
          break;
        case "Culture":
          print("you toggled culture");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedDestinations.forEach((destination) {
      destination.isFavorite = favorites.contains(destination.id);
    });

    final components = [
      Builder(
        builder: (context) => Circles(
            bubbles: selectedDestinations,
            markFavorite: (index) {
              addFavorite(selectedDestinations[index]);
            },
            markVisited: (index) {print('mark $index as visited');},
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
              });
            },
            onRefresh: () {
              loadRecommendations();
              print("Load bubbles with settings:");
              parameters.forEach((parameter) => print("\t- ${parameter.description}:\t${parameter.value}"));
            }
        ),
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
                radioValue1 = parameter.description;
              });
            },
            changeEndCallback: (parameter) {
              setState(() {
                radioValue1 = '';
                loadRecommendations();
              });
            },
            highlightParameter: (parameterDescription) => setState(() {radioValue1 = parameterDescription;}),
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
              onPressed: () {},
            ),
            new IconButton(
              icon: new Icon(Icons.favorite),
              onPressed: () {},
            ),
            new IconButton(
              icon: new Icon(Icons.account_circle),
              onPressed: () {},
            )
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