import 'dart:io';

import 'package:cutshot/services/services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final Directory dir = Provider.of<Directory>(context);
    final List<Video> videos = Provider.of<List<Video>>(context);
    final Video video = videos.firstWhere((Video video) => video.id == id,
        orElse: () => Video());

    final List<Highlight> highlights = Provider.of<List<Highlight>>(context);

    Future<String?> getThumbnail(Highlight highlight) async {
      if (dir.path.isEmpty) {
        return null;
      }

      final thumbnail = await VideoThumbnail.thumbnailFile(
          video: "${dir.path}/${video.videoPath}",
          imageFormat: ImageFormat.WEBP,
          maxWidth: 100,
          maxHeight: 100,
          timeMs: 1000 * highlight.start as int);
      return thumbnail;
    }

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
              onPressed: highlights.isNotEmpty
                  ? () => VideoService().exportVideo(video, highlights)
                  : null),
        ],
      ),
      body: Column(
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
          Expanded(
            child: GridView.builder(
              itemCount: highlights.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
              itemBuilder: (BuildContext context, int index) {
                final Highlight highlight = highlights[index];
                return Container(
                  child: FutureBuilder(
                    future: getThumbnail(highlight),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Image.asset(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          );
                          // return Text(snapshot.data!.toString());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
