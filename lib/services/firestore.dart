import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:rxdart/rxdart.dart';
import 'package:cutshot/services/services.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reads all documments from the topics collection
  Future<List<Video>> getVideos() async {
    var ref = _db.collection('videos');
    var snapshot = await ref.get();
    var data = snapshot.docs.map((s) => s.data());
    var videos = data.map((d) => Video.fromJson(d));
    return videos.toList();
  }

  /// Updates the current user's report document after completing quiz
  Future<void> createVideo(dynamic data) async {
    CollectionReference videos =
        FirebaseFirestore.instance.collection('videos');

    videos
        .add(data)
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
