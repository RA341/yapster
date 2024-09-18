import 'dart:async';

import 'package:client/providers.dart';
import 'package:client/service/microphone_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';

class RecordingPlayer extends ConsumerWidget {
  const RecordingPlayer({super.key});

  Future<void> play(String uri, WidgetRef ref) async {
    if (micMan.player.isPaused || micMan.player.isStopped) {
      await micMan.player.startPlayer(fromURI: uri, codec: Codec.opusWebM);
      ref.invalidate(isPlayingProvider);
    }
  }

  Future<void> pause(WidgetRef ref) async {
    if (micMan.player.isPlaying) {
      await micMan.player.pausePlayer();
      ref.invalidate(isPlayingProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording = ref.watch(recordingUrlProvider);
    final isPlaying = ref.watch(isPlayingProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isPlaying
            ? IconButton(
                onPressed:
                    recording.isEmpty ? null : () async => await pause(ref),
                icon: const Icon(Icons.pause),
              )
            : IconButton(
                onPressed: recording.isEmpty
                    ? null
                    : () async => await play(recording, ref),
                icon: const Icon(Icons.play_arrow),
              ),
      ],
    );
  }
}
