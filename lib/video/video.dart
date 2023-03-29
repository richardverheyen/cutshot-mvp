import 'dart:io';
import 'dart:async';

import 'package:cutshot/services/services.dart';
import 'package:cutshot/video/video_selector.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {
  final Video video;

  const VideoScreen({super.key, required this.video});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
      ),
      // body: const VideoSelectorWidget()
      body: Center(
        child: Column(
          children: [
            Container(
              color: Colors.black,
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
                      heightFactor: 5.5,
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
            // const VideoSelectorWidget()
          ],
        ),
      ),
    );
  }
}
