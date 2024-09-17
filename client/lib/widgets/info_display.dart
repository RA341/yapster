import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfoDisplay extends ConsumerWidget {
  const InfoDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: 600,
        height: 320,
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Gender shown here'),
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
                    child: SingleChildScrollView(child: Text(dummyDate)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const dummyDate = "Trancription";
