import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class VideoExporterWidget extends StatefulWidget {
  final File videoFile;

  const VideoExporterWidget({Key? key, required this.videoFile})
      : super(key: key);

  @override
  _VideoExporterWidgetState createState() => _VideoExporterWidgetState();
}

class _VideoExporterWidgetState extends State<VideoExporterWidget> {
  bool _isExporting = false;

  Future<void> _exportVideo() async {
    setState(() {
      _isExporting = true;
    });

    late Directory? appDirectory;

    if (Platform.isAndroid) {
      appDirectory = await getExternalStorageDirectory()!;
    } else {
      appDirectory = await getApplicationDocumentsDirectory();
    }

    final outputPath =
        '${appDirectory!.path}/${DateTime.now().millisecondsSinceEpoch}_exported.mp4';

    await widget.videoFile.copy(outputPath);

    final isSuccess =
        await GallerySaver.saveVideo(outputPath, albumName: 'Cutshot Clips');

    if (isSuccess != null) {
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Video exported successfully!'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to export video!'),
          backgroundColor: Colors.red,
        ));
      }

      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: _exportVideo,
        child: _isExporting
            ? const CircularProgressIndicator()
            : const Text('Export Video'));
  }
}
