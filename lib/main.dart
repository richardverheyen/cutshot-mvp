import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:cutshot/theme.dart';
import 'package:cutshot/shared/shared.dart';
import 'package:cutshot/home/home.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          // Error screen
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          // https://fireship.io/courses/flutter-firebase/topics-stream-provider/
          return StreamProvider(
              create: (_) => FirestoreService().streamVideos(),
              catchError: (_, err) => null,
              initialData: null,
              child: MaterialApp(
                  debugShowCheckedModeBanner: true,
                  // routes: appRoutes,
                  home: const HomeScreen(),
                  theme: appTheme));
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const MaterialApp(home: LoadingScreen());
      },
    );
  }
}
