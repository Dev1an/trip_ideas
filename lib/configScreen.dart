import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trip_ideas/FireStore.dart';
import 'package:trip_ideas/bubbleScreen/BubbleScreen.dart';
import 'package:trip_ideas/cardsScreen/CardsScreen.dart';

class ConfigState extends State<ConfigScreen> {
  static String userID;

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
              onChanged: (state) {
                username = state;
              },
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
                DatabaseHelper.instance.resetUser().then((_) {
                  logActionData(
                      'New user',
                      {
                        'username': username,
                        'mode': showBubbles ? 'Bubble' : 'List',
                      }
                  ).then((userReference) {
                    userID = userReference.documentID;
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => showBubbles ?  BubbleScreen() : CardsScreen()),
                            (_) => false
                    );
                  });
                });
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