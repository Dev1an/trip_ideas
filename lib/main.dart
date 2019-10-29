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
  int test = 0;
  @override
  Widget build(BuildContext context) {
    final root = BubbleNode.node(
      padding: 15,
      children: [
        BubbleNode.leaf(
            value: 4159,
            options: BubbleOptions(
                child: GestureDetector(
                  onTap: () {
                    //Insert event to be fired up when button is clicked here
                    //in this case, this increments our `countValue` variable by one.
                    setState(() => log(test));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailWidget()),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: new AssetImage('assets/images/paris.jpg'),
                    minRadius: 40,
                    maxRadius: 60,
                    child: Align(
                        alignment: Alignment(0,0.5),
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
                        )
                    ),
                  ),
                )
            )
        ),
        BubbleNode.leaf(
            value: 2074,
            options: BubbleOptions(
                child: Text('Venice', style: TextStyle(color: Colors.white))
            )
        ),
        BubbleNode.leaf(
            value: 4319,
            options: BubbleOptions(
                child: Text('Rome', style: TextStyle(color: Colors.white))
            )
        ),
        BubbleNode.leaf(
            value: 2074,
            options: BubbleOptions(
                child: Text('Rouen', style: TextStyle(color: Colors.white))
            )
        ),
        BubbleNode.leaf(
            value: 2074,
            options: BubbleOptions(
                child: Text('Bretagne', style: TextStyle(color: Colors.white))
            )
        ),
        BubbleNode.leaf(
            value: 2074,
            options: BubbleOptions(
                child: Text('England', style: TextStyle(color: Colors.white))
            )
        ),
        BubbleNode.leaf(
            value: 2074,
            options: BubbleOptions(
                child: Text('Oxford', style: TextStyle(color: Colors.white))
            )
        ),
      ],
    );

    return BubbleChartLayout(root: root);
  }
}

class Bubbles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BubblesState();
}

