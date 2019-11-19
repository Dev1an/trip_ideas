import 'package:flutter/material.dart';
import 'package:trip_ideas/model/Parameters.dart';

import 'BubbleScreen.dart';

class ParameterSliders extends StatelessWidget {
  final List<Parameter> parameters;
  final void Function(void Function()) changeCallback;
  final void Function(Parameter) changeStartCallback;
  final void Function(Parameter) changeEndCallback;
  final void Function(String) changeRadioCallback;

  const ParameterSliders({
    Key key,
    this.parameters,
    this.changeCallback,
    this.changeStartCallback,
    this.changeEndCallback,
    this.changeRadioCallback
  }) : super(key: key);

  Container createRow(Parameter parameter) {
    return Container(
      child: Row(
        children: [
          Text(parameter.description),
          Flexible(
              child: Slider(
                value: parameter.value,
                min: 0, max: 1,
                onChanged: (value) {
                  changeCallback(() {parameter.value = value;});
                },
                onChangeStart: (value) => changeStartCallback(parameter),
                onChangeEnd: (value) => changeEndCallback(parameter),
              )
          ),
          Radio(
            value: parameter.description,
            groupValue: BubbleScreenState.radioValue1,
            onChanged: changeRadioCallback,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: parameters.map(createRow).toList(),
    );
  }
}