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
      .withConverter<Video>(
        fromFirestore: (snapshot, _) =>
            Video.fromJson(snapshot.id, snapshot.data()!),
        toFirestore: (movie, _) => movie.toJson(),
      )
      .snapshots();

  Future<void> _addVideoToFirebase() async {
    final XFile? videoXFile = await _picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));

    final temporaryFilePath = await VideoThumbnail.thumbnailFile(
      video: videoXFile!.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight:
          200, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 90,
    );

    //get first frame of video as thumbnail
    final Map<String, dynamic> json = {
      'path': videoXFile.path,
      'thumbnail': temporaryFilePath,
      'lastModified': await videoXFile.lastModified(),
      'title': videoXFile.name,
    };

    FirestoreService().createVideo(json);
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
