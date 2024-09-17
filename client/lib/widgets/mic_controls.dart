import 'dart:async';

import 'package:client/providers.dart';
import 'package:client/service/microphone_manager.dart';
import 'package:client/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';

class MicControls extends ConsumerStatefulWidget {
  const MicControls({super.key});

  @override
  ConsumerState createState() => _MicControlsState();
}

class _MicControlsState extends ConsumerState<MicControls> {
  final recorder = micMan.recorder;
  final player = micMan.player;

  late final StreamSubscription<RecordingDisposition> progress;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    micMan.dispose();
    progress.cancel();
    super.dispose();
  }

  Future<void> startRecording() async {
    await recorder.startRecorder(toFile: 'tmp.webm', codec: Codec.opusWebM);
    setState(() {});
  }

  Future<void> stopRecording() async {
    final url = await recorder.stopRecorder() ?? '';
    ref.read(recordingUrlProvider.notifier).state = url;
    setState(() {});
    print(url);

    // await player.startPlayer(codec: Codec.opusWebM, fromURI: url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: 200,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: recorder.isRecording
                    ? const RecordingIndicator()
                    : const CircleWidget(color: Colors.redAccent, diameter: 20),
              ),
              recorder.isRecording
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async => await stopRecording(),
                          icon: const Icon(Icons.stop),
                        ),
                        const Text('Stop')
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async => await startRecording(),
                          icon: const Icon(Icons.mic),
                        ),
                        const Text('Record')
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}

class RecordingIndicator extends StatefulWidget {
  final double size;
  final Duration pulseDuration;

  const RecordingIndicator({
    super.key,
    this.size = 20,
    this.pulseDuration = const Duration(seconds: 1),
  });

  @override
  _RecordingIndicatorState createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 1.0, end: 0.5).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(_animation.value * 0.5),
                blurRadius: widget.size / 2,
                spreadRadius: widget.size / 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Usage example:
// RecordingIndicator(size: 30)

class CircleWidget extends StatelessWidget {
  final double diameter;
  final Color color;

  const CircleWidget({
    super.key,
    this.diameter = 100.0,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
