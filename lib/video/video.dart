import 'dart:io';

import 'package:cutshot/services/services.dart';
import 'package:cutshot/video/video_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key, required this.id});

  final bool highlights = false;
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
          IconButton(
              icon: const Icon(
                FontAwesomeIcons.upload,
              ),
              onPressed: video.videoStored
                  ? null
                  : () => FirestoreService().uploadVideo(video)),
          IconButton(
              icon: const Icon(
                FontAwesomeIcons.scissors,
              ),
              // ignore: avoid_returning_null_for_void
              onPressed: video.videoStored
                  ? () => FirestoreService().inferVideo(video.id)
                  : null),
          IconButton(
              icon: const Icon(
                FontAwesomeIcons.fileExport,
              ),

              // ignore: avoid_returning_null_for_void
              onPressed: highlights ? null : null),
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
                        tag: video.id,
                        child: Image.asset(
                          video.thumbnailPath,
                          fit: BoxFit.contain,
                        )),
                  ),
                  video.uploading
                      ? Center(
                          heightFactor: 240,
                          child: video.uploadProgress == 100
                              ? Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.check,
                                    color: Colors.white,
                                  ),
                                )
                              : CircularProgressIndicator(
                                  backgroundColor: Colors.grey.shade400,
                                  value: video.uploadProgress / 100))
                      : Container(),
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
