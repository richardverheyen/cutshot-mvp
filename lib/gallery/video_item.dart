import 'package:cutshot/video/video.dart';
import 'package:flutter/material.dart';
import 'package:cutshot/services/models.dart';
import 'package:intl/intl.dart';

import '../services/services.dart';

class VideoItem extends StatelessWidget {
  final Video video;
  const VideoItem({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: video.path,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => VideoScreen(video: video),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  flex: 3,
                  child: Image.asset(
                    video.thumbnail,
                    fit: BoxFit.contain,
                  )
                  // FutureBuilder<String>(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    DateFormat('d/MMM/yy').format(video.lastModified.toDate()),
                    style: const TextStyle(
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  const SizedBox(width: 8),
                  video.videoStored
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.cloud_off),
                  const SizedBox(width: 8)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
