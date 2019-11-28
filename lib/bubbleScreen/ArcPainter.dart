import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  final double length;
  static double width = 7;
  final double boxPosition = width + 3;
  final Color color;

  ArcPainter({this.length, this.color = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    path.arcTo(Rect.fromLTRB(
        boxPosition, boxPosition,
        size.width - boxPosition, size.height - boxPosition),
        pi/2,
        (length * 2*pi) - 0.00001,
        false
    );

    canvas.drawPath(path, paint);
    canvas.drawPath(path, paint
      ..color = color
      ..strokeWidth = width - 2
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
