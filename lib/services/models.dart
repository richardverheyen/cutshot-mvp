import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  Video(
      {required this.id,
      required this.title,
      required this.lastModified,
      required this.thumbnail,
      required this.path});

  Video.fromJson(String id, Map<String, dynamic> json)
      : this(
          id: id,
          title: json['title']! as String,
          thumbnail: json['thumbnail']! as String,
          lastModified: json['lastModified']! as Timestamp,
          path: json['path']! as String,
        );

  final String id;
  final String title;
  final String thumbnail;
  final Timestamp lastModified;
  final String path;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'lastModified': lastModified,
      'path': path,
    };
  }
}
