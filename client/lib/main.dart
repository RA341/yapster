import 'package:client/service/api.dart';
import 'package:client/service/microphone_manager.dart';
import 'package:client/utils.dart';
import 'package:client/widgets/mic_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // try {
  //   await Future.delayed(const Duration(seconds: 2));
  // } catch (e) {
  //   print(e);
  //   print('first try did not work, disposing');
  //   await micMan.dispose();
  //   await Future.delayed(const Duration(seconds: 2));
  //   try {
  //     micMan.init();
  //   } catch (e) {
  //     print('second try did not work');
  //     await micMan.dispose();
  //   }
  // }

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
      body: Center(
        child: MicControls(),
      ),
    );
  }
}
