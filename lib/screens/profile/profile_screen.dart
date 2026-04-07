import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_links.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_exception.dart';
import '../../services/local_notification_service.dart';
import '../../widgets/fade_in.dart';
import '../../widgets/gradient_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final privacy = context.watch<PrivacyProvider>();
    final user = auth.user;

    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            FadeIn(
              child: Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your details stay on this device session and are handled with care.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                    child: Text(
                      (user?.name?.isNotEmpty == true)
                          ? user!.name!.substring(0, 1).toUpperCase()
                          : 'Y',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tealDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name?.trim().isNotEmpty == true ? user!.name!.trim() : 'Friend',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '—',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.inkMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SettingsTile(
              icon: Icons.dark_mode_rounded,
              title: 'Appearance',
              subtitle: 'Dark mode for low-light comfort',
              trailing: Switch.adaptive(
                value: theme.mode == ThemeMode.dark,
                onChanged: (v) {
                  theme.setMode(v ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
            _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Daily mood reminder',
              subtitle: 'Gentle local notification (9:00)',
              trailing: Switch.adaptive(
                value: privacy.dailyReminderEnabled,
                onChanged: (v) async {
                  await privacy.setDailyReminderEnabled(v);
                  if (!context.mounted) return;
                  final notif = context.read<LocalNotificationService>();
                  if (v) {
                    await notif.scheduleDailyMoodReminder();
                  } else {
                    await notif.cancelDailyReminder();
                  }
                },
              ),
            ),
            _SettingsTile(
              icon: Icons.visibility_off_outlined,
              title: 'Hide chat previews',
              subtitle: 'Home hides your last message snippet',
              trailing: Switch.adaptive(
                value: privacy.hideChatPreviews,
                onChanged: (v) => privacy.setHidePreviews(v),
              ),
            ),
            _SettingsTile(
              icon: Icons.pin_outlined,
              title: privacy.hasPin ? 'Change PIN' : 'Set app PIN',
              subtitle: 'Extra privacy when you return to the app',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showPinSheet(context, privacy),
            ),
            _SettingsTile(
              icon: Icons.password_rounded,
              title: 'Change password',
              subtitle: 'Update your account password',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showChangePasswordSheet(context, auth),
            ),
            _SettingsTile(
              icon: Icons.menu_book_outlined,
              title: 'Resources',
              subtitle: 'Articles, tools, and crisis lines from your program',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pushNamed(context, AppRoutes.resources),
            ),
            _SettingsTile(
              icon: Icons.event_available_outlined,
              title: 'Book a session',
              subtitle: 'Request time with a listed therapist',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pushNamed(context, AppRoutes.bookings),
            ),
            _SettingsTile(
              icon: Icons.delete_sweep_outlined,
              title: 'Clear chat history',
              subtitle: 'Removes cached messages on this device',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear chat history?'),
                    content: const Text(
                      'This removes locally saved messages and starts a fresh warm greeting. It does not delete your account.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await context.read<ChatProvider>().clearConversation();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat history cleared gently.')),
                    );
                  }
                }
              },
            ),
            _SettingsTile(
              icon: Icons.shield_outlined,
              title: 'Privacy policy',
              subtitle: 'Opens in your browser',
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () => _openPolicyUrl(
                    context,
                    AppLinks.privacyPolicyUrl,
                    'Set PRIVACY_POLICY_URL when building, e.g. --dart-define=PRIVACY_POLICY_URL=https://…',
                  ),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of service',
              subtitle: 'Opens in your browser',
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () => _openPolicyUrl(
                    context,
                    AppLinks.termsOfServiceUrl,
                    'Set TERMS_OF_SERVICE_URL when building, e.g. --dart-define=TERMS_OF_SERVICE_URL=https://…',
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

Future<void> _openPolicyUrl(BuildContext context, String url, String emptyHint) async {
  if (url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emptyHint)));
    return;
  }
  final u = Uri.tryParse(url);
  if (u == null || !u.hasScheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('That link could not be opened.')),
    );
    return;
  }
  final ok = await launchUrl(u, mode: LaunchMode.externalApplication);
  if (!context.mounted) return;
  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open link.')),
    );
  }
}

Future<void> _showChangePasswordSheet(BuildContext context, AuthProvider auth) async {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Change password',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm new password'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (next.text != confirm.text) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match.')),
                  );
                  return;
                }
                if (next.text.length < 8) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Use at least 8 characters.')),
                  );
                  return;
                }
                try {
                  await auth.changePassword(
                    currentPassword: current.text,
                    newPassword: next.text,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated.')),
                    );
                  }
                } on ApiException catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(e.message)),
                    );
                  }
                }
              },
              child: const Text('Update password'),
            ),
          ],
        ),
      );
    },
  );
  current.dispose();
  next.dispose();
  confirm.dispose();
}

Future<void> _showPinSheet(BuildContext context, PrivacyProvider privacy) async {
  final c1 = TextEditingController();
  final c2 = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              privacy.hasPin ? 'Update PIN' : 'Create PIN',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c1,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN (4–8 digits)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: c2,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final a = c1.text.trim();
                final b = c2.text.trim();
                if (a.length < 4 || a != b) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('PINs should match and be at least 4 digits.')),
                  );
                  return;
                }
                await privacy.setNewPin(a);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN saved. We will ask when you return.')),
                  );
                }
              },
              child: const Text('Save PIN'),
            ),
            if (privacy.hasPin) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await privacy.removePin();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Remove PIN'),
              ),
            ],
          ],
        ),
      );
    },
  );
  c1.dispose();
  c2.dispose();
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
