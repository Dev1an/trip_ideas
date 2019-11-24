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
      child: new Row(
        children: <Widget>[
        Container(
          height: 175,
          width: 300,
          decoration: new BoxDecoration(
              image: new DecorationImage(
                fit: BoxFit.fitHeight,
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
          ),)
            ],
      ),),),
    /*Container(
              width: 250,
              height: 200,
              child: Stack(
              children: <Widget>[
                new Image.network(
                  _favoritesOrVisiteds[index].pictureURL, fit: BoxFit.cover),
                new FittedBox(
                  child: Text(
                    _favoritesOrVisiteds[index].destination, softWrap: true,
                    style: TextStyle(
                        color: Colors.white),),
                  fit: BoxFit.fitWidth,),
              ],
            )),*/
        FavoriteOrVisitedWidget(index: index, type: type,onChanged: _handleFavOrVisChanged)
      ],
    ),
    /*
        child: ListTile(
          title:
              Text(_favoritesOrVisiteds[index].destination, style: TextStyle(fontSize: 20)),
          subtitle: Text(_favoritesOrVisiteds[index].country.toString(),
              style: TextStyle(fontSize: 18)),
          trailing: FavoriteOrVisitedWidget(index: index, type: type,onChanged: _handleFavOrVisChanged),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailWidget(destID:_favoritesOrVisiteds[index].id)),
            );
          },
        ),*/
      margin: EdgeInsets.all(10.0)
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
    Color color = Theme.of(context).primaryColor;
    return IconButton(
      icon: Icon(type==FavOrVisEnum.favorite ? Icons.favorite : Icons.check_box),
      color: color,
      onPressed: _handleTap,
    );
  }
}
