import 'dart:io';

import 'package:cutshot/services/services.dart';
import 'package:cutshot/video/video_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class VideoScreen extends StatefulWidget {
  final Video video;

  const VideoScreen({super.key, required this.video});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dir = Provider.of<Directory>(context).path;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
        actions: [
          widget.video.videoStored
              ? Container()
              : IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.upload,
                  ),
                  // ignore: avoid_returning_null_for_void
                  onPressed: () => null),
          widget.video.videoStored
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
                        tag: widget.video.thumbnailPath,
                        child: Image.asset(
                          widget.video.thumbnailPath,
                          fit: BoxFit.contain,
                        )),
                  ),
                  Center(
                      heightFactor: 240,
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.grey.shade400,
                          value: widget.video.uploadProgress / 100)),
                ],
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        onPressed: widget.video.videoStored ? null : null,
                        child: Text(widget.video.videoStored
                            ? 'Video Stored!'
                            : 'Upload Video')))),
            VideoTrimmerWidget(
              videoFile: File("$dir/${widget.video.videoPath}"),
              onTrimmingComplete: (File file) => {},
            ),
          ],
        ),
      ),
    );
  }
}
