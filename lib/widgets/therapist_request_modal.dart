import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/main_shell_controller.dart';
import '../providers/therapist_provider.dart';

Future<void> showTherapistRequestModal(BuildContext context) {
  final shell = context.read<MainShellController>();
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
              child: Consumer<TherapistProvider>(
                builder: (context, tp, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Talk to a therapist',
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You can connect with a licensed therapist for additional support. '
                        'This is not emergency care — if you are in immediate danger, contact local emergency services.',
                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted, height: 1.45),
                      ),
                      const SizedBox(height: 20),
                      if (tp.requestPhase == TherapistRequestPhase.loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(color: AppColors.teal),
                          ),
                        )
                      else if (tp.requestPhase == TherapistRequestPhase.success) ...[
                        const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'A therapist will reach out to you soon.',
                          textAlign: TextAlign.center,
                          style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            tp.resetRequestPhase();
                            shell.goTherapist();
                          },
                          style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                          child: const Text('Done'),
                        ),
                      ] else ...[
                        if (tp.requestPhase == TherapistRequestPhase.error && tp.lastError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              tp.lastError!,
                              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.error),
                            ),
                          ),
                        FilledButton(
                          onPressed: () async {
                            await tp.requestTherapistSupport();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Request support'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Not now'),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}
