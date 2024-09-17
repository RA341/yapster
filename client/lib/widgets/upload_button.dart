import 'package:client/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingUrl = ref.watch(recordingUrlProvider);

    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: recordingUrl.isEmpty ? null : () {},
          ),
          const Text('Upload Audio')
        ],
      ),
    );
  }
}
