import 'package:cutshot/profile/profile.dart';
import 'package:cutshot/video/video.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _addVideoToFirebase() async {
    final XFile? videoXFile = await _picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));

    //get first frame of video as thumbnail
    final Map<String, dynamic> json = {
      'path': videoXFile!.path,
      // thumbnail: 'https://picsum.photos/250?image=9',
      'title': videoXFile.name,
    };

    //create new Video model instance
    // final video = Video.fromJson(json);

    FirestoreService().createVideo(json);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Video>>(
      future: FirestoreService().getVideos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        } else if (snapshot.hasError) {
          return Center(
            child: ErrorMessage(message: snapshot.error.toString()),
          );
        } else if (snapshot.hasData) {
          var videos = snapshot.data!;

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
              padding: const EdgeInsets.all(20.0),
              crossAxisSpacing: 10.0,
              crossAxisCount: 2,
              children: videos.map((video) => VideoItem(video: video)).toList(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _addVideoToFirebase,
              tooltip: 'Add Video',
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return const Text('No videos found in Firestore. Check database');
        }
      },
    );
  }
}
