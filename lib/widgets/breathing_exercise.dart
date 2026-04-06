import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Guided 4-4-4-4 box breathing with animated ring.
class BreathingExercise extends StatefulWidget {
  const BreathingExercise({super.key});

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 16))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        final phase = (t * 4).floor() % 4;
        final labels = ['Breathe in', 'Hold', 'Breathe out', 'Hold'];
        final scale = 0.88 + 0.12 * math.sin(t * 2 * math.pi);

        return Column(
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.teal.withValues(alpha: 0.35),
                      AppColors.sky.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.25),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.self_improvement_rounded, size: 56, color: AppColors.teal),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              labels[phase],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Follow the circle — about 4 seconds per step.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        );
      },
    );
  }
}
