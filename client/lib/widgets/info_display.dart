import 'dart:async';

import 'package:client/providers.dart';
import 'package:client/service/api.dart';
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
          color: Colors.purple,
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
                        color: Colors.blueAccent,
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
                        color: Colors.blueAccent,
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
          return const Text('transcribing, get a coffee')
              .animate()
              .fadeIn()
              .shimmer(duration: 200.ms, size: 20);
        } else if (data == failedString) {
          timer.cancel();
          return const Text('Error transcribing, try again')
              .animate()
              .fadeIn()
              .shimmer(duration: 200.ms);
        } else if (data == emptyResultString) {
          timer.cancel();
          return const Text(
                  'No transcription retrieved, your yaps were too powerful')
              .animate()
              .fadeIn();
        }
        timer.cancel();
        return SingleChildScrollView(child: Text(data).animate().fadeIn())
            .animate()
            .fadeIn();
      },
      error: (error, stackTrace) => Text('Error transcribing\n$error'),
      loading: () {
        return const Text('transcribing, get a coffee')
            .animate()
            .fadeIn()
            .shimmer(duration: 200.ms);
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
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
          return const Text("Analyzing gender, what's for dinner")
              .animate()
              .fadeIn()
              .shimmer(duration: 200.ms, size: 20);
        } else if (data == failedString) {
          timer.cancel();
          return const Text('Error transcribing, try again')
              .animate()
              .fadeIn()
              .shimmer(duration: 200.ms);
        } else if (data == emptyResultString) {
          timer.cancel();
          return const Text('No gender detected, you sure you are not a robot')
              .animate()
              .fadeIn();
        }
        timer.cancel();
        return SingleChildScrollView(child: Text(data).animate().fadeIn())
            .animate()
            .fadeIn();
      },
      error: (error, stackTrace) => Text('Error analyzing gender\n$error'),
      loading: () {
        return const Text("Analyzing gender, what's for dinner")
            .animate()
            .fadeIn()
            .shimmer(duration: 200.ms);
      },
    );
  }
}
