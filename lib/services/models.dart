import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  Video(
      {required this.id,
      required this.title,
      required this.lastModified,
      required this.thumbnail,
      this.videoStored = false,
      this.thumbnailStored = false,
      required this.path});

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

  final String id;
  final String title;
  late final String thumbnail;
  final Timestamp lastModified;
  final String path;
  late final bool videoStored;
  late final bool thumbnailStored;

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
