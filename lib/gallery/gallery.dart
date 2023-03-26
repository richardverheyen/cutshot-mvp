import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cutshot/profile/profile.dart';
import 'package:cutshot/video/video.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../services/services.dart';
import '../shared/shared.dart';
import 'video_item.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();

  final _videosStream = FirebaseFirestore.instance
      .collection('videos')
      .orderBy('createdDate', descending: false)
      .withConverter<Video>(
        fromFirestore: (snapshot, _) =>
            Video.fromJson(snapshot.id, snapshot.data()!),
        toFirestore: (movie, _) => movie.toJson(),
      )
      .snapshots();

  Future<void> _addVideoToFirebase() async {
    final XFile? videoXFile = await _picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));

    // perm directory
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String appDirPath = appDir.path;
    final videoPermFile =
        await File(videoXFile!.path).copy('$appDirPath/${videoXFile.name}');
    await videoPermFile.writeAsBytes(await videoXFile.readAsBytes());

    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPermFile.path,
      imageFormat: ImageFormat.WEBP,
      maxWidth: 0,
      maxHeight: 0,
    );

    //get first frame of video as thumbnail
    // final Map<String, dynamic> json = {
    //   'path': videoPermFile.path.split('/').last,
    //   'thumbnail': thumbnailPath!.split('/').last,
    //   'createdDate': await videoXFile.lastModified(),
    //   'title': "",
    // };

    Video video = Video(
        id: '',
        path: videoPermFile.path.split('/').last,
        thumbnail: thumbnailPath!.split('/').last,
        createdDate: await videoXFile.lastModified(),
        title: "");

    FirestoreService().createVideo(video);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _videosStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: ErrorMessage(message: snapshot.error.toString()),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gallery'),
            actions: [
              IconButton(
                  icon: Icon(
                    FontAwesomeIcons.circleUser,
                  ),
                  onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ProfileScreen();
                      })))
            ],
          ),
          body: GridView.count(
            primary: false,
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            children: snapshot.data!.docs.map((DocumentSnapshot snapshot) {
              Video data = snapshot.data()! as Video;
              return VideoItem(video: data);
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addVideoToFirebase,
            tooltip: 'Add Video',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
