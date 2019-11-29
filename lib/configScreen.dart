import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trip_ideas/model/config.dart';

class ConfigScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ConfigScreenState();
}


class ConfigScreenState extends State<ConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Ideas'),
      ),
      body: Center(
        child: Checkbox(value: BUBBLESCREEN, onChanged: (bool) => this.setState(() {
          BUBBLESCREEN = bool;
        }),),
      ),
      floatingActionButton: CupertinoButton(child: Text('Hello world'), onPressed: () {
        print("pressed button");
      },),
    );
  }

}