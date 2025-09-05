import 'package:flutter/material.dart';

class LargeSuggestionCard extends StatelessWidget {
  final VoidCallback? onTap;

  const LargeSuggestionCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 212,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white60),
        ),
      ),
    );
  }
}
