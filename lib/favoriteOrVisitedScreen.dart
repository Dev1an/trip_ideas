import 'package:flutter/material.dart';
import 'package:trip_ideas/Database.dart';
import 'package:trip_ideas/detailScreen/detail.dart';
import 'model/DestinationSimple.dart';

enum FavOrVisEnum {
  favorite,
  visited
}

class FavoriteOrVisitedList extends StatefulWidget {
  final FavOrVisEnum type;
  FavoriteOrVisitedList({Key key, @required this.type}) : super(key: key);

  @override
  createState() => FavoriteOrVisitedListState(type);
}

class FavoriteOrVisitedListState extends State<FavoriteOrVisitedList> {

  FavOrVisEnum type;

  FavoriteOrVisitedListState(FavOrVisEnum t) {
    this.type = t;
  }

  List<DestinationSimple> _favoritesOrVisiteds = new List<DestinationSimple>();

  @override
  void initState() {
    super.initState();
    _populateList();
  }

  void  _populateList() {
    _favoritesOrVisiteds = new List<DestinationSimple>();
    DatabaseHelper helper = DatabaseHelper.instance;
    if(type==FavOrVisEnum.favorite) {
      helper.queryAllFavorites().then((favorites) => setState(() {
        _favoritesOrVisiteds = favorites;
      }));
    } else {
      helper.queryAllVisited().then((visiteds) => setState(() {
        _favoritesOrVisiteds = visiteds;
      }));
    }

  }

  void _handleFavOrVisChanged(int index) {
    setState(() {
      _deleteFavOrVis(_favoritesOrVisiteds[index]);
      _favoritesOrVisiteds.removeAt(index);
      if (_favoritesOrVisiteds == null) _favoritesOrVisiteds = new List<DestinationSimple>();
    });
  }

  Card _buildItemsForListView(BuildContext context, int index) {
    return Card(
      elevation: 5.0,
      child: new InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailWidget(dest:_favoritesOrVisiteds[index].toDestination())),
          );
        },
        child: new Row(
          children: <Widget>[
          Expanded(
            child: Container(
              height: 125,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                    fit: BoxFit.fitWidth,
                    alignment: FractionalOffset.topLeft,
                    image: new NetworkImage(
                        _favoritesOrVisiteds[index].pictureURL),
                  )
              ),
              child: Padding(
                padding: new EdgeInsets.all(10.0),
                child: Stack(
                  children: <Widget>[
                    // Stroked text as border.
                    Text(
                      _favoritesOrVisiteds[index].destination,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        shadows: [
                          Shadow(blurRadius: 3, color: Colors.black),
                          Shadow(blurRadius: 7, color: Colors.black),
                        ],
                        // Solid text as fill.
                      ),
                    )
                  ],
                ),),),
          ),
          FavoriteOrVisitedWidget(index: index, type: type,onChanged: _handleFavOrVisChanged)
          ],
        ),
      ),
      margin: EdgeInsets.all(5.0)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(type==FavOrVisEnum.favorite ? 'Favorites' : 'Visited'),
        ),
        body: (_favoritesOrVisiteds == null || _favoritesOrVisiteds.isEmpty)
            ? Center(child: Text(type==FavOrVisEnum.favorite? 'No favorites yet' : 'No visited yet'))
            : ListView.builder(
                itemCount: _favoritesOrVisiteds.length,
                itemBuilder: _buildItemsForListView,
              ));
  }

  _deleteFavOrVis(DestinationSimple fv) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    if(type == FavOrVisEnum.favorite) {
      await helper.deleteFavorite(fv.id);
      print('deleted ' + fv.destination + " as favorite");
    } else {
      await helper.deleteVisited(fv.id);
      print('deleted ' + fv.destination + " as visited");
    }
  }
}

class FavoriteOrVisitedWidget extends StatelessWidget {
  FavoriteOrVisitedWidget({Key key, this.index, @required this.type,@required this.onChanged})
      : super(key: key);

  final FavOrVisEnum type;
  final int index;
  final ValueChanged<int> onChanged;

  void _handleTap() {
    onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.close),
      color: Colors.black38,
      onPressed: _handleTap,
    );
  }
}
