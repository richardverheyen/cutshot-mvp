import 'dart:io';

import 'package:cutshot/services/services.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final storageRef = FirebaseStorage.instance.ref();

  // Stores the video data in firebase storage
  Future<void> storeVideo(Video video) async {
    // Create a storage reference from our app

    final videoRef = storageRef.child("${video.id}/video");
    File videoFile = File(video.videoPath);

    final thumbnailRef = storageRef.child("${video.id}/thumbnail");
    File thumbnailFile = File(video.thumbnailPath);

    try {
      print("uploading video...");
      await videoRef.putFile(videoFile);

      print("uploading thumbnail...");
      await thumbnailRef.putFile(thumbnailFile);
      print('done');
    } on FirebaseException catch (e) {
      print("Error: $e");
    }
  }

  Future<String> getThumbnailUrl(Video video) async {
    final thumbnailRef = storageRef.child('${video.id}/thumbnail');

    try {
      final url = await thumbnailRef.getDownloadURL();
      video.thumbnailPath = url;
    } on FirebaseException catch (e) {
      print("Error: $e");
    }

    return video.thumbnailPath;
  }
}
