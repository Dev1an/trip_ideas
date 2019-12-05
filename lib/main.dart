import 'package:flutter/material.dart';
import 'package:trip_ideas/FireStore.dart';
import 'package:trip_ideas/cardsScreen/CardsScreen.dart';
import 'package:trip_ideas/configScreen.dart';
import 'bubbleScreen/BubbleScreen.dart';
import 'model/config.dart';

void main() => runApp(MaterialApp(
    title: "Trip Ideas",
    home: VersionSwitcher()
));

class VersionSwitcher extends StatefulWidget {
  static bool showBubbles = true;

  @override
  State<StatefulWidget> createState() => VersionState();
}

class VersionState extends State<VersionSwitcher> {
  void setBubbles(bool visible) {
    setState(() {
      VersionSwitcher.showBubbles = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final configButton = IconButton(
      icon: new Icon(Icons.account_circle),
      onPressed: () {
        getAllLogs();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConfigScreen(
            showBubbles: setBubbles,
          )),
        );
      },
    );
    return VersionSwitcher.showBubbles ? BubbleScreen(configButton: configButton) : CardsScreen(configButton: configButton);
  }
}