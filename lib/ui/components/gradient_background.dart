import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<double>? stops;
  final double primaryOpacity;

  const GradientBackground({
    super.key,
    required this.child,
    this.stops,
    this.primaryOpacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withValues(alpha: primaryOpacity),
            colorScheme.surface,
            colorScheme.surface,
          ],
          stops: stops ?? const [0.0, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}