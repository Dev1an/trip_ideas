import 'package:cloud_firestore/cloud_firestore.dart';

final databaseReference = Firestore.instance;

void logAction(String user, String action, String screen) async {
  await databaseReference.collection("log")
      .add({
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