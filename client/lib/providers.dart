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
final uploadRecording = FutureProvider<String>((ref) async {
  return '';
});

final transcriptionProvider = FutureProvider<String>((ref) async {
  return '';
});

final genderProvider = FutureProvider<String>((ref) async {
  return '';
});
