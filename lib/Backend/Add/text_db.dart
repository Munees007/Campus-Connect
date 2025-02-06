import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class Textdb {
  void setName() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("users").doc("2").set({
      'name': "Munees",
      'email': "muneesm458mail.com",
    });

    log("data stored successfully in db");
  }
}
