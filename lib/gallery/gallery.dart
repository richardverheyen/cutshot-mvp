import 'dart:io';

import 'package:cutshot/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../services/services.dart';
import 'video_item.dart';
import 'package:provider/provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // final ImagePicker _picker = ImagePicker();

  // Future<void> _addVideoToFirebase() async {
  //   final XFile? videoXFile = await _picker.pickVideo(
  //       source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));

  //   // perm directory
  //   final Directory appDir = await getApplicationDocumentsDirectory();
  //   final String appDirPath = appDir.path;
  //   final videoPermFile =
  //       await File(videoXFile!.path).copy('$appDirPath/${videoXFile.name}');
  //   await videoPermFile.writeAsBytes(await videoXFile.readAsBytes());

  //   final thumbnailPath = await VideoThumbnail.thumbnailFile(
  //       video: videoPermFile.path,
  //       imageFormat: ImageFormat.WEBP,
  //       maxWidth: 0,
  //       maxHeight: 0,
  //       timeMs: 0);

  //   Video video = Video(
  //       id: '',
  //       videoPath: videoPermFile.path,
  //       thumbnailPath: thumbnailPath!,
  //       createdDate: await videoXFile.lastModified(),
  //       title: "");

  //   FirestoreService().createVideo(video);
  // }

  @override
  Widget build(BuildContext context) {
    List<Video> videoList = Provider.of<List<Video>>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
              icon: const Icon(
                FontAwesomeIcons.circleUser,
              ),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ProfileScreen();
                  })))
        ],
      ),
      body: GridView.builder(
        itemCount: videoList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
        itemBuilder: (BuildContext context, int index) {
          return VideoItem(
            video: videoList[index],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: FirestoreService().createVideo,
        tooltip: 'Add Video',
        child: const Icon(Icons.add),
      ),
    );
  }
}
