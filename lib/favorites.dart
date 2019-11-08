import 'package:flutter/material.dart';
import 'package:trip_ideas/database_helpers.dart';
import 'package:trip_ideas/detail.dart';

class FavoritesList extends StatefulWidget {
  @override
  createState() => FavoritesListState();
}

class FavoritesListState extends State<FavoritesList> {
  List<FavoriteOrVisited> _favorites = new List<FavoriteOrVisited>();

  @override
  void initState() {
    super.initState();
    _populateFavorites();
  }

  void _populateFavorites() {
    _favorites = new List<FavoriteOrVisited>();
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.queryAllFavorites().then((favorites) => setState(() {
          _favorites = favorites;
        }));
  }

  void _handleFavoriteChanged(int index) {
    setState(() {
      _deleteFavorite(_favorites[index]);
      _favorites.removeAt(index);
      if (_favorites == null) _favorites = new List<FavoriteOrVisited>();
    });
  }

  Card _buildItemsForListView(BuildContext context, int index) {
    return Card(
        child: ListTile(
          title:
              Text(_favorites[index].destination, style: TextStyle(fontSize: 20)),
          subtitle: Text(_favorites[index].country.toString(),
              style: TextStyle(fontSize: 18)),
          trailing: FavoriteWidget(index: index, onChanged: _handleFavoriteChanged),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailWidget(destID: _favorites[index].id)),
            );
          },
        ),
      margin: EdgeInsets.all(10.0)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Favorites'),
        ),
        body: (_favorites == null || _favorites.isEmpty)
            ? Center(child: Text('No favorites yet'))
            : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: _buildItemsForListView,
              ));
  }

  _deleteFavorite(FavoriteOrVisited fv) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.deleteFavorite(fv.id);
    print('deleted ' + fv.destination + " as favorite");
  }
}

class FavoriteWidget extends StatelessWidget {
  FavoriteWidget({Key key, this.index, @required this.onChanged})
      : super(key: key);

  final int index;
  final ValueChanged<int> onChanged;

  void _handleTap() {
    onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return IconButton(
      icon: Icon(Icons.favorite),
      color: color,
      onPressed: _handleTap,
    );
  }
}
