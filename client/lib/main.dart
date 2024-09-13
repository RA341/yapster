import 'package:client/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_html/html.dart' as html;

Future<void> main() async {
  String basePath;
  if (kDebugMode) {
    basePath = 'http://localhost:8000';
  } else {
    if (kIsWeb) {
      basePath = html.window.location.href;
    }
    basePath = 'http://localhost:8000';
  }

  if (basePath.endsWith('/')) {
    basePath = basePath.substring(0, basePath.length - 1);
  }

  print('Base path is $basePath');

  api.init(basePath);

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
    );
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final echo = ref.watch(echoPointProvider('hello'));

    return Scaffold(
      body: Center(
        child: echo.when(
          data: (data) => Text(data),
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
