class Video {
  Video({required this.title, required this.path});

  Video.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title']! as String,
          path: json['path']! as String,
        );

  final String title;
  final String path;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'path': path,
    };
  }
}
