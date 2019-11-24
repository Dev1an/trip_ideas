import 'package:flutter/material.dart';
import 'package:trip_ideas/cardsScreen/CardsScreen.dart';
import 'bubbleScreen/BubbleScreen.dart';
import 'model/config.dart';

void main() => runApp(MaterialApp(
    title: "Trip Ideas",
    home: BUBBLESCREEN ? BubbleScreen() : CardsScreen()
));