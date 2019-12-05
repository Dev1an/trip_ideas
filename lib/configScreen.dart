import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trip_ideas/main.dart';

class ConfigScreenSate extends State<ConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Ideas'),
      ),
      body: Center(
        child: Checkbox(value: VersionSwitcher.showBubbles, onChanged: (state) {
          setState(() {
            widget.showBubbles(state);
          });
        }),
      ),
      floatingActionButton: CupertinoButton(child: Text('Hello world'), onPressed: () {
        print("pressed button");
      },),
    );
  }
}

class ConfigScreen extends StatefulWidget {
  final void Function(bool) showBubbles;

  const ConfigScreen({Key key, this.showBubbles}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ConfigScreenSate();
}