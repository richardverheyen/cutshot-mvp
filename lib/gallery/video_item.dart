import 'dart:io';

import 'package:cutshot/video/video.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cutshot/services/services.dart';
import 'package:provider/provider.dart';

class VideoItem extends StatelessWidget {
  const VideoItem({super.key, required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: video.id,
      child: Material(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  // Figure out how to do routing correctly
                  builder: (BuildContext context) => MultiProvider(providers: [
                        StreamProvider<List<Video>>(initialData: [
                          video
                        ], create: (_) => FirestoreService().streamVideoList()),
                        StreamProvider<List<Highlight>>(
                            initialData: [Highlight()],
                            catchError: (context, error) {
                              print(error);
                              return [Highlight()];
                            },
                            create: (_) => FirestoreService()
                                .streamHighlightList(video.id)),
                        FutureProvider<Directory>(
                            initialData: Directory(''),
                            create: (_) => getApplicationDocumentsDirectory()),
                      ], child: VideoScreen(id: video.id))),
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
                            video.thumbnailPaths.first,
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
                            video.createdDate as DateTime,
                          ),
                          style: const TextStyle(
                            height: 1.5,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          video.uploadComplete
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          video.uploadComplete
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off,
                          color: video.uploadComplete
                              ? Colors.greenAccent.shade400
                              : Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
              video.uploading
                  ? SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(
                            backgroundColor: Colors.grey.shade400),
                      ))
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
