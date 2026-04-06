import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/primary_button.dart';

class _MoodOption {
  const _MoodOption(this.label, this.emoji);
  final String label;
  final String emoji;
}

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  static const _options = [
    _MoodOption('Calm', '😌'),
    _MoodOption('Happy', '😊'),
    _MoodOption('Tired', '😔'),
    _MoodOption('Anxious', '😰'),
    _MoodOption('Sad', '😢'),
    _MoodOption('Stressed', '😣'),
    _MoodOption('Hopeful', '🌤️'),
    _MoodOption('Overwhelmed', '🌊'),
  ];

  _MoodOption? _selected;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick how you feel — there is no wrong answer.')),
      );
      return;
    }
    await context.read<MoodProvider>().addEntry(
          label: _selected!.label,
          emoji: _selected!.emoji,
          note: _note.text,
        );
    if (!mounted) return;
    _note.clear();
    setState(() => _selected = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved gently. You can revisit this anytime.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mood = context.watch<MoodProvider>();

    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'Mood check-in',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Text(
                'Name what you feel. It helps you notice patterns without judgment.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _options.map((o) {
                  final sel = _selected?.label == o.label;
                  return ChoiceChip(
                    label: Text('${o.emoji}  ${o.label}'),
                    selected: sel,
                    onSelected: (_) => setState(() => _selected = o),
                    selectedColor: AppColors.teal.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: sel ? AppColors.tealDark : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: TextField(
                controller: _note,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Optional note — a sentence is enough.',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: PrimaryButton(label: 'Save entry', onPressed: _save),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: Text(
                'Previous logs',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (mood.isLoading)
              const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.teal),
                )),
              )
            else if (mood.entries.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  title: 'No entries yet',
                  subtitle: 'When you log how you feel, a gentle history will appear here.',
                  icon: Icons.auto_awesome_rounded,
                ),
              )
            else
              SliverList.separated(
                itemCount: mood.entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final e = mood.entries[i];
                  final when = DateFormat.yMMMd().add_jm().format(e.createdAt);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.label,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                when,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.inkMuted,
                                    ),
                              ),
                              if (e.note != null && e.note!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  e.note!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        height: 1.35,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
