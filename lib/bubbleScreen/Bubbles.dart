import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:trip_ideas/model/Destination.dart';
import 'ArcPainter.dart';
import 'BubbleScreen.dart';

class Circles extends StatefulWidget {
  final List<Destination> bubbles;
  final void Function(int) markFavorite;
  final void Function(int) markVisited;
  final void Function(int) openDetail;
  final void Function() onRefresh;

  const Circles({Key key, this.bubbles, this.markFavorite, this.markVisited, this.openDetail, this.onRefresh}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CirclesState(
      bubbles: bubbles,
      markFavorite: markFavorite,
      markVisited: markVisited,
      openDetail: openDetail,
      onRefresh: onRefresh
  );
}

class ProxyDrag extends Drag {
  final Drag proxy;
  final void Function(DragUpdateDetails) updateHook;
  final void Function(DragUpdateDetails) startHook;
  ProxyDrag({this.proxy, this.updateHook, this.startHook}) : super();
  bool inProgress = false;

  void update(DragUpdateDetails details) {
    if (inProgress == false) {
      startHook(details);
      inProgress = true;
    } else {
      updateHook(details);
    }
    proxy.update(details);
  }

  void end(DragEndDetails details) {
    proxy.end(details);
  }

  void cancel() {proxy.cancel();}
}
class DraggableBubble<T> extends Draggable<T> {
  final void Function(DragUpdateDetails) updateHook;
  final void Function(DragUpdateDetails) startHook;

  @override
  MultiDragGestureRecognizer<MultiDragPointerState> createRecognizer(GestureMultiDragStartCallback onStart) {
    return ImmediateMultiDragGestureRecognizer()..onStart = (offset) {
      return ProxyDrag(
          proxy: onStart(offset),
          updateHook: updateHook,
          startHook: startHook
      );
    };
  }

  DraggableBubble({
    Key key,
    @required Widget child,
    @required Widget feedback,
    this.updateHook,
    this.startHook,
    T data,
    Axis axis,
    Widget childWhenDragging,
    Offset feedbackOffset = Offset.zero,
    DragAnchor dragAnchor = DragAnchor.child,
    int maxSimultaneousDrags,
    VoidCallback onDragStarted,
    DraggableCanceledCallback onDraggableCanceled,
    DragEndCallback onDragEnd,
    VoidCallback onDragCompleted,
    bool ignoringFeedbackSemantics = true,
  }) : super(
    key: key,
    child: child,
    feedback: feedback,
    data: data,
    axis: axis,
    childWhenDragging: childWhenDragging,
    feedbackOffset: feedbackOffset,
    dragAnchor: dragAnchor,
    maxSimultaneousDrags: maxSimultaneousDrags,
    onDragStarted: onDragStarted,
    onDraggableCanceled: onDraggableCanceled,
    onDragEnd: onDragEnd,
    onDragCompleted: onDragCompleted,
    ignoringFeedbackSemantics: ignoringFeedbackSemantics,
  );
}

class CirclesState extends State<Circles> with SingleTickerProviderStateMixin {
  static final double offset = pi/2;
  double position = pi/4;
  double positionOffset = 0;
  double startAngle;

  final List<Destination> bubbles;
  final void Function(int) markFavorite;
  final void Function(int) markVisited;
  final void Function(int) openDetail;
  final void Function() onRefresh;
  CirclesState({this.bubbles, this.markFavorite, this.markVisited, this.openDetail, this.onRefresh});

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

  Align circle({int index, BuildContext context, Destination data}) {
    int score = 0;
    Color scoreColor = Colors.orange;
    switch (BubbleScreenState.radioValue1) {
      case "Beach":     score = data.scoreBeach; scoreColor = Colors.lightBlueAccent; break;
      case "Nature":    score = data.scoreNature; scoreColor = Colors.lightGreen;  break;
      case "Culture":   score = data.scoreCulture; scoreColor = Colors.yellow; break;
      case "Shopping":  score = data.scoreShopping; scoreColor = Colors.purple; break;
      case "Nightlife": score = data.scoreNightlife; scoreColor = Colors.pink; break;
    }

    final NetworkImage picture = NetworkImage(data.pictureURL);

    return Align(
        alignment: Alignment(sqrt2 * cos(position + positionOffset + offset * index),
            sqrt2 * sin(position + positionOffset + offset * index)),
        child: FractionallySizedBox(
          child: DraggableBubble(
            data: BubbleReference(index),
            child:
            new GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  openDetail(index);
                },
                child: CustomPaint(
                  foregroundPainter: ArcPainter(score/100),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                      image: DecorationImage(image: picture, fit: BoxFit.cover),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 7))]
                    ),
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
                  ),
                )
            ),
            feedback: Material(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.7),
                    image: DecorationImage(image: picture, fit: BoxFit.cover)
                  ),
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
            },
          ),
          widthFactor: 0.5,
          heightFactor: 0.5,
        )
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
              color: Colors.red,
              left: true,
              acceptor: markVisited
          ),
          backgroundTarget(
              title: 'Favorite',
              icon: Icons.favorite,
              color: Colors.green,
              left: false,
              acceptor: markFavorite
          ),
          for (var index=0; index<min(4, bubbles.length); index ++)
            circle(
                index: index,
                context: context,
                data: bubbles[index]
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
                  onRefresh();
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