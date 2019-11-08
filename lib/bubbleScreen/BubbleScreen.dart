import 'package:flutter/material.dart';
import 'package:bubble_chart/bubble_chart.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:trip_ideas/bubbleScreen/BubbleData.dart';
import 'package:trip_ideas/bubbleScreen/MockData.dart';
import '../detail.dart';

class BubbleScreenState extends State<BubbleScreen> {
  final data = loadData();

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
          body: Bubbles(),
        )
    );
  }
}

class BubbleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BubbleScreenState();
}

class Bubbles extends StatelessWidget {
  BubbleNode destinationWidget(DestinationBubbleData data, context) {
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
      children: sampleData.map((place) => destinationWidget(place, context)).toList(),
    );
    return BubbleChartLayout(root: root);
  }
}