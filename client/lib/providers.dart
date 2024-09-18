import 'dart:async';

import 'package:client/service/api.dart';
import 'package:client/service/microphone_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///////////////////////////////////////////////////////////////////////////
// mic controls
final isRecordingProvider = Provider<bool>((ref) {
  return micMan.recorder.isRecording;
});

final isPlayingProvider = Provider<bool>((ref) {
  final timer = Timer.periodic(
    const Duration(milliseconds: 200),
    (timer) {
      ref.invalidateSelf();
    },
  );
  ref.onDispose(timer.cancel);

  return micMan.player.isPlaying;
});

///////////////////////////////////////////////////////////////////////////
// url and transcription provider
final recordingUrlProvider = StateProvider<String>((ref) {
  return '';
});

final jobIdProvider = StateProvider<String>((ref) {
  return '';
});

///////////////////////////////////////////////////////////////////////////
// api calls
final transcriptionStatusProvider =
    FutureProvider.autoDispose<String>((ref) async {
  final jobId = ref.read(jobIdProvider);
  if (jobId.isEmpty) {
    return '';
  }
  return api.getJobStatus(jobId: jobId, whichJob: 'transcription');
});

final genderStatusProvider = FutureProvider.autoDispose<String>((ref) async {
  final jobId = ref.read(jobIdProvider);
  if (jobId.isEmpty) {
    return '';
  }
  return api.getJobStatus(jobId: jobId, whichJob: 'gender');
});
