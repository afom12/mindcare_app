import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/therapist_models.dart';
import '../../providers/therapist_provider.dart';
import '../../services/crisis_detector.dart';
import '../../widgets/crisis_therapist_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_in.dart';

/// Human therapist messaging — completely separate from AI chat.
class TherapistChatScreen extends StatefulWidget {
  const TherapistChatScreen({super.key});

  @override
  State<TherapistChatScreen> createState() => _TherapistChatScreenState();
}

class _TherapistChatScreenState extends State<TherapistChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TherapistProvider>().refreshMessages();
      _startPolling();
    });
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      final tp = context.read<TherapistProvider>();
      if (tp.connection.canUseTherapistChat) {
        tp.refreshMessages();
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _send(TherapistProvider tp) async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    if (CrisisDetector.shouldFlag(text)) {
      final request = await showCrisisTherapistDialog(context);
      if (!mounted) return;
      if (request == true) {
        await context.read<TherapistProvider>().requestTherapistSupport();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('We shared your request with the care team.')),
        );
      }
      return;
    }
    final toSend = text;
    _input.clear();
    await tp.sendTherapistMessage(toSend);
    _scrollBottom();
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TherapistProvider>();
    final thread = tp.threadMessages;

    if (!tp.connection.canUseTherapistChat) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBottom());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (tp.messagesLoading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: thread.isEmpty
              ? const EmptyState(
                  title: 'No messages yet',
                  subtitle:
                      'Say hello when you feel ready. Your therapist will respond during their available hours.',
                  icon: Icons.mark_chat_unread_rounded,
                )
              : ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  itemCount: thread.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final m = thread[i];
                    return FadeIn(
                      delay: Duration(milliseconds: 20 * i.clamp(0, 12)),
                      child: _TherapistBubble(
                        message: m,
                        onRetry: m.delivery == TherapistMessageDelivery.failed
                            ? () => context.read<TherapistProvider>().retryOptimisticMessage(m.id)
                            : null,
                      ),
                    );
                  },
                ),
        ),
        if (tp.lastError != null && tp.messages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              tp.lastError!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.error),
            ),
          ),
        _TherapistInputBar(
          controller: _input,
          sending: tp.sending,
          onSend: () => _send(tp),
        ),
      ],
    );
  }
}

class _TherapistBubble extends StatelessWidget {
  const _TherapistBubble({
    required this.message,
    this.onRetry,
  });

  final TherapistThreadMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final fromMe = message.isFromStudent;
    final time = DateFormat.jm().format(message.timestamp);
    final pending = message.delivery == TherapistMessageDelivery.pending;
    final failed = message.delivery == TherapistMessageDelivery.failed;
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fromMe
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.9)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(fromMe ? 18 : 4),
              bottomRight: Radius.circular(fromMe ? 4 : 18),
            ),
            border: Border.all(
              color: failed
                  ? AppColors.error.withValues(alpha: 0.6)
                  : (fromMe ? Colors.transparent : AppColors.line.withValues(alpha: 0.6)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: fromMe ? Colors.white : AppColors.ink,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: fromMe ? Colors.white70 : AppColors.inkMuted,
                          ),
                    ),
                    if (pending) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: fromMe ? Colors.white70 : AppColors.teal,
                        ),
                      ),
                    ],
                    if (failed && onRetry != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: onRetry,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: fromMe ? Colors.white : AppColors.error,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TherapistInputBar extends StatelessWidget {
  const _TherapistInputBar({
    required this.controller,
    required this.onSend,
    required this.sending,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + inset),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Message your therapist…',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: 'Send message to therapist',
              button: true,
              child: FilledButton(
                onPressed: sending ? null : onSend,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                child: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
