import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'video_trimmer.dart'; // Import the VideoTrimmerWidget
import 'video_exporter.dart'; // Import the VideoTrimmerWidget

class VideoSelectorWidget extends StatefulWidget {
  const VideoSelectorWidget({Key? key}) : super(key: key);

  @override
  _VideoSelectorWidgetState createState() => _VideoSelectorWidgetState();
}

class _VideoSelectorWidgetState extends State<VideoSelectorWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _videoFile;
  late VideoPlayerController _controller;
  bool _isTrimmingComplete =
      false; // State variable to track if trimming process is complete

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _videoFile = File(pickedFile.path);
      _controller = VideoPlayerController.file(_videoFile!);
      setState(() {});
    }
  }

  // Callback function to receive trimmed video file
  void _onTrimmingComplete(File trimmedVideoFile) {
    // Display details of trimmed video file in the UI
    setState(() {
      _isTrimmingComplete = true;
      _videoFile = trimmedVideoFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickVideo,
          child: const Text('Pick Video'),
        ),
        if (_videoFile != null) // Conditionally render VideoTrimmerWidget
          VideoTrimmerWidget(
            videoFile: _videoFile!,
            onTrimmingComplete: _onTrimmingComplete,
          ),
        if (_videoFile != null &&
            _isTrimmingComplete) // Display trimmed video file details
          VideoExporterWidget(
            videoFile: _videoFile!,
          )
      ],
    );
  }
}
