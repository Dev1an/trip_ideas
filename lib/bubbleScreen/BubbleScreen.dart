import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bubble_chart/bubble_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:trip_ideas/model/BubbleData.dart';
import 'package:trip_ideas/bubbleScreen/RecommendationUtil.dart';
import 'package:trip_ideas/model/Parameters.dart';
import 'package:trip_ideas/model/Destination.dart';
import '../detailScreen/Detail.dart';

class BubbleScreenState extends State<BubbleScreen> {
  final List<DestinationBubbleData> data = [];
  List<Destination> selectedDestinations = [];
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
          selectedDestinations = destinations;
        })
    );
  }
  static String _radioValue1;
  void _handleRadioValueChange(String value) {
    setState(() {
      _radioValue1 = value;

      switch (_radioValue1) {
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
                Flexible(child: Bubbles(destinations: selectedDestinations)),
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
            floatingActionButton: FloatingActionButton(child: Icon(Icons.refresh), onPressed: () {
              setState(loadRecommendations);
              print("Load bubbles with settings:");
              parameters.forEach((parameter) => print("\t- ${parameter.description}:\t${parameter.value}"));
            },),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked)
    );
  }
}

class ParameterSliders extends StatelessWidget {
  final List<Parameter> parameters;
  final void Function(void Function()) changeCallback;
  final void Function(String) changeRadioCallback;

  const ParameterSliders({Key key, this.parameters, this.changeCallback, this.changeRadioCallback}) : super(key: key);

  Container createRow(Parameter parameter) {
    return Container(
      child: Row(
        children: [
          Text(parameter.description),
          Flexible(
              child: Slider(
                value: parameter.value,
                min: 0, max: 1,
                onChanged: (value) {
                  changeCallback(() {parameter.value = value;});
                },
              )
          ),
          Radio(
            value: parameter.description,
            groupValue: BubbleScreenState._radioValue1,
            onChanged: changeRadioCallback,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: parameters.map(createRow).toList(),
    );
  }
}

class BubbleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BubbleScreenState();
}

class Bubbles extends StatelessWidget {
  final Iterable<Destination> destinations;

  const Bubbles({Key key, this.destinations}) : super(key: key);

  BubbleNode destinationWidget(Destination data, context) {
    return BubbleNode.leaf(
        value: 5,
        options: BubbleOptions(
            child: bubbleContent(data),
            image: NetworkImage(data.pictureURL),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailWidget(destID: data.id)),
              );
            }
        )
    );
  }

  Stack bubbleContent(Destination dest) {
    int score = 0;
    Color scoreColor = Colors.orange;
    switch (BubbleScreenState._radioValue1) {
      case "Beach":   score = dest.scoreBeach; scoreColor = Colors.lightBlueAccent; break;
      case "Nature":  score = dest.scoreNature; scoreColor = Colors.lightGreen;  break;
      case "Culture": score = dest.scoreCulture; scoreColor = Colors.yellow; break;
    }

    double percent = (score.toDouble() / 100);
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        CircularPercentIndicator(
          animation: true,
          animationDuration: 200,
          radius: 154.5,
          lineWidth: 8.0,
          percent: percent,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[],
          ),
          backgroundColor: Colors.white12,
          progressColor: scoreColor,
        ),
        // Stroked text as border.
        Text(
          dest.destination,
          style: TextStyle(
            fontSize: 20,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.grey[900],
          ),
        ),
        // Solid text as fill.
        Text(
          dest.destination,
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[100],
          ),
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) return Text('no items');

    final root = BubbleNode.node(
      padding: 15,
      children: destinations.map((place) => destinationWidget(place, context)).toList(),
    );
    return BubbleChartLayout(root: root);
  }
}