import 'dart:io';

import 'package:cutshot/services/services.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  final Video video;

  const VideoScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: video.path,
            child: Image.network(
              'https://picsum.photos/250?image=9',
            ),
          ),
        ),
      ),
    );
  }
}
