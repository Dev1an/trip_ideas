import 'package:flutter/material.dart';
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
    Parameter('Culture', 0.70)
  ];

  BubbleScreenState() {
    loadRecommendations();
  }

  void loadRecommendations() {
    getRecommendations(parameters).then((destinations) =>
        setState(() {
          selectedDestinations.clear();
          selectedDestinations.addAll(destinations);
        })
    );
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
    return MaterialApp(
        title: "Trip Ideas",
        home: Scaffold(
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
            body: Column(
              children: [
                Flexible(
                  child: Circles(
                    bubbles: selectedDestinations,
                    markFavorite: (index) {print('mark $index as favorite');},
                    markVisited: (index) {print('mark $index as visited');},
                    openDetail: (index) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DetailWidget(destID: selectedDestinations[index].id)
                        ),
                      );
                    },
                    onRefresh: () {
                      loadRecommendations();
                      print("Load bubbles with settings:");
                      parameters.forEach((parameter) => print("\t- ${parameter.description}:\t${parameter.value}"));
                    }
                  )
                ),
                Container(
                  child: ParameterSliders(
                    parameters: parameters,
                    changeCallback: (changeParameter) {
                      setState(changeParameter);
                    },
                    changeRadioCallback: _handleRadioValueChange,
                  ),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                )
              ],
            ),
        )
    );
  }
}

class BubbleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BubbleScreenState();
}