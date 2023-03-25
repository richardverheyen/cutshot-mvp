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
  bool _uploading = false;
  late UploadTask _uploadTask;
  late StreamController<double> _progressController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _progressController = StreamController<double>.broadcast();
  }

  Future<void> _uploadVideo() async {
    final videoRef =
        StorageService().storageRef.child("${widget.video.id}/video");
    final thumbnailRef =
        StorageService().storageRef.child("${widget.video.id}/thumbnail");

    File videoFile = File(widget.video.path);
    File thumbnailFile = File(widget.video.thumbnail);

    // Upload thumbnail but don't track progress
    thumbnailRef.putFile(
        thumbnailFile, SettableMetadata(contentType: "image/webp"));

    setState(() {
      _uploading = true;
      _uploadTask = videoRef.putFile(
          videoFile, SettableMetadata(contentType: "video/mp4"));
    });

    _uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      switch (snapshot.state) {
        case TaskState.running:
          final progress =
              snapshot.bytesTransferred / snapshot.totalBytes * 100;
          _progressController.add(progress);

          setState(() {
            _progress = progress;
          });
          break;

        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          break;

        case TaskState.success:
          setState(() {
            _uploading = false;
          });
          break;
      }
    }, onError: (error) {
      print(error.toString());
    });
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
                        tag: widget.video.path,
                        child: Image.asset(
                          widget.video.thumbnail,
                          fit: BoxFit.contain,
                        )),
                  ),
                  Center(
                    heightFactor: 5.5,
                    child: StreamBuilder<double>(
                      stream: _progressController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _progress = snapshot.data!;
                        }
                        return CircularProgressIndicator(
                            backgroundColor: Colors.grey.shade400,
                            value: _progress / 100);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Text(widget.video.path),
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
                        onPressed:
                            widget.video.videoStored ? null : _uploadVideo,
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
