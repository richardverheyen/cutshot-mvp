import 'package:cutshot/video/video.dart';
import 'package:flutter/material.dart';
import 'package:cutshot/services/models.dart';

class VideoItem extends StatelessWidget {
  final Video video;
  const VideoItem({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: video.path,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => VideoScreen(video: video),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: SizedBox(
                    child: Image.network(
                  'https://picsum.photos/250?image=9',
                )
                    // child: Image.asset(
                    //   'assets/covers/${topic.img}',
                    //   fit: BoxFit.contain,
                    // ),
                    ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    video.title,
                    style: const TextStyle(
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
              // Flexible(child: TopicProgress(topic: topic)),
            ],
          ),
        ),
      ),
    );
  }
}

// class TopicScreen extends StatelessWidget {
//   final Topic topic;

//   const TopicScreen({super.key, required this.topic});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//       ),
//       body: ListView(children: [
//         Hero(
//           tag: topic.img,
//           child: Image.asset('assets/covers/${topic.img}',
//               width: MediaQuery.of(context).size.width),
//         ),
//         Text(
//           topic.title,
//           style: const TextStyle(
//               height: 2, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         QuizList(topic: topic)
//       ]),
//     );
//   }
// }
