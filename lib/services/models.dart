class Video {
  Video({required this.title, required this.thumbnail, required this.path});

  Video.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title']! as String,
          thumbnail: json['thumbnail']! as String,
          path: json['path']! as String,
        );

  final String title;
  final String thumbnail;
  final String path;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'thumbnail': thumbnail,
      'path': path,
    };
  }
}
