import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:trip_ideas/bubbleScreen/BubbleData.dart';

final sampleData = {
  DestinationBubbleData(name: 'Paris', pictureUrl: 'https://static.independent.co.uk/s3fs-public/thumbnails/image/2019/08/07/08/paris.jpg?w968h681'),
  DestinationBubbleData(name: "Venice", pictureUrl: 'https://s27363.pcdn.co/wp-content/uploads/2016/07/Best-Things-to-do-in-Venice-Italy-1163x775.jpg.optimal.jpg'),
  DestinationBubbleData(name: "Rome", pictureUrl: 'https://www.thoughtco.com/thmb/GS4AiVqpE78EVPlhV8tJgRThEr0=/768x0/filters:no_upscale():max_bytes(150000):strip_icc()/the-roman-coliseum-in-the-early-morning-655490208-5abd1d0f119fa80037ef98b9.jpg'),
  DestinationBubbleData(name: "Rouen", pictureUrl: 'https://res.cloudinary.com/hzekpb1cg/image/upload/c_fill,h_410,w_800,f_auto/s3/public/prod/2019-02/Rouen.jpg'),
  DestinationBubbleData(name: "Bretagne", pictureUrl: 'https://www.tourismebretagne.com/app/uploads/crt-bretagne/2018/10/5-binic-etables-sur-mer-a-lamoureux-640x480.jpg'),
  DestinationBubbleData(name: "Oxford", pictureUrl: 'https://www.telegraph.co.uk/content/dam/education/2017/01/03/oxford-uni_trans_NvBQzQNjv4Bqox62pZtR-cGG9XPRDwknLfY3lL1NglnEUrCGcyD9d6g.jpg?imwidth=450'),
};

Future loadData() async {
  final csv = await rootBundle.loadString("assets/data/TripIdeas.csv");
  final fields = const CsvToListConverter(fieldDelimiter: ';', eol: '\n').convert(csv);
  print(fields.length);
}