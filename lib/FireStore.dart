import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_ideas/configScreen.dart';

final databaseReference = Firestore.instance;

const String MSG_MORE_BUTTON = "More button clicked";
const String MSG_MARK_FAVORITE_HOME = "Marked dest as favorite in home screen";
const String MSG_MARK_VISITED_HOME = "Marked dest as visited in home screen";
const String MSG_MARK_FAVORITE_DETAIL = "Marked dest as favorite in detail screen";
const String MSG_MARK_VISITED_DETAIL = "Marked dest as visited in detail screen";
const String MSG_NAVIGATE_TO_HOME = "Navigated to home screen";
const String MSG_NAVIGATE_TO_DETAIL = "Navigated to detail screen";
const String MSG_NAVIGATE_TO_FAVORITES = "Navigated to favorites";
const String MSG_NAVIGATE_TO_VISITED = "Navigated to visited";
const String MSG_TIME_ON_DETAIL = "Stayed on detail screen for (seconds) ";
const String MSG_TIME_ON_HOME = "Stayed on home screen for (seconds) ";

Future<DocumentReference> logAction(String message, String screen) async {
  return databaseReference.collection("log").add({ //key is timestamp
    'user': ConfigState.userID,
    'event': message,
    'screen': screen,
    'time': Timestamp.now()
  });
}

Future<DocumentReference> logActionData(String event, Map<String, dynamic> data) async {
  return databaseReference.collection("log").add({ //key is timestamp
    'event': event,
    'data': data,
    'time': Timestamp.now()
  });
}

void getAllLogs() async {
  QuerySnapshot querySnapshot = await databaseReference.collection("log").getDocuments();
  var list = querySnapshot.documents;
  list.forEach((doc) => print(doc.data));
}