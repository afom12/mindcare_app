import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/therapist_models.dart';
import '../../providers/therapist_provider.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/therapist_request_modal.dart';
import 'therapist_chat_screen.dart';

/// Student entry for human support — separate from AI chat and Calm tools.
class TherapistHubScreen extends StatefulWidget {
  const TherapistHubScreen({super.key});

  @override
  State<TherapistHubScreen> createState() => _TherapistHubScreenState();
}

class _TherapistHubScreenState extends State<TherapistHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tp = context.read<TherapistProvider>();
      await tp.refreshStatus();
      if (!mounted) return;
      if (tp.connection.canUseTherapistChat) {
        await tp.refreshMessages(signalNewTherapistReply: false);
        if (mounted) await tp.markTherapistHubViewed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TherapistProvider>();

    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            FadeIn(
              child: Text(
                'Human support',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Licensed professionals are separate from the AI companion. Availability depends on your school or program.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            _StatusCard(
              loading: tp.statusLoading,
              connection: tp.connection,
              onRequest: () => showTherapistRequestModal(context),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: ColoredBox(
                  color: Theme.of(context).cardColor,
                  child: tp.connection.canUseTherapistChat
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Conversation with ${tp.connection.therapist?.name ?? 'your therapist'}',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: TherapistChatScreen(),
                            ),
                          ],
                        )
                      : _NotConnectedBody(
                          status: tp.connection.status,
                          onRequest: () => showTherapistRequestModal(context),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.loading,
    required this.connection,
    required this.onRequest,
  });

  final bool loading;
  final TherapistConnectionState connection;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    final (icon, title, subtitle) = _copyFor(connection.status, connection.therapist?.name);

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: connection.status == TherapistAssignmentStatus.none ? onRequest : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.teal),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, String, String) _copyFor(TherapistAssignmentStatus s, String? name) {
    switch (s) {
      case TherapistAssignmentStatus.assigned:
        return (
          Icons.verified_rounded,
          'Therapist assigned',
          name != null ? 'You are connected with $name.' : 'You are connected with a therapist.',
        );
      case TherapistAssignmentStatus.pending:
        return (
          Icons.hourglass_top_rounded,
          'Request pending',
          'We are matching you with someone. You will be notified when it is ready.',
        );
      case TherapistAssignmentStatus.closed:
        return (
          Icons.folder_shared_outlined,
          'Support closed',
          'This connection has ended. You can request support again if you need to.',
        );
      case TherapistAssignmentStatus.none:
        return (
          Icons.person_search_rounded,
          'No therapist assigned',
          'Tap to request support when you want a human professional.',
        );
    }
  }
}

class _NotConnectedBody extends StatelessWidget {
  const _NotConnectedBody({
    required this.status,
    required this.onRequest,
  });

  final TherapistAssignmentStatus status;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    if (status == TherapistAssignmentStatus.pending) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Your request is with our care team. You do not need to do anything else right now.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted, height: 1.45),
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety_outlined, size: 48, color: AppColors.teal.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(
              'You are not connected to a therapist yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'When you are ready, you can request to be matched. This is optional and separate from the AI chat.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRequest,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Request therapist support'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
