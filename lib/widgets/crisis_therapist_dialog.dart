import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Returns `true` if user chose to request therapist support from crisis UI.
Future<bool?> showCrisisTherapistDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(Icons.favorite_rounded, color: AppColors.teal.withValues(alpha: 0.9)),
            const SizedBox(width: 10),
            const Expanded(child: Text('You are not alone')),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'We heard something that sounds really heavy. MindCare is not a crisis service — '
            'if you are in immediate danger, please contact local emergency services.\n\n'
            'Would you like to connect with a therapist for additional human support?',
            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
            child: const Text('Request therapist'),
          ),
        ],
      );
    },
  );
}
