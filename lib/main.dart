import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bubble_chart/bubble_chart.dart';
import 'detail.dart';

void main() => runApp(TripIdeas());

class TripIdeas extends StatelessWidget {
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

class BubblesState extends State<Bubbles> {
  final cities = <String>[];

  void addCity() {
    setState(() {
      cities.add('Hello');
    });
  }

  BubbleNode cityNode(String name) {
    return BubbleNode.leaf(
      value: 5,
      options: BubbleOptions(
          child: Text(name, style: TextStyle(color: Colors.white))
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final root = BubbleNode.node(
      padding: 15,
      children: [
        BubbleNode.leaf(
            value: 5,
            options: BubbleOptions(
                child: Stack(
                  children: <Widget>[
                    // Stroked text as border.
                    Text(
                      'Paris',
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
                      'Paris',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
                image: AssetImage('assets/images/paris.jpg'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailWidget()),
                  );
                }
            )
        ),
        cityNode('Venice'),
        cityNode('Rome'),
        cityNode('Rouen'),
        cityNode('Bretagne'),
        cityNode('England'),
        cityNode('Oxford'),
      ],
    );
    return BubbleChartLayout(root: root);
  }
}

class Bubbles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BubblesState();
}

