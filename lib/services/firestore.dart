import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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

  Stream<List<Highlight>> streamHighlightList(String id) {
    return _db
        .collection("videos")
        .doc(id)
        .collection('highlights')
        .orderBy('start', descending: false)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((doc) => Highlight.fromJson(doc.id, doc.data()))
            .toList());
  }

  inferVideo(String id) async {
    print('Infering video $id');
    _db.collection('videos').doc(id).collection('highlights').add({
      "start": 1,
      "end": 2,
    });
    _db.collection('videos').doc(id).collection('highlights').add({
      "start": 3,
      "end": 4,
    });
  }

  createVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? videoXFile = await picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));

    DocumentReference ref = _db.collection('videos').doc();

    // perm directory
    final Directory appDir = await getApplicationDocumentsDirectory();

    print(videoXFile);

    // Create a new directory inside the application documents directory.
    final newDirectory = Directory('${appDir.path}/${ref.id}');
    if (!await newDirectory.exists()) {
      await newDirectory.create();
      print('New directory created: ${newDirectory.path}');
    } else {
      print('Directory already exists: ${newDirectory.path}');
    }

    // Write video data to file in new directory
    final videoFile =
        await File(videoXFile!.path).copy('${newDirectory.path}/video.mp4');
    await videoFile.writeAsBytes(await videoXFile.readAsBytes());

    // Get the duration of the video
    VideoPlayerController controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    final int videoDurationMs =
        controller.value.duration.inMilliseconds.toInt();

    print(controller.value);

    List<String?> thumbnailPaths = [];

    for (int i = 0; i < (videoDurationMs / 1000) - 0.2; i++) {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: '${newDirectory.path}/thumbnail-$i.png',
        imageFormat: ImageFormat.PNG,
        maxWidth: 0,
        maxHeight: 0,
        timeMs: i * 1000,
      );

      thumbnailPaths.add(thumbnailPath);
      print('Thumbnail $i generated at $thumbnailPath');
    }

    ref.set({
      "videoPath": videoFile.path,
      "thumbnailPaths": thumbnailPaths,
      "durationMs": videoDurationMs,
      "sizeX": controller.value.size.width,
      "sizeY": controller.value.size.height,
      "uploading": true
    });

    List<Future<void>> futures = [];

    for (String? thumbnail in thumbnailPaths) {
      List<String> parts = thumbnail!.split('/');
      String localPath = "${parts[parts.length - 2]}/${parts.last}";

      Future<void> future = StorageService()
          .storageRef
          .child(localPath)
          .putFile(File(thumbnail), SettableMetadata(contentType: "image/png"))
          .then((value) {
        print("Uploaded thumbnail $thumbnail");
        // Your code to be executed after the file has been uploaded
      });
      futures.add(future);
    }

    Future.wait(futures).then((_) {
      print("All uploads complete");
      ref.update({"uploading": true, "uploadComplete": true});
      // Your code to be executed when all the uploads are complete
    });
  }

  /// Updates the current user's report document after completing quiz
  // createVideo(Video video) async {
  //   _db
  //       .collection('videos')
  //       .add(video.toJson())
  //       // Then start the uploadVideo process
  //       .then((data) => _db
  //           .collection('videos')
  //           .doc(data.id)
  //           .withConverter(
  //             fromFirestore: (snapshot, _) =>
  //                 Video.fromJson(snapshot.id, snapshot.data()!),
  //             toFirestore: (Video video, _) => video.toJson(),
  //           )
  //           .get())
  //       .then((doc) => doc.data())
  //       .then((newVideo) => uploadVideo(newVideo as Video))
  //       .then((_) => print("Video uploaded!"))
  //       .catchError((error) => print("Failed to add video: $error"));
  // }

  // uploadVideo(Video video) async {

  //   final appDocDir = await getApplicationDocumentsDirectory();
  //   final appDocPath = appDocDir.path;

  //   late UploadTask uploadVideoTask;

  //   File videoFile = File("$appDocPath/${video.videoPath}");
  //   File thumbnailFile = File(video.thumbnailPath);

  //   // Upload thumbnail but don't track progress
  //   StorageService()
  //       .storageRef
  //       .child("${video.id}/thumbnail")
  //       .putFile(thumbnailFile, SettableMetadata(contentType: "image/webp"));

  //   uploadVideoTask = StorageService()
  //       .storageRef
  //       .child("${video.id}/video")
  //       .putFile(videoFile, SettableMetadata(contentType: "video/mp4"));

  //   uploadVideoTask.snapshotEvents.listen((TaskSnapshot snapshot) {
  //     switch (snapshot.state) {
  //       case TaskState.running:
  //         final double progress =
  //             snapshot.bytesTransferred / snapshot.totalBytes * 100;
  //         _db.collection('videos').doc(video.id).update({
  //           'uploading': true,
  //           'uploadProgress': progress,
  //         });
  //         break;

  //       case TaskState.paused:
  //         print("Upload is paused.");
  //         break;
  //       case TaskState.canceled:
  //         print("Upload was canceled");
  //         break;
  //       case TaskState.error:
  //         // Handle unsuccessful uploads
  //         break;

  //       case TaskState.success:
  //         _db.collection('videos').doc(video.id).update({
  //           'uploading': false,
  //         });
  //         break;
  //     }
  //   }, onError: (error) {
  //     print(error.toString());
  //   });
  // }
}
