import 'package:cutshot/shared/shared.dart';
import 'package:cutshot/services/auth.dart';
import 'package:cutshot/gallery/gallery.dart';
import 'package:cutshot/login/login.dart';

import 'package:flutter/material.dart';

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
          return const GalleryScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
