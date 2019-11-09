import 'package:flutter/material.dart';

/// Toggle widget for Favorite
class FavoriteWidget extends StatelessWidget {
  FavoriteWidget({Key key, this.favorite: false, @required this.onChanged})
      : super(key: key);

  final bool favorite;
  final ValueChanged<bool> onChanged;

  void _handleTap() {
    onChanged(!favorite);
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
            icon:
            (favorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border)),
            color: color,
            onPressed: _handleTap,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            'FAVORITE',
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