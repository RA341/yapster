import 'package:client/consts.dart';
import 'package:client/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscardButton extends ConsumerWidget {
  const DiscardButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingUrl = ref.watch(recordingUrlProvider);

    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: outerDialogBox,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: recordingUrl.isEmpty
                ? null
                : () {
                    ref.read(recordingUrlProvider.notifier).state = '';
                  },
          ),
          const Text('Discard Audio')
        ],
      ),
    );
  }
}
