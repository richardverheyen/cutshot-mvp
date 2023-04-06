import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class Video {
  final String id;
  final dynamic createdDate;
  final String title;
  final String videoPath;
  final List<String> thumbnailPaths;
  bool uploading;
  bool uploadComplete;

  Video(
      {this.id = '',
      this.createdDate,
      this.title = '',
      this.videoPath = '',
      this.thumbnailPaths = const [""],
      this.uploading = false,
      this.uploadComplete = false});

  Video.fromJson(String id, Map<String, dynamic> json)
      : this(
          id: id,
          createdDate:
              json['createdDate'] == null ? null : json['createdDate'].toDate(),
          title: json['title'] ?? '',
          videoPath: json['videoPath'] ?? '',
          thumbnailPaths: (json['thumbnailPaths'] as List<dynamic>?)
                  ?.map((path) => path as String)
                  .toList() ??
              [],
          uploading: json['uploading'] ?? false,
          uploadComplete: json['uploadComplete'] ?? false,
        );

  Map<String, dynamic> toJson() {
    print('toJson');

    return {
      'id': id,
      'createdDate': createdDate,
      'title': title,
      'videoPath': videoPath,
      'thumbnailPaths': thumbnailPaths,
      'uploading': uploading,
      'uploadComplete': uploadComplete,
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
