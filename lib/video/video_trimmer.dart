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
  late List<File> _tempVideos;
  bool _isTrimming = false;
  bool _isExporting = false;

  Future<void> _trimVideo() async {
    setState(() {
      _isTrimming = true;
    });

    final outputPath1 =
        '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}_trimmed.mp4';

    final outputPath2 =
        '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}_trimmed.mp4';
    final duration =
        await FFprobeKit.getMediaInformation(widget.videoFile.path);

    final arguments = [
      '-y',
      '-i',
      widget.videoFile.path,
      '-filter_complex',
      '[0:v]trim=1:2,setpts=PTS-STARTPTS[v1];[0:v]trim=3:4,setpts=PTS-STARTPTS[v2];[0:a]atrim=1:2,asetpts=PTS-STARTPTS[a1];[0:a]atrim=3:4,asetpts=PTS-STARTPTS[a2];[v1][a1]concat=n=1:v=1:a=1[vout1][aout1];[v2][a2]concat=n=1:v=1:a=1[vout2][aout2]',
      '-map',
      '[vout1]',
      '-map',
      '[aout1]',
      '-strict',
      '-2',
      outputPath1,
      '-map',
      '[vout2]',
      '-map',
      '[aout2]',
      '-strict',
      '-2',
      outputPath2,
    ];

    // https://pub.dev/documentation/ffmpeg_kit_flutter/latest/ffmpeg_kit/FFmpegKit/executeAsync.html
    await FFmpegKit.executeAsync(arguments.join(' '), (session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('successfully trimmed video {returnCode: $session}}');
        setState(() {
          _isTrimming = false;
          _tempVideos = [File(outputPath1), File(outputPath2)];
        });
        // widget.onTrimmingComplete(File(outputPath));
      } else {
        print('failed to trim video {returnCode: $returnCode}');
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

  Future<void> _exportVideos(List<File> exportingVideos) async {
    setState(() {
      _isExporting = true;
    });

    late Directory? appDirectory;

    if (Platform.isAndroid) {
      appDirectory = await getExternalStorageDirectory()!;
    } else {
      appDirectory = await getApplicationDocumentsDirectory();
    }

    final List<bool> results = [];

    for (final video in exportingVideos) {
      final outputPath =
          '${appDirectory!.path}/${DateTime.now().millisecondsSinceEpoch}_exported.mp4';

      await video.copy(outputPath);

      final isSuccess =
          await GallerySaver.saveVideo(outputPath, albumName: 'Cutshot Clips');

      results.add(isSuccess ?? false);
    }

    if (!results.contains(false)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All videos exported successfully!'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to export one or more videos!'),
        backgroundColor: Colors.red,
      ));
    }

    setState(() {
      _isExporting = false;
    });
  }

  // Future<void> _exportVideos(List<File> exportingVideo) async {
  //   setState(() {
  //     _isExporting = true;
  //   });

  //   late Directory? appDirectory;

  //   if (Platform.isAndroid) {
  //     appDirectory = await getExternalStorageDirectory()!;
  //   } else {
  //     appDirectory = await getApplicationDocumentsDirectory();
  //   }

  //   final outputPath =
  //       '${appDirectory!.path}/${DateTime.now().millisecondsSinceEpoch}_exported.mp4';

  //   await exportingVideo.copy(outputPath);

  //   final isSuccess =
  //       await GallerySaver.saveVideo(outputPath, albumName: 'Cutshot Clips');

  //   if (isSuccess != null) {
  //     if (isSuccess) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Video exported successfully!'),
  //         backgroundColor: Colors.green,
  //       ));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Failed to export video!'),
  //         backgroundColor: Colors.red,
  //       ));
  //     }

  //     setState(() {
  //       _isExporting = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ElevatedButton(
          onPressed: _isTrimming ? null : _trimVideo,
          child: _isTrimming
              ? const CircularProgressIndicator()
              : const Text('Trim Video')),
      ElevatedButton(
          onPressed: _isExporting ? null : () => _exportVideos(_tempVideos),
          child: _isExporting
              ? const CircularProgressIndicator()
              : const Text('Export Video'))
    ]);
  }
}
