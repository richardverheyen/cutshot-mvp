import 'package:cutshot/video/video.dart';
import 'package:flutter/material.dart';
import 'package:cutshot/services/models.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class VideoItem extends StatelessWidget {
  final Video video;
  const VideoItem({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: video.path,
      child: Material(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => VideoScreen(video: video),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: FutureBuilder(
                      future: getApplicationDocumentsDirectory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Image.asset(
                            video.thumbnail,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      })),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d/MMM').format(
                            video.lastModified.toDate(),
                          ),
                          style: const TextStyle(
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          video.videoStored
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          video.videoStored
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
