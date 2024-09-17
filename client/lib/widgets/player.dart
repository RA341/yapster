import 'dart:async';

import 'package:client/providers.dart';
import 'package:client/service/microphone_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';

class RecordingPlayer extends ConsumerStatefulWidget {
  const RecordingPlayer({super.key});

  @override
  ConsumerState createState() => _RecordingPlayerState();
}

class _RecordingPlayerState extends ConsumerState<RecordingPlayer> {
  final player = micMan.player;

  late final Timer timer;

  var pState = PlayerState.isStopped;

  @override
  void initState() {
    timer = Timer.periodic(
      const Duration(microseconds: 200),
      (timer) {
        if (pState != player.playerState) {
          pState = player.playerState;
          setState(() {});
        }
      },
    );
    super.initState();
  }

  Future<void> play(String uri) async {
    await player.startPlayer(fromURI: uri, codec: Codec.opusWebM);
    setState(() {});
  }

  Future<void> pause() async {
    await player.pausePlayer();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final recording = ref.watch(recordingUrlProvider);

    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          player.isPlaying
              ? IconButton(
                  onPressed:
                      recording.isEmpty ? null : () async => await pause(),
                  icon: const Icon(Icons.pause),
                )
              : IconButton(
                  onPressed:
                      recording.isEmpty ? null : () async => await play(recording),
                  icon: const Icon(Icons.play_arrow),
                ),
        ],
      ),
    );
  }
}
