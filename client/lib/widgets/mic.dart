import 'package:client/providers.dart';
import 'package:client/service/microphone_manager.dart';
import 'package:client/widgets/indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class MicRecorder extends ConsumerWidget {
  const MicRecorder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = ref.watch(isRecordingProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: isRecording
              ? const RecordingIndicator().animate().fadeIn()
              : const CircleWidget(
                  color: Colors.grey,
                  diameter: 20,
                ).animate().fadeIn(),
        ),
        isRecording
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async => await stopRecording(ref),
                    icon: const Icon(Icons.stop),
                  ),
                  const Text('Stop').animate().fadeIn()
                ],
              ).animate().fadeIn()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async => await startRecording(context, ref),
                    icon: const Icon(Icons.mic),
                  ),
                  const Text('Record').animate().fadeIn()
                ],
              ).animate().fadeIn()
      ],
    );
  }

  Future<void> startRecording(BuildContext context, WidgetRef ref) async {
    var status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Microphone Permission denied'),
          content: const Text('Please allow microphone to use the app'),
          actions: [
            ElevatedButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('OK'),
            )
          ],
          actionsAlignment: MainAxisAlignment.center,
        ),
      );
    }

    await micMan.recorder.startRecorder(
      toFile: 'tmp.webm',
      codec: Codec.opusWebM,
    );
    ref.invalidate(isRecordingProvider);
  }

  Future<void> stopRecording(WidgetRef ref) async {
    final url = await micMan.recorder.stopRecorder() ?? '';
    ref.read(recordingUrlProvider.notifier).state = url;
    // clear for next job id
    ref.read(jobIdProvider.notifier).state = '';
    ref.invalidate(isRecordingProvider);
  }
}
