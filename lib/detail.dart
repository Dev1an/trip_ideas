import 'dart:io';

import 'package:flutter/material.dart';
import 'favoriteOrVisited.dart';
import 'custom_icons.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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
  static const int PHOTOS_AMOUNT = 2;
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

  //Future<List<String>> photoUrls;
  List<String> photoUrls = ["",""];
  int calledBuild = 0;

  // The DETAIL build method
  @override
  Widget build(BuildContext context) {
    calledBuild++;
    if (calledBuild == 3 && currentDestination !=null &&currentDestination.destination!="")
      // Only called once (i.e. not when FavoriteWidget invokes setState)
      //photoUrls = getImageUrls(currentDestination.destination);
      photoUrls = json.decode(currentDestination.otherImagesJSON).cast<String>().toList();

    // Image carousel
    Widget photoSection = new Container(
      child: new Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Image.network(photoUrls.elementAt(index));
         /* return FutureBuilder(
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
          );*/
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
        _buildCharacteristicContainer(Icons.beach_access, "Beach", Color(0xff81D4FA),currentDestination.scoreBeach),
        _buildCharacteristicContainer(CustomIcons.forrest, "Nature", Color(0xffA5D6A7),currentDestination.scoreNature),
        _buildCharacteristicContainer(CustomIcons.theater, "Culture", Color(0xffFFEB3B),currentDestination.scoreCulture),
        _buildCharacteristicContainer(CustomIcons.shopping, "Shopping", Color(0xffFFB74D),currentDestination.scoreShopping),
        _buildCharacteristicContainer(CustomIcons.party, "Nightlife", Color(0xffCE93D8),currentDestination.scoreNightlife),
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

  CircularPercentIndicator _buildCharacteristicContainer(IconData icon, String text, Color color, int score) {
    double percent = (score.toDouble() / 100);
    return CircularPercentIndicator(
      radius: 60.0,
      lineWidth: 3.0,
      percent: percent,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[Icon(icon,color: Colors.black45,),
          Text(text,style:TextStyle(fontSize: 10.0, color: Colors.black45))],
      ),
      backgroundColor: Colors.white12,
      progressColor: color,
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
    Destination dest = await helper.readDestination(destID);
    if (dest == null) {
      print('read row $destID: empty');
      return null;
    } else {
      print('found in cache: $destID: ${dest.destination} ${dest.country} ${dest.otherImagesJSON} ');
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
    DestinationSimple fv = new DestinationSimple();
    fv.id = dest.id;
    fv.destination = dest.destination;
    fv.country = dest.country;
    await helper.insertFavorite(fv);
    print('inserted '+dest.destination+' as favorite');
  }

  _addVisited(Destination dest) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    DestinationSimple fv = new DestinationSimple();
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

  Future<bool> _checkIfVisited(Destination dest) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    bool exists = await helper.checkIfExistsVisited(dest.id);
    print(exists ? dest.destination+" is visited": dest.destination+" is not visited");

    return exists;
  }


  _loadDetailsOfCurrent() {
    // set dummy values of placeholder destination
    currentDestination.destination="";
    currentDestination.description="";
    currentDestination.location="";
    currentDestination.country="";
    currentDestination.otherImagesJSON = "";
    currentDestination.scoreBeach = 0;
    currentDestination.scoreNature = 0;
    currentDestination.scoreCulture = 0;
    currentDestination.scoreShopping = 0;
    currentDestination.scoreNightlife = 0;

    _getDetailsOfDestination(currentDestID).then((destination) =>
        _checkIfFavorite(destination).then((isFavorite) =>
            _checkIfVisited(destination).then((isVisited) =>
                setState(() {
                  currentDestination = destination;
                  _favorite = isFavorite;
                  _visited = isVisited;
                })
            )

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
      var raw_destination = data[0];
      destination =  new Destination();
      destination.id = destID;
      destination.country = raw_destination['Country'];
      destination.destination = raw_destination['Destination'];
      destination.description = raw_destination['Description'];
      destination.location = raw_destination['Location'];
      String images = raw_destination['Other images'];
      List<String> imagesList = images.substring(1,images.length-1).split("1");
      imagesList.add(raw_destination['Front image']);
      destination.otherImagesJSON = jsonEncode(imagesList);
      destination.scoreBeach = raw_destination['Beach score'];
      destination.scoreNature = raw_destination['Nature score'];
      destination.scoreCulture = raw_destination['Culture score'];
      destination.scoreShopping = raw_destination['Shopping score'];
      destination.scoreNightlife = raw_destination['Nightlife score'];
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
    var resp = await http.post(url, body: {'preferences':'[70, 90, 20, 0, 5, 0, 0, 10]','removed':'[1,2,3]'});
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

