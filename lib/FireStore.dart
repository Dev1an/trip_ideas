import 'package:cloud_firestore/cloud_firestore.dart';

final databaseReference = Firestore.instance;

const String MSG_MORE_BUTTON = "More button clicked";
const String MSG_MARK_FAVORITE_HOME = "Marked dest as favorite in homescreen";
const String MSG_MARK_VISITED_HOME = "Marked dest as visited in homescreen";
const String MSG_MARK_FAVORITE_DETAIL = "Marked dest as favorite in detailscreen";
const String MSG_MARK_VISITED_DETAIL = "Marked dest as visited in detailscreen";
const String MSG_NAVIGATE_TO_HOME = "Navigated to homescreen";
const String MSG_NAVIGATE_TO_DETAIL = "Navigated to detailscreen";
const String MSG_NAVIGATE_TO_FAVORITES = "Navigated to favorites";
const String MSG_NAVIGATE_TO_VISITED = "Navigated to visited";

void logAction(String user, String message, String screen) async {
  String timeNow = new DateTime.now().toIso8601String();
  await databaseReference.collection("log")
      .document(timeNow).setData({ //key is timestamp
    'user': user,
    'message': message,
    'screen': screen,
    'time': new DateTime.now().toIso8601String()
  });
  //print(ref.documentID);
}

void getAllLogs() async {
  QuerySnapshot querySnapshot = await databaseReference.collection("log").getDocuments();
  var list = querySnapshot.documents;
  list.forEach((doc) => print(doc.data));
}