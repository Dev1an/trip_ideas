import 'package:cloud_firestore/cloud_firestore.dart';

final databaseReference = Firestore.instance;

void logAction(String user, String action, String screen) async {
  String timeNow = new DateTime.now().toIso8601String();
  await databaseReference.collection("log")
      .document(timeNow).setData({ //key is timestamp
    'user': user,
    'action': action,
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