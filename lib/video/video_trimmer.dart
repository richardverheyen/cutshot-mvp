import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _isTrimming = false;

  Future<void> _trimVideo() async {
    setState(() {
      _isTrimming = true;
    });

    final outputPath =
        '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}_trimmed.mp4';
    final duration =
        await FFprobeKit.getMediaInformation(widget.videoFile.path);
    final startTime = 0;
    final endTime = startTime + 10;

    final arguments = [
      '-y',
      '-i',
      widget.videoFile.path,
      '-ss',
      startTime.toString(),
      '-t',
      (endTime - startTime).toString(),
      '-c:v',
      'mpeg4',
      '-b:v',
      '1M',
      '-c:a',
      'copy',
      '-strict',
      '-2',
      outputPath,
    ];

    await FFmpegKit.executeAsync(arguments.join(' ')).then((ffCommand) async {
      // final returnCode = await ffCommand.getReturnCode();
      // if (ReturnCode.isSuccess(returnCode)) {
      setState(() {
        _isTrimming = false;
      });
      widget.onTrimmingComplete(File(outputPath));
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text('Failed to trim video!'),
      //     backgroundColor: Colors.red,
      //   ));
      //   setState(() {
      //     _isTrimming = false;
      //   });
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isTrimming)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )
        else
          ElevatedButton(
            onPressed: _trimVideo,
            child: const Text('Trim Video'),
          ),
      ],
    );
  }
}
