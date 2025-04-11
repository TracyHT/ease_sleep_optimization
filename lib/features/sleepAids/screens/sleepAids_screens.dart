import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SleepaidsScreens extends ConsumerWidget {
  const SleepaidsScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Aids')),
      body: const Center(child: Text('This is Sleep Aids Screen')),
    );
  }
}
