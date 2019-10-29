import 'package:flutter/material.dart';
import 'package:bubble_chart/bubble_chart.dart';
void main() => runApp(TripIdeas());

class TripIdeas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Trip Ideas",
        home: Scaffold(
          appBar: AppBar(title: Text('Trip Ideas')),
          body: Bubbles(),
        )
    );
  }
}

class BubblesState extends State<Bubbles> {
  @override

  Widget build(BuildContext context) {
    final root = BubbleNode.node(
      padding: 15,
      children: [
        BubbleNode.leaf(
            value: 4159,
            options: BubbleOptions(
                child: Text('Paris', style: TextStyle(color: Colors.white))
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