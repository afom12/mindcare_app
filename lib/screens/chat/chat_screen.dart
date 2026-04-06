import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/main_shell_controller.dart';
import '../../providers/therapist_provider.dart';
import '../../services/crisis_detector.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/crisis_support_sheet.dart';
import '../../widgets/crisis_therapist_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_in.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  ChatProvider? _chat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      final chat = context.read<ChatProvider>();
      await chat.loadPersisted();
      _chat = chat;
      chat.addListener(_onChatUpdate);
      _scrollToBottom();
    });
  }

  void _onChatUpdate() => _scrollToBottom();

  @override
  void dispose() {
    _chat?.removeListener(_onChatUpdate);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    if (CrisisDetector.shouldFlag(text)) {
      final wantTherapist = await showCrisisTherapistDialog(context);
      if (!mounted) return;
      if (wantTherapist == true) {
        await context.read<TherapistProvider>().requestTherapistSupport();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('We shared your request with the care team.')),
        );
        context.read<MainShellController>().goTherapist();
      } else {
        await showCrisisSupportSheet(context);
      }
      return;
    }
    _input.clear();
    await context.read<ChatProvider>().send(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final messages = chat.messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindCare AI'),
        actions: [
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: () async {
              await chat.clearConversation();
              _scrollToBottom();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: messages.isEmpty
                  ? const EmptyState(
                      title: 'Your space is ready',
                      subtitle:
                          'When you are ready, share a thought below. There is no rush and no wrong way to begin.',
                      icon: Icons.volunteer_activism_rounded,
                    )
                  : ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.only(top: 12, bottom: 120),
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final m = messages[i];
                        return FadeIn(
                          delay: Duration(milliseconds: 30 * (i.clamp(0, 8))),
                          child: ChatBubble(message: m),
                        );
                      },
                    ),
            ),
          ),
          if (chat.isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MindCare is thinking…',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.inkMuted),
                ),
              ),
            ),
          _InputBar(
            controller: _input,
            onSend: _send,
            sending: chat.isTyping,
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
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
      elevation: 6,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + inset),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Write gently — this space is yours…',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: sending
                  ? null
                  : () {
                      if (controller.text.trim().isEmpty) return;
                      onSend();
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
