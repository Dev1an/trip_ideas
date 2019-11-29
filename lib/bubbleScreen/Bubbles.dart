import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:trip_ideas/model/Destination.dart';
import 'package:trip_ideas/model/Parameters.dart';
import 'ArcPainter.dart';
import 'EnhancedDraggable.dart';

class Circles extends StatefulWidget {
  final List<Destination> bubbles;
  final void Function(int) markFavorite;
  final void Function(int) markVisited;
  final void Function(int) openDetail;
  final void Function() onRefresh;
  final Parameter highlightedParameter;

  const Circles({Key key, this.bubbles, this.markFavorite, this.markVisited, this.openDetail, this.onRefresh, this.highlightedParameter}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CirclesState();
}

class CirclesState extends State<Circles> with SingleTickerProviderStateMixin {
  static final double offset = pi/2;
  double position = pi/4;
  double positionOffset = 0;
  double startAngle;
  bool isInDragMode = false;

  NetworkImage picture;

  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.addListener(() {
      setState(() {
        position = _animation.value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _animation;

  Align draggableCircle({int index, BuildContext context, Destination data}) {
    final NetworkImage picture = NetworkImage(data.pictureURL);

    final circle = Container(
      decoration: circleDecoration(picture),
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                    data.destination,
                    style: TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 3, color: Colors.black),
                        Shadow(blurRadius: 7, color: Colors.black)
                      ],
                      fontSize: 20,
                    )
                ),
              ),
              if (data.isFavorite) Icon(Icons.favorite, color: Colors.white),
//                            if (data.isVisited) Icon(Icons.assignment_turned_in, color: Colors.white),
            ],
          )
      ),
    );

    return Align(
        alignment: Alignment(sqrt2 * cos(position + positionOffset + offset * index),
            sqrt2 * sin(position + positionOffset + offset * index)),
        child: FractionallySizedBox(
          child: DraggableBubble(
            data: BubbleReference(index),
            child: new GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.openDetail(index);
              },
              child: Opacity(
                opacity: isInDragMode ? 0.4 : 1,
                child: widget.highlightedParameter == null ? circle : CustomPaint(
                  foregroundPainter: ArcPainter(
                    length: data.parameterValues[widget.highlightedParameter.type],
                    color: widget.highlightedParameter.color
                  ),
                  child: circle,
                )
              )
            ),
            feedback: Material(
                child: Container(
                  decoration: circleDecoration(picture),
                  width: 70,
                  height: 70,
                  transform: Matrix4.translationValues(-35, -55, 0),
                ),
                color: Colors.transparent
            ),
//            feedbackOffset: Offset(-35, -35),
            dragAnchor: DragAnchor.pointer,
            childWhenDragging: Container(),
            startHook: (details) {
              final RenderBox box = context.findRenderObject();
              final size = box.size.width / 2;
              final startLocation = box.globalToLocal(details.globalPosition).translate(-size, -size);
              startAngle = atan2(startLocation.dy, startLocation.dx);
              _controller.stop();
              setState(() {
                isInDragMode = true;
              });
            },
            updateHook: (details) {
              final RenderBox box = context.findRenderObject();
              final size = box.size.width / 2;
              final location = box.globalToLocal(details.globalPosition).translate(-size, -size);
              final angle = atan2(location.dy, location.dx);
              final offset = angle - startAngle;
              setState(() {
                positionOffset = offset;
              });
            },
            onDragEnd: (_) {
              position += positionOffset;
              positionOffset = 0;
              stickToQuarterAngle();
              isInDragMode = false;
            },
          ),
          widthFactor: 0.5,
          heightFactor: 0.5,
        )
    );
  }

  BoxDecoration circleDecoration(NetworkImage picture) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: picture == null ? Colors.grey : null,
      image: DecorationImage(image: picture, fit: BoxFit.cover),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 7))],
    );
  }

  Widget backgroundTarget({Color color, IconData icon, bool left, String title, void Function(int) acceptor}) {
    return Align(
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: 0.25,
          heightFactor: 1,
          child: DragTarget<BubbleReference>(
            builder: (context, candidateData, rejectedData) {
              final isHovered = candidateData.length == 1;
              final primaryColor = isHovered ? Colors.white : Colors.grey.withOpacity(0.5);
              return Container(
                color: isHovered ? color : null,
                child: Row(
                    textDirection: left ? TextDirection.ltr : TextDirection.rtl,
                    children: [
                      RotatedBox(
                          quarterTurns: left ? 3 : 1,
                          child: Text(title, style: TextStyle(color: primaryColor))
                      ),
                      Icon(
                          icon,
                          color: primaryColor
                      )
                    ]
                ),
              );
            },
            onAccept: (reference) {
              acceptor(reference.index);
            },
          ),
        )
    );
  }

  void spin() {
    _animation = _controller.drive(
      Tween(
        begin: position,
        end: position + pi,
      ),
    );
    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, 1);
    _controller.animateWith(simulation);
  }

  void stickToQuarterAngle() {
    _animation = _controller.drive(
      Tween(
        begin: position,
        end: offset * ((position - pi/4)/offset).round() + pi/4,
      ),
    );
    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, 1);

    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        child: Stack(children: [
          backgroundTarget(
              title: 'Visited',
              icon: Icons.assignment_turned_in,
              color: Colors.orange,
              left: true,
              acceptor: widget.markVisited
          ),
          backgroundTarget(
              title: 'Favorite',
              icon: Icons.favorite,
              color: Colors.deepPurple,
              left: false,
              acceptor: widget.markFavorite
          ),
          for (var index=0; index<min(4, widget.bubbles.length); index ++)
            draggableCircle(
                index: index,
                context: context,
                data: widget.bubbles[index]
            ),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.2,
              heightFactor: 0.2,
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 7))]
                  ),
                  child: Center(child: Text('more...', style: TextStyle(color: Colors.white))),
                ),
                onTap: () {
                  widget.onRefresh();
                  spin();
                },
              ),
            ),
          )
        ]),
        aspectRatio: 1
    );
  }
}

class BubbleReference {
  final int index;
  BubbleReference(this.index);
}