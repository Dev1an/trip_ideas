import 'package:flutter/material.dart';
import 'custom_icons.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailWidget extends StatefulWidget {
  @override
  _DetailWidgetState createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  static const int PHOTOS_AMOUNT = 5;
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
    if(calledBuild==1) photoUrls = getImageUrls("paris");

    // Image carousel
    Widget photoSection = new Container(
      child:  new Swiper(
        itemBuilder: (BuildContext context,int index){
          return FutureBuilder(
            future: photoUrls,
            builder: (context,snapshot) {
              if(snapshot.connectionState == ConnectionState.done) {
                return Image.network(snapshot.data[index]);
              } else {
                return new SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator()
                );
              }
            },
          );
           // new Image.network(urls[index],fit: BoxFit.fill);
          //return new Image.network("http://via.placeholder.com/350x150",fit: BoxFit.fill,);
        },
        itemCount: PHOTOS_AMOUNT,
        viewportFraction: 0.8,
        scale: 0.9,
        pagination: new SwiperPagination(),
        control: new SwiperControl(),
      ),
      height: 200,
    ) ;


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
                    'Paris',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'France, Europe',
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
          FavoriteWidget(favorite: _favorite,onChanged: _handleFavoriteChanged),
          VisitedWidget(visited: _visited,onChanged: _handleVisitedChanged),
        ],
      ),
    );

    // Text section
    Widget textSection = Container(
      padding: const EdgeInsets.all(32),
      child: Text(
        'Paris offers the largest concentration of tourist attractions in France, and possibly in Europe. '
        'Besides some of the world\'s most famous musuems, its has a vibrant historic city centre, a beautiful '
        'riverscape, an extensive range of historic monuments, including cathedrals, chapels and palaces, plus one of the most famous nightlife scenes in the world.'
        'Paris is also famous for its cafés and restaurants, its theatres and cinemas, and its general ambiance.',
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
  Future<List<String>> getImageUrls(String city) async{
    String exlude = "+-woman+-animal+-flower+-meal+-postcard+-door+-painting";
    int resultLimit = 40;
    String url = "https://pixabay.com/api/?key=14114941-200003d620e7a15f560cb840c";
    url += "&q="+city+exlude+"&image_type=photo&orientation=horizontal&category=travel&page=1&per_page="+resultLimit.toString();

    List<String> list =  new List();

    final response = await http.get(url);
    var data = json.decode(response.body);
    List<dynamic> hits = data['hits'];

    var randomIndices = new List<int>.generate(resultLimit, (int index) => index); // [0, 1, 4]
    randomIndices.shuffle();
    print("HITS LENGHTH");
    print(hits.length);

    for(int i=0; i<PHOTOS_AMOUNT;i++) {
      //list.add(hits[i]["webformatURL"]);
      list.add(hits[randomIndices[i]]["webformatURL"]);
    }
    return list;
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
            icon: (favorite
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border)),
            color: color,
            onPressed: _handleTap,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            favorite ? 'FAVORITE' : 'NOT FAVORITE',
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
            visited ? 'VISITED' : 'NOT VISITED',
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

