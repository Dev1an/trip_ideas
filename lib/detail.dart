import 'package:flutter/material.dart';
import 'custom_icons.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helpers.dart';

class DetailWidget extends StatefulWidget {
  @override
  _DetailWidgetState createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  static const int PHOTOS_AMOUNT = 5;
  int currentDestID = 1;
  Destination currentDestination = new Destination();

  @override
  void initState() {
    super.initState();
    _initializeDestinationDB();
    _loadDetailsOfCurrent();
  }

  // Handling favorite toggle
  bool _favorite = false;
  void _handleFavoriteChanged(bool newValue) {
    setState(() {
      _favorite = newValue;
    });
  }

  // Handling visited toggle
  bool _visited = false;
  void _handleVisitedChanged(bool newValue) {
    setState(() {
      _visited = newValue;
    });
  }

  Future<List<String>> photoUrls;
  int calledBuild = 0;

  // The DETAIL build method
  @override
  Widget build(BuildContext context) {
    calledBuild++;
    if (calledBuild == 2 && currentDestination.destination!="") photoUrls = getImageUrls(currentDestination.destination);

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
            Icons.map,
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
          _buildButtonColumn(color, Icons.near_me, 'ROUTE'),
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
    Widget characteristicsSection = ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          leading: Icon(CustomIcons.park),
          title: Text('Nature & parks'),
        ),
        ListTile(
          leading: Icon(CustomIcons.theater),
          title: Text('Theaters'),
        ),
        ListTile(
          leading: Icon(CustomIcons.sport),
          title: Text('Sport'),
        ),
      ],
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("Detail view"),
        ),
        body: ListView(
          children: [
            photoSection,
            titleSection,
            buttonSection,
            textSection,
            characteristicsSection
          ],
        ));
  }

  //=============== HELPER METHODS ===================

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
  Future<Destination> _readDestination(int destID) async {
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

  _addFavorite(FavoriteOrVisited fv) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insertFavorite(fv);
    print('inserted row: $id');
  }

  _addVisited(FavoriteOrVisited fv) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insertVisited(fv);
    print('inserted row: $id');
  }

  _deleteFavorite(FavoriteOrVisited fv) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.deleteFavorite(fv.id);
  }

  _deleteVisited(FavoriteOrVisited fv) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.deleteVisited(fv.id);
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

    _readDestination(currentDestID).then((destination) =>
      setState(() {
        currentDestination = destination;}
      )
    );
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

