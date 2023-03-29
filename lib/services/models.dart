import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class Video {
  final String id;
  final String title;
  DateTime? createdDate;
  String thumbnailPath;
  late final bool thumbnailStored;
  final String videoPath;
  late final bool videoStored;
  double uploadProgress;
  bool uploading;

  Video(
      {this.id = '',
      this.title = '',
      this.createdDate,
      this.videoPath = '',
      this.videoStored = false,
      this.thumbnailPath = '',
      this.thumbnailStored = false,
      this.uploadProgress = 0,
      this.uploading = false}) {
    _initPaths(thumbnailPath);
  }

  void _initPaths(String? thumbnailPath) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    this.thumbnailPath = "$appDocPath/$thumbnailPath";
  }

  Video.fromJson(String id, Map<String, dynamic> json)
      : this(
          id: id,
          title: json['title']! as String,
          createdDate: json['createdDate']!.toDate() as DateTime,
          thumbnailPath: json['thumbnailPath'] as String,
          thumbnailStored:
              [null, false].contains(json['thumbnailStored']) ? false : true,
          videoPath: json['videoPath'] as String,
          videoStored:
              [null, false].contains(json['videoStored']) ? false : true,
          uploadProgress: json['uploadProgress'].toDouble() as double,
          uploading: [null, false].contains(json['uploading']) ? false : true,
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdDate': Timestamp.fromDate(createdDate!),
      'thumbnailPath': thumbnailPath.split("/").last,
      'thumbnailStored': thumbnailStored,
      'videoPath': videoPath.split("/").last,
      'videoStored': videoStored,
      'uploadProgress': uploadProgress,
      'uploading': uploading,
    };
  }
}

class Highlight {
  final String id;
  final num start;
  final num end;

  Highlight({this.id = "", this.start = 9, this.end = 19});

  Highlight.fromJson(String id, Map<String, dynamic> json)
      : this(
          id: id,
          start: json['start']! as num,
          end: json['end']! as num,
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start': start,
      'end': end,
    };
  }
}
