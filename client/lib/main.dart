import 'package:client/service/microphone_manager.dart';
import 'package:client/utils.dart';
import 'package:client/widgets/discard_button.dart';
import 'package:client/widgets/info_display.dart';
import 'package:client/widgets/mic_controls.dart';
import 'package:client/widgets/player.dart';
import 'package:client/widgets/upload_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // important keep this in it allows the
  // flutter sound files to be fully downloaded
  // await Future.delayed(const Duration(seconds: 1));
  await micMan.init();

  setupApiPath();

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yapster',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const App(),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Welcome to Yapster',
                  style: TextStyle(fontSize: 40),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    Text(
                      'Yap something',
                      style: TextStyle(fontSize: 25),
                      maxLines: 2,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'not so state of the art machine learning models will attempt\n to detect your gender and transcribe what you say',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              InfoDisplay(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DiscardButton(),
                  MicControls(),
                  UploadButton(),
                ],
              ),
              RecordingPlayer()
            ],
          ),
        ),
      ),
    );
  }
}
