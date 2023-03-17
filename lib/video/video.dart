import 'package:cutshot/services/services.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  final Video video;

  const VideoScreen({super.key, required this.video});

  Future<void> _uploadVideo() async {
    StorageService().storeVideo(video);
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
                )
                //     FutureBuilder<String>(
                //   future: StorageService().getThumbnailUrl(video),
                //   builder:
                //       (BuildContext context, AsyncSnapshot<String> snapshot) {
                //     if (snapshot.hasData) {
                //       return Image.network(
                //         snapshot.data!,
                //         fit: BoxFit.contain,
                //       );
                //     } else {
                //       return Image.network(
                //         "https://via.placeholder.com/150",
                //         fit: BoxFit.contain,
                //       );
                //     }
                //   },
                // ),
                ),
            video.videoStored
                ? ElevatedButton(
                    onPressed: _uploadVideo, child: const Text('Upload Video'))
                : ElevatedButton(
                    onPressed: _uploadVideo, child: const Text('Upload Video')),
          ],
        ),
      ),
    );
  }
}
