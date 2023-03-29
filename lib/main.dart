import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:cutshot/theme.dart';
import 'package:cutshot/shared/shared.dart';
import 'package:cutshot/home/home.dart';
import 'package:path_provider/path_provider.dart';
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

        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
              providers: [
                FutureProvider<Directory>(
                    initialData: Directory(''),
                    create: (_) => getApplicationDocumentsDirectory()),
              ],
              child: MaterialApp(
                  debugShowCheckedModeBanner: true,
                  home: const HomeScreen(),
                  theme: appTheme));
        }

        return const MaterialApp(home: LoadingScreen());
      },
    );
  }
}
