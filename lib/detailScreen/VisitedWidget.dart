import 'package:flutter/material.dart';

/// Toggle widget for Visited
class VisitedWidget extends StatelessWidget {
  VisitedWidget({Key key, this.visited: false, @required this.onChanged})
      : super(key: key);

  final bool visited;
  final ValueChanged<bool> onChanged;

  void _handleTap() {
    onChanged(!visited);
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 0),
          padding: EdgeInsets.all(0),
          child: IconButton(
            icon: (visited
                ? Icon(Icons.check_box)
                : Icon(Icons.check_box_outline_blank)),
            color: color,
            onPressed: _handleTap,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            'VISITED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}