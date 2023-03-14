import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  Video(
      {required this.title,
      required this.lastModified,
      required this.thumbnail,
      required this.path});

  Video.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title']! as String,
          thumbnail: json['thumbnail']! as String,
          lastModified: json['lastModified']! as Timestamp,
          path: json['path']! as String,
        );

  final String title;
  final String thumbnail;
  final Timestamp lastModified;
  final String path;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'thumbnail': thumbnail,
      'lastModified': lastModified,
      'path': path,
    };
  }
}
