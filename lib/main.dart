import 'package:flutter/material.dart';
import 'package:trip_ideas/FireStore.dart';
import 'package:trip_ideas/cardsScreen/CardsScreen.dart';
import 'package:trip_ideas/configScreen.dart';
import 'bubbleScreen/BubbleScreen.dart';

void main() => runApp(MaterialApp(
    title: "Trip Ideas",
    home: ConfigScreen()
));