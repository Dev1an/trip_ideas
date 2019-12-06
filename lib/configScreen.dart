import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trip_ideas/bubbleScreen/BubbleScreen.dart';
import 'package:trip_ideas/cardsScreen/CardsScreen.dart';
import 'package:trip_ideas/main.dart';

class ConfigState extends State<ConfigScreen> {
  bool showBubbles = true;
  String username = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Ideas')
      ),
      body: Column(
        children: [
          CheckboxListTile(
            title: Text('Show bubbles'),
            value: showBubbles,
            onChanged: (state) => setState(() => showBubbles = state),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            padding: EdgeInsets.all(8),
          ),
          Container(
            child: RaisedButton(
              child: Row(
                children: <Widget>[
                  Text('Start testing'),
                  Icon(Icons.arrow_forward, semanticLabel: "Start testing")
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => showBubbles ?  BubbleScreen() : CardsScreen()),
                );
              },
              color: Colors.blueAccent,
              textColor: Colors.white,
            ),
            padding: EdgeInsets.all(8),
          )
        ],
      )
    );
  }
}

class ConfigScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ConfigState();
}