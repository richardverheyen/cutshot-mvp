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

  inferVideo(String id) async {
    _db.collection('videos').doc(id).collection('highlights').add({
      "start": 1,
      "end": 2,
    });
    _db.collection('videos').doc(id).collection('highlights').add({
      "start": 3,
      "end": 4,
    });
  }

  /// Updates the current user's report document after completing quiz
  createVideo(Video video) async {
    _db
        .collection('videos')
        .add(video.toJson())
        // Then start the uploadVideo process
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

  uploadVideo(Video video) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;

    late UploadTask uploadVideoTask;

    File videoFile = File("$appDocPath/${video.videoPath}");
    File thumbnailFile = File(video.thumbnailPath);

    // Upload thumbnail but don't track progress
    StorageService()
        .storageRef
        .child("${video.id}/thumbnail")
        .putFile(thumbnailFile, SettableMetadata(contentType: "image/webp"));

    uploadVideoTask = StorageService()
        .storageRef
        .child("${video.id}/video")
        .putFile(videoFile, SettableMetadata(contentType: "video/mp4"));

    uploadVideoTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      switch (snapshot.state) {
        case TaskState.running:
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes * 100;
          _db.collection('videos').doc(video.id).update({
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
          _db.collection('videos').doc(video.id).update({
            'uploading': false,
          });
          break;
      }
    }, onError: (error) {
      print(error.toString());
    });
  }
}
