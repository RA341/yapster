import 'package:client/providers.dart';
import 'package:client/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UploadButton extends HookConsumerWidget {
  const UploadButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingUrl = ref.watch(recordingUrlProvider);
    final jobId = ref.watch(jobIdProvider);
    final isUploading = useState(false);

    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: isUploading.value
            ? [
                const CircularProgressIndicator(),
                const Text('Uploading'),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: recordingUrl.isEmpty
                      ? null
                      : () async {
                          if (jobId.isNotEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('You have already uploaded'),
                                content: const Text(
                                  'Your recording is being analyzed please wait',
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

                          isUploading.value = true;

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

                          isUploading.value = false;
                        },
                ),
                const Text('Upload Audio')
              ],
      ),
    );
  }
}
