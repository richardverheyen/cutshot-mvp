import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Updates the current user's report document after completing quiz
  Future<void> createVideo(dynamic data) async {
    CollectionReference videos =
        FirebaseFirestore.instance.collection('videos');

    videos
        .add(data)
        .then((value) => print("Video Added"))
        .catchError((error) => print("Failed to add video: $error"));
  }
}
