import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:cutshot/services/services.dart';
import 'package:provider/provider.dart';

class VideoTrimmerWidget extends StatefulWidget {
  final Video sourceVideo;
  final ValueChanged<Video> onTrimmingComplete;

  const VideoTrimmerWidget({
    Key? key,
    required this.sourceVideo,
    required this.onTrimmingComplete,
  }) : super(key: key);

  @override
  _VideoTrimmerWidgetState createState() => _VideoTrimmerWidgetState();
}

class _VideoTrimmerWidgetState extends State<VideoTrimmerWidget> {
  late List<Highlight> _tempVideos;
  bool _isTrimming = false;
  bool _isExporting = false;

  Future<void> _trimVideo() async {
    setState(() {
      _isTrimming = true;
    });

    String tempDir = await getTemporaryDirectory().then((dir) => dir.path);
    String dir =
        await getApplicationDocumentsDirectory().then((dir) => dir.path);

    final List<Highlight> clips = [
      Highlight(
          start: 1,
          end: 2,
          outputPath:
              '$tempDir/${DateTime.now().millisecondsSinceEpoch}_trimmed.mp4'),
      Highlight(
          start: 3,
          end: 4,
          outputPath:
              '$tempDir/${DateTime.now().millisecondsSinceEpoch}_trimmed.mp4'),
    ];

    List<String> filterStrings = [];
    List<String> exportStrings = [];

    for (int i = 0; i < clips.length; i++) {
      Highlight clip = clips[i];
      int j = (i + 1).toInt();

      String videoString =
          "[0:v]trim=${clip.start}:${clip.end},setpts=PTS-STARTPTS[v$j];";
      String audioString =
          "[0:a]atrim=${clip.start}:${clip.end},asetpts=PTS-STARTPTS[a$j];";
      String concatString =
          "[v$j][a$j]concat=n=1:v=1:a=1[vout$j][aout$j]"; // ; is added below when we join all the filter strings together

      filterStrings.add("$videoString$audioString$concatString");
      exportStrings
          .add("-map [vout$j] -map [aout$j] -strict -2 ${clip.outputPath}");
    }

    final arguments = [
      '-y',
      '-i',
      "$dir/${widget.sourceVideo.videoPath}",
      '-filter_complex',
      filterStrings.join(";"),
      exportStrings.join(" "),
    ];

    print(arguments.join(' '));

    // https://pub.dev/documentation/ffmpeg_kit_flutter/latest/ffmpeg_kit/FFmpegKit/executeAsync.html
    await FFmpegKit.executeAsync(arguments.join(' '), (session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('successfully trimmed video {returnCode: $session}}');
        setState(() {
          _isTrimming = false;
          _tempVideos = clips;
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

  Future<void> _exportVideos(List<Highlight> exportingHighlights) async {
    setState(() {
      _isExporting = true;
    });

    final List<bool> results = [];

    for (final highlight in exportingHighlights) {
      final isSuccess = await GallerySaver.saveVideo(highlight.outputPath,
          albumName: 'Cutshot Highlights');

      results.add(isSuccess ?? false);
    }

    if (!results.contains(false)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Highlights saved to Cutshot Hightlights album!'),
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

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.sourceVideo.uploadProgress != 100
          ? const Text("Uploading video...")
          : const Text("No Highlights found")
      // ElevatedButton(
      //     onPressed: _isTrimming ? null : _trimVideo,
      //     child: _isTrimming
      //         ? const CircularProgressIndicator()
      //         : const Text('Trim Video')),
      // ElevatedButton(
      //     onPressed: _isExporting ? null : () => _exportVideos(_tempVideos),
      //     child: _isExporting
      //         ? const CircularProgressIndicator()
      //         : const Text('Export Video'))
    ]);
  }
}
