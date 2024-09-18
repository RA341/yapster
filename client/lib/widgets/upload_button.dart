import 'package:client/consts.dart';
import 'package:client/providers.dart';
import 'package:client/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isUploadingProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

class UploadAndAnalyzeButton extends ConsumerWidget {
  const UploadAndAnalyzeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingUrl = ref.watch(recordingUrlProvider);
    final jobId = ref.watch(jobIdProvider);
    final isUploading = ref.watch(isUploadingProvider);

    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: outerDialogBox,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: isUploading
            ? [
                const CircularProgressIndicator(),
                const Text('Uploading'),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: recordingUrl.isEmpty
                      ? null
                      : () async {
                          if (jobId.isNotEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('You have already submitted'),
                                content: const Text(
                                  'Record new audio to submit again',
                                ),
                                actionsAlignment: MainAxisAlignment.center,
                                actions: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  )
                                ],
                              ),
                            );
                            return;
                          }

                          ref.read(isUploadingProvider.notifier).state = true;

                          final blobUrl = ref.read(recordingUrlProvider);
                          final id = await api.uploadBlobUrlToServer(blobUrl);

                          if (id.isEmpty) {
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Error uploading recording, try again',
                                ),
                                actionsAlignment: MainAxisAlignment.center,
                                actions: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  )
                                ],
                              ),
                            );
                          } else {
                            ref.read(jobIdProvider.notifier).state = id;
                          }

                          ref.read(isUploadingProvider.notifier).state = false;
                        },
                ),
                const Text('Analyze Audio')
              ],
      ),
    );
  }
}
