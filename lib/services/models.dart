import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class Video {
  final String id;
  final String title;
  String thumbnail;
  final Timestamp lastModified;
  final String path;
  late final bool videoStored;
  late final bool thumbnailStored;

  Video(
      {required this.id,
      required this.title,
      required this.lastModified,
      required this.thumbnail,
      this.videoStored = false,
      this.thumbnailStored = false,
      required this.path}) {
    _initPaths(thumbnail);
  }

  void _initPaths(String? thumbnail) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    this.thumbnail = "$appDocPath/$thumbnail";
  }

  Video.fromJson(String id, Map<String, dynamic> json)
      : this(
          id: id,
          title: json['title']! as String,
          thumbnail: json['thumbnail']! as String,
          lastModified: json['lastModified']! as Timestamp,
          path: json['path']! as String,
          videoStored:
              [null, false].contains(json['videoStored']) ? false : true,
          thumbnailStored:
              [null, false].contains(json['thumbnailStored']) ? false : true,
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'lastModified': lastModified,
      'path': path,
      'videoStored': videoStored,
      'thumbnailStored': thumbnailStored,
    };
  }
}

class Highlight {
  // final String id;
  final double start;
  final double end;
  late String outputPath;

  Highlight(
      {
      // required this.id,
      required this.start,
      required this.end,
      this.outputPath = ''});

  Highlight.fromJson(String id, Map<String, dynamic> json)
      : this(
          // id: id,
          start: json['start']! as double,
          end: json['end']! as double,
          outputPath: json['outputPath']! as String,
        );

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'start': start,
      'end': end,
      'outputPath': outputPath,
    };
  }
}
