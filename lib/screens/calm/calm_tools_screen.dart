import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/main_shell_controller.dart';
import '../../widgets/breathing_exercise.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/gradient_background.dart';

class CalmToolsScreen extends StatelessWidget {
  const CalmToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            FadeIn(
              child: Text(
                'Calm tools',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A pocket of calm. Use these anytime — no rush, no score.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 24),
            FadeIn(
              delay: const Duration(milliseconds: 120),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
                ),
                child: const BreathingExercise(),
              ),
            ),
            const SizedBox(height: 18),
            FadeIn(
              delay: const Duration(milliseconds: 220),
              child: _QuickCalm(
                icon: Icons.edit_note_rounded,
                title: 'Log a mood',
                subtitle: 'Name what you feel — it often softens the edge.',
                onTap: () => context.read<MainShellController>().goMood(),
              ),
            ),
            const SizedBox(height: 10),
            FadeIn(
              delay: const Duration(milliseconds: 300),
              child: _QuickCalm(
                icon: Icons.insights_outlined,
                title: 'See insights',
                subtitle: 'Notice patterns with kindness, not judgment.',
                onTap: () => context.read<MainShellController>().goInsights(),
              ),
            ),
            const SizedBox(height: 10),
            FadeIn(
              delay: const Duration(milliseconds: 380),
              child: _QuickCalm(
                icon: Icons.nightlight_round,
                title: 'Dim the noise',
                subtitle: 'Try dark mode in Profile for a softer evening.',
                onTap: () => context.read<MainShellController>().goProfile(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _QuickCalm extends StatelessWidget {
  const _QuickCalm({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.teal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
