import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/main_shell_controller.dart';
import '../../providers/mood_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../providers/therapist_provider.dart';
import '../../models/therapist_models.dart';
import '../../services/greeting_catalog.dart';
import '../../services/streak_calculator.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/therapist_request_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TherapistProvider>().refreshStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.name?.trim();
    final greeting = context.read<GreetingCatalog>().greetingForHome(name);

    final mood = context.watch<MoodProvider>();
    final weekCount = mood.entries.where((e) {
      final d = DateTime.now().difference(e.createdAt);
      return d.inDays < 7;
    }).length;
    final streak = StreakCalculator().calculate(mood.entries);

    final privacy = context.watch<PrivacyProvider>();
    final therapist = context.watch<TherapistProvider>();
    final chat = context.watch<ChatProvider>();
    String? lastUserPreview;
    if (!privacy.hideChatPreviews) {
      for (final m in chat.messages.reversed) {
        if (m.role == ChatRole.user && m.text.trim().isNotEmpty) {
          final t = m.text.trim();
          lastUserPreview = t.length > 72 ? '${t.substring(0, 72)}…' : t;
          break;
        }
      }
    }

    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FadeIn(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.12),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.spa_rounded, color: AppColors.teal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              'How are you feeling today? Move at your own pace.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.inkMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FadeIn(
                  delay: const Duration(milliseconds: 80),
                  child: _TherapistHomeCard(
                    loading: therapist.statusLoading,
                    connection: therapist.connection,
                    onTalk: () => showTherapistRequestModal(context),
                    onOpenSupport: () => context.read<MainShellController>().goTherapist(),
                  ),
                ),
              ),
            ),
            if (lastUserPreview != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_open_rounded, size: 18, color: AppColors.teal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Last note: $lastUserPreview',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: _HeroCard(
                title: 'A quiet moment',
                subtitle: 'Speak with MindCare AI in a calm, private chat.',
                onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Start Chat',
                      color: AppColors.teal,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.edit_note_rounded,
                      label: 'Log Mood',
                      color: AppColors.slateSecondary,
                      onTap: () => context.read<MainShellController>().goMood(),
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.spa_rounded,
                      label: 'Calm tools',
                      color: AppColors.tealDark,
                      onTap: () => context.read<MainShellController>().goCalm(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.insights_rounded,
                      label: 'Insights',
                      color: AppColors.amber,
                      onTap: () => context.read<MainShellController>().goInsights(),
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverToBoxAdapter(
              child: Text(
                'This week',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _StatPill(
                      label: 'Check-ins',
                      value: '$weekCount',
                      hint: 'last 7 days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatPill(
                      label: 'Streak',
                      value: '${streak.currentStreak}d',
                      hint: streak.currentStreak == 0 ? 'log to begin' : 'keep it gentle',
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: [
                AppColors.teal,
                AppColors.tealDark,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _TherapistHomeCard extends StatelessWidget {
  const _TherapistHomeCard({
    required this.loading,
    required this.connection,
    required this.onTalk,
    required this.onOpenSupport,
  });

  final bool loading;
  final TherapistConnectionState connection;
  final VoidCallback onTalk;
  final VoidCallback onOpenSupport;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
        ),
        child: const Center(
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.teal),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent_rounded, color: AppColors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _statusTitle(connection.status),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _statusSubtitle(connection),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted, height: 1.35),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: connection.canUseTherapistChat ? onOpenSupport : onTalk,
              child: Text(
                connection.canUseTherapistChat ? 'Open therapist chat' : 'Talk to a therapist',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusTitle(TherapistAssignmentStatus s) {
    switch (s) {
      case TherapistAssignmentStatus.none:
        return 'No therapist assigned';
      case TherapistAssignmentStatus.pending:
        return 'Request pending';
      case TherapistAssignmentStatus.assigned:
        return 'Therapist assigned';
      case TherapistAssignmentStatus.closed:
        return 'Support closed';
    }
  }

  String _statusSubtitle(TherapistConnectionState c) {
    switch (c.status) {
      case TherapistAssignmentStatus.assigned:
        return c.therapist?.name != null
            ? 'Connected with ${c.therapist!.name}. Human support is separate from AI chat.'
            : 'You are connected with a therapist.';
      case TherapistAssignmentStatus.pending:
        return 'We are matching you with someone from the care team.';
      case TherapistAssignmentStatus.closed:
        return 'You can request support again when you are ready.';
      case TherapistAssignmentStatus.none:
        return 'Optional licensed support — different from the AI companion.';
    }
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color.withValues(alpha: 0.95)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(hint, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}
