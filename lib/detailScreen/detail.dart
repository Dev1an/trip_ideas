import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:geolocator/geolocator.dart';

import '../model/Destination.dart';
import '../detailScreen/DetailCacheUtil.dart';
import '../detailScreen/FavoriteWidget.dart';
import '../detailScreen/VisitedWidget.dart';
import '../favoriteOrVisitedScreen.dart';
import 'custom_icons.dart';



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
      if(_favorite) addFavorite(currentDestination);
      else deleteFavorite(currentDestination);
    });
  }

  // Handling visited toggle
  bool _visited = false;
  void _handleVisitedChanged(bool newValue) {
    setState(() {
      _visited = newValue;
      if(_visited) addVisited(currentDestination);
      else deleteVisited(currentDestination);
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

  // Helper method to retrieve the distance between the current location and the destination location
  Future<String> getDistance() async {
    String distanceString = "";
    Position _currentPosition;
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
    
    final TextEditingController _startCoordinatesTextController =
      currentDestination.location;
    final List<String> endCoords =
        _startCoordinatesTextController.text.split(':');
    
    final double startLatitude = _currentPosition.latitude;
    final double startLongitude = _currentPosition.longitude;
    final double endLatitude = double.parse(endCoords[0]);
    final double endLongitude = double.parse(endCoords[1]);
    final double distance = await Geolocator().distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    
    distanceString = "$distance km";
    return distanceString;
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

    getDetailsOfDestination(currentDestID).then((destination) =>
        checkIfFavorite(destination).then((isFavorite) =>
            checkIfVisited(destination).then((isVisited) =>
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


  void _getRecommendationsDEBUG() async {

    var url = "http://localhost:5000/recommendations/";
    var resp = await http.post(url, body: {'preferences':'[70, 90, 20, 0, 5]','removed':'[1,2,3]'});
    //print('Response status: ${resp.statusCode}');
    print('Response body: ${resp.body}');

  }

}
