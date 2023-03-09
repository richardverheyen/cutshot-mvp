import 'package:cutshot/video/video.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<XFile> _videoFileList = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _onButtonPressed() async {
    final XFile? newVideo = await _picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));

    setState(() {
      _videoFileList.add(newVideo!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker Example'),
      ),
      body: Center(
          child: GridView.builder(
        itemCount: _videoFileList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const VideoScreen();
                }));
              },
              child: Hero(
                  tag: 'imageHero',
                  child: Column(children: [
                    Image.network(
                      'https://picsum.photos/250?image=9',
                    ),
                    Text(_videoFileList[index].path),
                  ])));
          // return Card(
          //   child: Column(
          //     children: [
          //       Image.file(File(_videoFileList[index].path)),
          //       Text(_videoFileList[index].path),
          //     ],
          //   ),
          // );
        },
      )),
      // body: ListView.builder(
      //   itemCount: _videoFileList.length,
      //   itemBuilder: (BuildContext context, int index) {
      //     // in a 2 column grid display a thumbnail of the video inside a material card component
      //     return Card(
      //       child: Column(
      //         children: [
      //           Image.file(File(_videoFileList[index].path)),
      //           Text(_videoFileList[index].path),
      //         ],
      //       ),
      //     );

      //     // return Image.file(File(_videoFileList![index].path));
      //   },
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onButtonPressed,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
