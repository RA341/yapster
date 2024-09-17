import 'package:client/service/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// url and transcription provider
final recordingUrlProvider = StateProvider<String>((ref) {
  return '';
});

final jobIdProvider = StateProvider<String>((ref) {
  return '';
});

///////////////////////////////////////////////////////////////////////////
// api calls
final transcriptionStatusProvider = FutureProvider.autoDispose<String>((ref) async {
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
