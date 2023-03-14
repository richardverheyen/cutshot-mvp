import 'package:cutshot/services/models.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  final Video video;

  const VideoScreen({super.key, required this.video});

  Future<void> _uploadVideo() async {
    print('Upload Video');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(video.title),
      ),
      body: Center(
        child: Column(
          children: [
            Hero(
              tag: video.path,
              child: Image.asset(
                video.thumbnail,
                fit: BoxFit.contain,
              ),
            ),
            ElevatedButton(
                onPressed: _uploadVideo, child: const Text('Upload Video'))
          ],
        ),
      ),
    );
  }
}
