import 'package:cutshot/services/services.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class VideoService {
  Future<void> exportVideo(
      Video sourceVideo, List<Highlight> highlights) async {
    String tempDir = await getTemporaryDirectory().then((dir) => dir.path);
    String dir =
        await getApplicationDocumentsDirectory().then((dir) => dir.path);

    List<String> filterStrings = [];
    List<String> exportStrings = [];
    List<String> tempPathStrings = [];

    for (int i = 0; i < highlights.length; i++) {
      Highlight clip = highlights[i];
      int j = (i + 1).toInt();

      String videoString =
          "[0:v]trim=${clip.start}:${clip.end},setpts=PTS-STARTPTS[v$j];";
      String audioString =
          "[0:a]atrim=${clip.start}:${clip.end},asetpts=PTS-STARTPTS[a$j];";
      String concatString =
          "[v$j][a$j]concat=n=1:v=1:a=1[vout$j][aout$j]"; // ; is added below when we join all the filter strings together

      String tempPathString =
          "$tempDir/$j-${sourceVideo.videoPath.split("/").last}";

      filterStrings.add("$videoString$audioString$concatString");
      exportStrings
          .add("-map [vout$j] -map [aout$j] -strict -2 $tempPathString");
      tempPathStrings.add(tempPathString);
    }

    final arguments = [
      '-y',
      '-i',
      "$dir/${sourceVideo.videoPath}",
      '-filter_complex',
      filterStrings.join(";"),
      exportStrings.join(" "),
    ];

    // https://pub.dev/documentation/ffmpeg_kit_flutter/latest/ffmpeg_kit/FFmpegKit/executeAsync.html
    await FFmpegKit.executeAsync(arguments.join(' '), (session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('successfully trimmed video {returnCode: $session}}');

        final List<bool> results = [];
        for (final path in tempPathStrings) {
          final isSuccess = await GallerySaver.saveVideo(path,
              albumName: 'Cutshot Highlights');

          results.add(isSuccess ?? false);
        }

        if (!results.contains(false)) {
          print('Highlights saved to Cutshot Hightlights album!');
        } else {
          print('Failed to export one or more videos!');
        }
      } else {
        print('failed to trim video {returnCode: $returnCode}');
      }
    });
  }
}
