import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';
import 'storage.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Video>> streamVideoList() {
    return _db
        .collection('videos')
        .orderBy('createdDate', descending: false)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((doc) => Video.fromJson(doc.id, doc.data()))
            .toList());
  }

  /// Updates the current user's report document after completing quiz
  Future<void> createVideo(Video video) async {
    CollectionReference videos = _db.collection('videos');

    videos
        .add(video.toJson())
        .then((data) => _db
            .collection('videos')
            .doc(data.id)
            .withConverter(
              fromFirestore: (snapshot, _) =>
                  Video.fromJson(snapshot.id, snapshot.data()!),
              toFirestore: (Video video, _) => video.toJson(),
            )
            .get())
        .then((doc) => doc.data())
        .then((newVideo) => uploadVideo(newVideo as Video))
        .then((_) => print("Video uploaded!"))
        .catchError((error) => print("Failed to add video: $error"));
  }

  Future<void> uploadVideo(Video video) async {
    // print("Upload teh video!");

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;

    late UploadTask uploadVideoTask;

    CollectionReference videos = _db.collection('videos');

    final videoRef = StorageService().storageRef.child("${video.id}/video");
    final thumbnailRef =
        StorageService().storageRef.child("${video.id}/thumbnail");

    File videoFile = File("$appDocPath/${video.path}");
    File thumbnailFile = File(video.thumbnail);

    // Upload thumbnail but don't track progress
    thumbnailRef.putFile(
        thumbnailFile, SettableMetadata(contentType: "image/webp"));
    uploadVideoTask =
        videoRef.putFile(videoFile, SettableMetadata(contentType: "video/mp4"));

    uploadVideoTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      switch (snapshot.state) {
        case TaskState.running:
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes * 100;
          videos.doc(video.id).update({
            'uploading': true,
            'uploadProgress': progress,
          });
          break;

        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          break;

        case TaskState.success:
          videos.doc(video.id).update({
            'uploading': false,
          });
          break;
      }
    }, onError: (error) {
      print(error.toString());
    });
  }
}
