import 'package:client/service/microphone_manager.dart';
import 'package:client/utils.dart';
import 'package:client/widgets/discard_button.dart';
import 'package:client/widgets/info_display.dart';
import 'package:client/widgets/mic_controls.dart';
import 'package:client/widgets/upload_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // important keep this in it allows the
  // flutter sound files to be fully downloaded
  await Future.delayed(const Duration(milliseconds: 50));
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
                padding: EdgeInsets.all(20),
                child:
                    Text('Welcome to Yapster', style: TextStyle(fontSize: 50)),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text('Yap something', style: TextStyle(fontSize: 25)),
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
            ],
          ),
        ),
      ),
    );
  }
}
