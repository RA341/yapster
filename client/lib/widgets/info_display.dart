import 'dart:async';

import 'package:client/consts.dart';
import 'package:client/providers.dart';
import 'package:client/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfoDisplay extends ConsumerWidget {
  const InfoDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobId = ref.watch(jobIdProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: 600,
        height: 320,
        decoration: BoxDecoration(
          color: outerDialogBox,
          borderRadius: BorderRadius.circular(20),
        ),
        child: jobId.isEmpty
            ? const Center(
                child: Text(
                  'No analysis found, try yapping something',
                  style: TextStyle(fontSize: 25),
                ),
              ).animate().fadeIn()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: genderBoxColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: GenderAnalysis(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      width: 575,
                      height: 220,
                      decoration: BoxDecoration(
                        color: transcriptionBoxColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: TranscriptionView(),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }
}

class TranscriptionView extends ConsumerStatefulWidget {
  const TranscriptionView({super.key});

  @override
  ConsumerState createState() => _TranscriptionViewState();
}

class _TranscriptionViewState extends ConsumerState<TranscriptionView> {
  late final Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      ref.invalidate(transcriptionStatusProvider);
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transcription = ref.watch(transcriptionStatusProvider);

    return transcription.when(
      data: (data) {
        if (data.isEmpty) {
          return generateText('transcribing, get a coffee')
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 900.ms)
              .then(duration: 900.ms)
              .fadeOut(duration: 900.ms);
        } else if (data == failedString) {
          timer.cancel();
          return generateText('Error transcribing, try again')
              .animate()
              .fadeIn()
              .shimmer(duration: 200.ms);
        } else if (data == emptyResultString) {
          timer.cancel();
          return generateText(
                  'No transcription retrieved\nYour yaps were too powerful!!')
              .animate()
              .fadeIn();
        }
        timer.cancel();
        return SingleChildScrollView(
                child: generateText(data).animate().fadeIn())
            .animate()
            .fadeIn();
      },
      error: (error, stackTrace) => generateText('Error transcribing\n$error'),
      loading: () {
        return generateText('transcribing, get a coffee')
            .animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 900.ms)
            .then(duration: 900.ms)
            .fadeOut(duration: 900.ms);
      },
    );
  }
}

class GenderAnalysis extends ConsumerStatefulWidget {
  const GenderAnalysis({super.key});

  @override
  ConsumerState createState() => _GenderAnalysisState();
}

class _GenderAnalysisState extends ConsumerState<GenderAnalysis> {
  late final Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      ref.invalidate(genderStatusProvider);
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gender = ref.watch(genderStatusProvider);

    return gender.when(
      data: (data) {
        if (data.isEmpty) {
          return generateText("Analyzing gender, what's for dinner")
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 900.ms)
              .then(duration: 900.ms)
              .fadeOut(duration: 900.ms);
        } else if (data == failedString) {
          timer.cancel();
          return generateText('Error detecting gender, try again')
              .animate()
              .fadeIn()
              .shimmer(duration: 200.ms);
        } else if (data == emptyResultString) {
          timer.cancel();
          return generateText('No gender detected\nAre you a robot ?')
              .animate()
              .fadeIn();
        }
        timer.cancel();
        return SingleChildScrollView(
                child: generateText(data).animate().fadeIn())
            .animate()
            .fadeIn();
      },
      error: (error, stackTrace) =>
          generateText('Error analyzing gender\n$error'),
      loading: () => generateText("Analyzing gender, what's for dinner")
          .animate(onPlay: (controller) => controller.repeat())
          .fadeIn(duration: 900.ms)
          .then(duration: 900.ms)
          .fadeOut(duration: 900.ms),
    );
  }
}

Widget generateText(String data) {
  return Text(
    data,
    textAlign: TextAlign.center,
    style: const TextStyle(color: Colors.black),
  );
}
