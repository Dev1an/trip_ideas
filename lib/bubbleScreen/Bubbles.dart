import 'package:flutter/material.dart';
import 'package:bubble_chart/bubble_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:trip_ideas/model/Destination.dart';
import '../detailScreen/Detail.dart';
import 'BubbleScreen.dart';

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
    switch (BubbleScreenState.radioValue1) {
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