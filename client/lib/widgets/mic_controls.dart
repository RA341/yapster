import 'package:client/consts.dart';
import 'package:client/widgets/mic.dart';
import 'package:client/widgets/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MicTrackControls extends ConsumerWidget {
  const MicTrackControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: 200,
        height: 130,
        decoration: BoxDecoration(
          color: outerDialogBox,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Expanded(
                flex: 50,
                child: MicRecorder(),
              ),
              Expanded(
                flex: 1,
                child: Container(color: Colors.blueGrey, height: 100, width: 1),
              ),
              const Expanded(
                flex: 50,
                child: RecordingPlayer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
