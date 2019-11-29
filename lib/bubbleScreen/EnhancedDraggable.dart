import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

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
