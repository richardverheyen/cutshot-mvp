import 'package:cutshot/shared/shared.dart';
import 'package:cutshot/gallery/gallery.dart';
import 'package:cutshot/login/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cutshot/services/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        } else if (snapshot.hasError) {
          return const Center(
            child: ErrorMessage(),
          );
        } else if (snapshot.hasData) {
          return MultiProvider(providers: [
            StreamProvider<List<Video>>(
                initialData: [Video()],
                create: (_) => FirestoreService().streamVideoList()),
          ], child: const GalleryScreen());
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
