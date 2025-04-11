import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SleepmodeScreen extends ConsumerWidget {
  const SleepmodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Mode')),
      body: const Center(child: Text('This is Sleep Screen')),
    );
  }
}
