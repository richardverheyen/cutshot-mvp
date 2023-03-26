import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class Video {
  final String id;
  final String title;
  DateTime? createdDate;
  String thumbnail;
  late final bool thumbnailStored;
  final String path;
  late final bool videoStored;
  double uploadProgress;
  bool uploading;

  Video(
      {this.id = '',
      this.title = '',
      this.createdDate,
      this.thumbnail = '',
      this.videoStored = false,
      this.thumbnailStored = false,
      this.path = '',
      this.uploadProgress = 0,
      this.uploading = false}) {
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
          createdDate: json['createdDate']!.toDate() as DateTime,
          path: json['path']! as String,
          videoStored:
              [null, false].contains(json['videoStored']) ? false : true,
          thumbnailStored:
              [null, false].contains(json['thumbnailStored']) ? false : true,
          uploadProgress: json['uploadProgress'].toDouble() as double,
          uploading: [null, false].contains(json['uploading']) ? false : true,
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'createdDate': Timestamp.fromDate(createdDate!),
      'path': path,
      'videoStored': videoStored,
      'thumbnailStored': thumbnailStored,
      'uploadProgress': uploadProgress,
      'uploading': uploading,
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
