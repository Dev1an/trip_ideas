import 'dart:io';

import 'package:flutter/material.dart';
import 'favoriteOrVisited.dart';
import 'custom_icons.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helpers.dart';

const bool LOCALHOST  = true; // Use localhost or Heroku for details lookup

class DetailWidget extends StatefulWidget {
  final int destID;
  DetailWidget({Key key, @required this.destID}) : super(key: key);

  @override
  _DetailWidgetState createState() => _DetailWidgetState(destID);
}

class _DetailWidgetState extends State<DetailWidget> {
  static const int PHOTOS_AMOUNT = 5;
  int currentDestID;

  _DetailWidgetState(int destID) {
    this.currentDestID = destID;
  }

  Destination currentDestination = new Destination();

  @override
  void initState() {
    super.initState();
    //_initializeDestinationDB();
    _loadDetailsOfCurrent();
  }

  // Handling favorite toggle
  bool _favorite = false;
  void _handleFavoriteChanged(bool newValue) {
    setState(() {
      _favorite = newValue;
      if(_favorite) _addFavorite(currentDestination);
      else _deleteFavorite(currentDestination);
    });
  }

  // Handling visited toggle
  bool _visited = false;
  void _handleVisitedChanged(bool newValue) {
    setState(() {
      _visited = newValue;
      if(_visited) _addVisited(currentDestination);
      else _deleteVisited(currentDestination);
    });
  }

  Future<List<String>> photoUrls;
  int calledBuild = 0;

  // The DETAIL build method
  @override
  Widget build(BuildContext context) {
    calledBuild++;
    if (calledBuild == 2 && currentDestination !=null &&currentDestination.destination!="")
      // Only called once (i.e. not when FavoriteWidget invokes setState)
      photoUrls = getImageUrls(currentDestination.destination);

    // Image carousel
    Widget photoSection = new Container(
      child: new Swiper(
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: photoUrls,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Image.network(snapshot.data[index]);
              } else {
                return new Container(
                    child: new Center(
                      child: new SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator()),
                ));
              }
            },
          );
        },
        itemCount: PHOTOS_AMOUNT,
        viewportFraction: 0.8,
        scale: 0.9,
        pagination: new SwiperPagination(),
        control: new SwiperControl(),
      ),
      height: 200,
    );

    // Title row
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    currentDestination.destination,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  currentDestination.country,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          Icon(
            Icons.near_me,
            color: Colors.grey[500],
          ),
          Text('321km'),
        ],
      ),
    );

    // Button row
    Color color = Theme.of(context).primaryColor;
    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.map, 'Location'),
          FavoriteWidget(
              favorite: _favorite, onChanged: _handleFavoriteChanged),
          VisitedWidget(visited: _visited, onChanged: _handleVisitedChanged),
        ],
      ),
    );

    // Text section
    Widget textSection = Container(
      padding: const EdgeInsets.all(32),
      child: Text(
        currentDestination.description,
        softWrap: true,
      ),
    );

    // Characteristics section
    Widget characteristicsSection = Row(
      //Creates even space between each item and their parent container
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildCharacteristicContainer(CustomIcons.theater, "Theaters", Color(0xffD2E0E1)),
        _buildCharacteristicContainer(CustomIcons.sport, "Sports", Color(0xffFEF1D0)),
        _buildCharacteristicContainer(CustomIcons.park, "Parks", Color(0xffE3F579)),
        _buildCharacteristicContainer(Icons.account_balance, "Musea", Color(0xffF4C2C2))
      ],
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("Detail view"),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.assignment_turned_in),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteOrVisitedList(type: FavOrVisEnum.visited)),
                ).then((e) => {_loadDetailsOfCurrent()}); // Refresh on back
              },
            ),
            new IconButton(
              icon: new Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteOrVisitedList(type: FavOrVisEnum.favorite)),
                ).then((e) => {_loadDetailsOfCurrent()}); // Refresh on back
              },
            ),
            new IconButton(
              icon: new Icon(Icons.account_circle),
              onPressed: () {},
            )
          ],
        ),
        body: ListView(
          children: [
            photoSection,
            titleSection,
            buttonSection,
            textSection,
            characteristicsSection,
            SizedBox(height: 10)
          ],
        ));
  }

  //=============== HELPER METHODS ===================

  Container _buildCharacteristicContainer(IconData icon, String text, Color color) {
    return Container(
        width: 80.0,
        height: 80.0,
        decoration: new BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Icon(icon,color: Colors.black45,),
                Text(text,style:TextStyle(color: Colors.black45)),
                Text('5',style: TextStyle(color: Colors.black45, fontSize: 18),)],
        )
    );
  }

  // Helper method to create columns
  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 0),
          padding: EdgeInsets.all(0),
          child: IconButton(
            icon: Icon(icon),
            color: color,
            onPressed: null,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
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

  // Helper method to retrieve images
  Future<List<String>> getImageUrls(String city) async {
    String exlude = "+-woman+-animal+-flower+-meal+-postcard+-door+-painting";
    int resultLimit = 40;
    String url =
        "https://pixabay.com/api/?key=14114941-200003d620e7a15f560cb840c";
    url += "&q=" +
        city +
        exlude +
        "&image_type=photo&orientation=horizontal&category=travel&page=1&per_page=" +
        resultLimit.toString();

    List<String> list = new List();

    final response = await http.get(url);
    var data = json.decode(response.body);
    List<dynamic> hits = data['hits'];

    var randomIndices =
        new List<int>.generate(resultLimit, (int index) => index); // [0, 1, 4]
    randomIndices.shuffle();

    for (int i = 0; i < PHOTOS_AMOUNT; i++) {
      //list.add(hits[i]["webformatURL"]);
      list.add(hits[randomIndices[i]]["webformatURL"]);
    }
    return list;
  }

  // Helper method to read from database
  Future<Destination> _readDestinationFromCache(int destID) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    Destination dest = await helper.queryDestination(destID);
    if (dest == null) {
      print('read row $destID: empty');
      return null;
    } else {
      print('read row $destID: ${dest.destination} ${dest.country}');
      return dest;
    }
  }

  _addDestinationToCache(Destination dest) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.insertDestination(dest);
    print('inserted '+dest.destination+' in cache');
  }

  _addFavorite(Destination dest) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    FavoriteOrVisited fv = new FavoriteOrVisited();
    fv.id = dest.id;
    fv.destination = dest.destination;
    fv.country = dest.country;
    await helper.insertFavorite(fv);
    print('inserted '+dest.destination+' as favorite');
  }

  _addVisited(Destination dest) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    FavoriteOrVisited fv = new FavoriteOrVisited();
    fv.id = dest.id;
    fv.destination = dest.destination;
    fv.country = dest.country;
    int id = await helper.insertVisited(fv);
    print('inserted visited row: $id');
  }

  _deleteFavorite(Destination dest) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.deleteFavorite(dest.id);
    print('deleted '+dest.destination+" as favorite");
  }

  _deleteVisited(Destination dest) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.deleteVisited(dest.id);
    print('deleted '+dest.destination+" as visited");
  }

  Future<bool> _checkIfFavorite(Destination dest) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    bool exists = await helper.checkIfExistsFavorite(dest.id);
    print(exists ? dest.destination+" is favorite": dest.destination+" is not favorite");

    return exists;
  }

  _initializeDestinationDB() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    Destination dest = new Destination();
    dest.destination = "Paris";
    dest.country = "France";
    dest.location = "48.8566° N, 2.3522° E";
    dest.description = "Paris offers the largest concentration of tourist attractions in France, and possibly in Europe."+
                      "Besides some of the world\'s most famous musuems, its has a vibrant historic city centre, a beautiful "+
                      "riverscape, an extensive range of historic monuments, including cathedrals, chapels and palaces, plus "+
                      "one of the most famous nightlife scenes in the world. Paris is also famous for its cafés and "+
                      "restaurants, its theatres and cinemas, and its general ambiance.";
    await helper.insertDestination(dest);
    dest = new Destination();
    dest.destination = "Barcelona";
    dest.location = "41.3851° N, 2.1734° E";
    dest.country = "Spain";
    dest.description = "Barcelona is a city of contrasts: it's Catalan and Spanish, traditional "+
                        "and modern, and exciting and laid-back, all at the same time. But it's "+
                        "this perfect harmony that makes Spain's second-largest city fascinating "+
                        "enough to draw around 32 million tourists every year. As one of Europe's "+
                        "chicest cities, home to no shortage of things to see and do, it's important "+
                        "to make every second count while in Barcelona.";
    await helper.insertDestination(dest);
  }

  _loadDetailsOfCurrent() {
    // set dummy values of placeholder destination
    currentDestination.destination="";
    currentDestination.description="";
    currentDestination.location="";
    currentDestination.country="";

    /*
    _readDestination(currentDestID).then((destination) =>
        _checkIfFavorite(destination).then((exists) =>
            setState(() {
              currentDestination = destination;
              _favorite = exists;
            })));

     */
    _getDetailsOfDestination(currentDestID).then((destination) =>
        _checkIfFavorite(destination).then((exists) =>
            setState(() {
              currentDestination = destination;
              _favorite = exists;
            })
        )
    );

    //_getRecommendationsDEBUG();
  }

  Future<Destination> _getDetailsOfDestination(int destID) async {
    // CHECK IF AVAILABLE IN CACHE
    DatabaseHelper helper = DatabaseHelper.instance;
    bool exists = await helper.checkIfExistsDestination(destID);
    if (exists) return _readDestinationFromCache(destID);

    // NOT IN CACHE
    Destination destination = new Destination();
    // URL
    String host;
    if(LOCALHOST) host="localhost:5000";
    else host="http://tripideas.heroku.com/";
    String url = 'http://'+host+'/destination/?id='+destID.toString();
    // GET REQUEST
    var response = await http.get(url);  // sample info available in response

    // PARSE RESPONSE
    int statusCode = response.statusCode;
    if(statusCode == HttpStatus.ok) {
      var data = json.decode(response.body);
      print(data);
      var raw_destination = data['MESSAGE'];
      destination =  new Destination();
      destination.id = destID;
      destination.country = raw_destination['country'];
      destination.destination = raw_destination['destination'];
      destination.description = raw_destination['description'];
      destination.location = raw_destination['location'];

      // ADD TO CACHE
      _addDestinationToCache(destination);

      return destination;
    } else {
      // ?
    }

    return destination;
  }

  void _getRecommendationsDEBUG() async {

    var url = "http://localhost:5000/recommendations/";
    var resp = await http.post(url, body: {'parks':'as much as possible','theaters':'none'});
    //print('Response status: ${resp.statusCode}');
    print('Response body: ${resp.body}');

  }

}

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

