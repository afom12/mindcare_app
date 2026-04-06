import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Non-clinical UI support when distress keywords appear — encourages real-world help.
Future<void> showCrisisSupportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(ctx).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: AppColors.teal.withValues(alpha: 0.9)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You deserve real support',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MindCare AI is not a crisis service. If you are in immediate danger, '
                    'please contact local emergency services right away.',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.45, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'You can also reach a crisis line (US): call or text 988 for the Suicide & Crisis Lifeline. '
                    'If you are outside the US, search for a crisis line in your country.',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('I understand'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
