import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trip_ideas/model/Destination.dart';

class Parameter {
  final ParameterType type;
  final String description;
  final Color color;
  double value;

  static List<Parameter> exampleParameters = [
    Parameter(type: ParameterType.beach, value: 0.20, description: "Beach", color: Colors.lightBlueAccent),
    Parameter(type: ParameterType.nature, value: 0.90, description: "Nature", color: Colors.lightGreen),
    Parameter(type: ParameterType.culture, value: 0.70, description: "Culture", color: Colors.yellow),
    Parameter(type: ParameterType.shopping, value: 0.10, description: "Shopping", color: Colors.purple),
    Parameter(type: ParameterType.nightlife, value: 0.3, description: "Nightlife", color: Colors.pink)
  ];

  Parameter({this.type, this.value, this.description, this.color});

}