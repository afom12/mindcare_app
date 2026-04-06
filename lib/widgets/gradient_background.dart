import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? const [
            Color(0xFF0F1719),
            Color(0xFF152428),
            Color(0xFF1A2E32),
          ]
        : const [
            Color(0xFFF5FAFB),
            Color(0xFFE8F6F4),
            Color(0xFFE8F4FF),
          ];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// Soft teal–blue hero orb for onboarding / headers.
class SoftHeroOrb extends StatelessWidget {
  const SoftHeroOrb({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.teal.withValues(alpha: 0.35),
            AppColors.sky.withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}
