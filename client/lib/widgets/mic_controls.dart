import 'package:client/service/microphone_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';

class MicControls extends ConsumerStatefulWidget {
  const MicControls({super.key});

  @override
  ConsumerState createState() => _MicControlsState();
}

class _MicControlsState extends ConsumerState<MicControls> {
  String url = '';

  @override
  void initState() {
    micMan.init().then((value) {
    },).onError((error, stackTrace) {
      print(error);
    },);
    super.initState();
  }

  @override
  void dispose() {
    micMan.dispose();
    super.dispose();
  }

  final recorder = micMan.recorder;
  final player = micMan.player;

  Future<void> startRecording() async {
    await recorder.startRecorder(toFile: 'tmp.webm', codec: Codec.opusWebM);
    setState(() {});
  }

  Future<void> stopRecording() async {
    url = await recorder.stopRecorder() ?? '';
    setState(() {});
    print(url);
    await player.startPlayer(codec: Codec.opusWebM, fromURI: url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const RecordingProgress(),
        recorder.isRecording
            ? ElevatedButton(
                onPressed: () async => await stopRecording(),
                child: const Text('Stop recording'),
              )
            : ElevatedButton(
                onPressed: () async => await startRecording(),
                child: const Text('Start recording'),
              )
      ],
    );
  }
}

class RecordingProgress extends ConsumerWidget {
  const RecordingProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Text('Recording progress is here');
  }
}
