import 'dart:io';

import 'package:cutshot/services/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  final storage = FirebaseStorage.instance;

  // Stores the video data in firebase storage
  Future<void> storeVideo(Video video) async {
    // Create a storage reference from our app
    final storageRef = storage.ref();

    final videoRef = storageRef.child(video.id + "/video");
    File videoFile = File(video.path);

    final thumbnailRef = storageRef.child(video.id + "/thumbnail");
    File thumbnailFile = File(video.thumbnail);

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
}
