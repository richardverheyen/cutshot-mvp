import 'dart:io';

import 'package:cutshot/services/services.dart';
import 'package:cutshot/video/video_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// class VideoScreen extends StatefulWidget {
//   final String id;

//   const VideoScreen({super.key, required this.video});

//   @override
//   State<VideoScreen> createState() => _VideoScreenState();
// }

// class MyWidget extends StatelessWidget {
//   const MyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final List<Video> videos = Provider.of<List<Video>>(context);
    final Video video = videos.firstWhere((Video video) => video.id == id,
        orElse: () => Video());

    return Scaffold(
      appBar: AppBar(
        title: Text(video.title),
        actions: [
          video.videoStored
              ? Container()
              : IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.upload,
                  ),
                  // ignore: avoid_returning_null_for_void
                  onPressed: () => null),
          video.videoStored
              ? IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.scissors,
                  ),
                  // ignore: avoid_returning_null_for_void
                  onPressed: () => null)
              : Container(),
          IconButton(
              icon: const Icon(
                FontAwesomeIcons.fileExport,
              ),

              // ignore: avoid_returning_null_for_void
              onPressed: () => null),
        ],
      ),
      // body: const VideoSelectorWidget()
      body: Center(
        child: Column(
          children: [
            Container(
              color: Colors.black,
              height: 240,
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                        tag: video.thumbnailPath,
                        child: Image.asset(
                          video.thumbnailPath,
                          fit: BoxFit.contain,
                        )),
                  ),
                  Center(
                      heightFactor: 240,
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.grey.shade400,
                          value: video.uploadProgress / 100)),
                ],
              ),
            ),
            VideoTrimmerWidget(
              sourceVideo: video,
              onTrimmingComplete: (Video video) => {},
            ),
          ],
        ),
      ),
    );
  }
}
