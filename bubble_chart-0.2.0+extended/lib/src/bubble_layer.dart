import 'package:bubble_chart/src/bubble_node.dart';
import 'package:flutter/material.dart';

class BubbleLayer extends StatelessWidget {
  final BubbleNode bubble;

  const BubbleLayer({this.bubble});

  onTap() {
    if (bubble.options.onTap != null) bubble.options.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: bubble.radius * 2,
        height: bubble.radius * 2,
        decoration: BoxDecoration(
          border: bubble.options?.border ?? Border(),
          color: bubble.options?.color ?? Theme.of(context).accentColor,
          image: bubble.options.image == null ?
            null :
            DecorationImage(image: bubble.options.image, fit: BoxFit.cover),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: bubble.options?.child ?? Container(),
        ),
      ),
    );
  }
}
