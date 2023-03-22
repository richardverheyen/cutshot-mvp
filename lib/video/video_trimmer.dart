import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class VideoTrimmerWidget extends StatefulWidget {
  final File videoFile;
  final ValueChanged<File> onTrimmingComplete;

  const VideoTrimmerWidget({
    Key? key,
    required this.videoFile,
    required this.onTrimmingComplete,
  }) : super(key: key);

  @override
  _VideoTrimmerWidgetState createState() => _VideoTrimmerWidgetState();
}

class _VideoTrimmerWidgetState extends State<VideoTrimmerWidget> {
  late File _tempVideo;
  bool _isTrimming = false;
  bool _isExporting = false;

  Future<void> _trimVideo() async {
    setState(() {
      _isTrimming = true;
    });

    final outputPath =
        '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}_trimmed.mp4';
    final duration =
        await FFprobeKit.getMediaInformation(widget.videoFile.path);
    final startTime = 0;
    final endTime = startTime + 4;

    final arguments = [
      '-y',
      '-i',
      widget.videoFile.path,
      '-ss',
      startTime.toString(),
      '-t',
      (endTime - startTime).toString(),
      '-c',
      'copy',
      '-strict',
      '-2',
      outputPath,
    ];

    // https://pub.dev/documentation/ffmpeg_kit_flutter/latest/ffmpeg_kit/FFmpegKit/executeAsync.html
    await FFmpegKit.executeAsync(arguments.join(' '), (session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('successfully trimmed video {returnCode: $session}}');
        setState(() {
          _isTrimming = false;
          _tempVideo = File(outputPath);
        });
        // widget.onTrimmingComplete(File(outputPath));
      } else {
        print('failed to trim video {returnCode: $session}');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to trim video!'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isTrimming = false;
        });
      }
    });
  }

  Future<void> _exportVideo(File exportingVideo) async {
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

    await exportingVideo.copy(outputPath);

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
    return Column(children: [
      ElevatedButton(
          onPressed: _isTrimming ? null : _trimVideo,
          child: _isTrimming
              ? const CircularProgressIndicator()
              : const Text('Trim Video')),
      ElevatedButton(
          onPressed: _isExporting ? null : () => _exportVideo(_tempVideo),
          child: _isExporting
              ? const CircularProgressIndicator()
              : const Text('Export Video'))
    ]);
  }
}
