import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:logger/logger.dart';
import 'package:flutter_sound_web/flutter_sound_web.dart' show FlutterSoundPlugin;

final micMan = MicrophoneManager();

class MicrophoneManager {
  MicrophoneManager._internal();

  factory MicrophoneManager() {
    return _instance;
  }

  static final _instance = MicrophoneManager._internal();

  final player = FlutterSoundPlayer(logLevel: Level.off);
  final recorder = FlutterSoundRecorder(logLevel: Level.off);

  Future<void> init() async {
    await FlutterSoundPlugin.ScriptLoaded.future;
    await player.openPlayer();
    await recorder.openRecorder();
  }

  Future<void> dispose() async {
    await player.closePlayer();
    await recorder.closeRecorder();
  }
}
