import 'package:flutter/material.dart';
import 'package:bubble_chart/bubble_chart.dart';
import 'package:trip_ideas/bubbleScreen/BubbleData.dart';
import 'package:trip_ideas/bubbleScreen/MockData.dart';
import '../detail.dart';

class BubbleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    loadData();
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
          body: Bubbles(),
        )
    );
  }
}

class BubblesState extends State<Bubbles> {
  final cities = <String>[];

  void addCity() {
    setState(() {
      cities.add('Hello');
    });
  }

  BubbleNode destinationWidget(DestinationBubbleData data) {
    return BubbleNode.leaf(
        value: 5,
        options: BubbleOptions(
            child: strokedText(data.name),
            image: NetworkImage(data.pictureUrl),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailWidget(destID: 1)),
              );
            }
        )
    );
  }
  
  Stack strokedText(String content) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          content,
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
          content,
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
    final root = BubbleNode.node(
      padding: 15,
      children: sampleData.map(destinationWidget).toList(),
    );
    return BubbleChartLayout(root: root);
  }
}

class Bubbles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BubblesState();
}

