import '../models/emotional_insight.dart';
import '../models/mood_entry.dart';

/// Pure local analysis of mood entries — no network.
class InsightsEngine {
  EmotionalInsight buildWeeklyInsight(List<MoodEntry> entries) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    final week = entries.where((e) => e.createdAt.isAfter(start)).toList();

    final label =
        '${_d(start)} – ${_d(now)}';

    final counts = <String, int>{};
    for (final e in week) {
      counts[e.label] = (counts[e.label] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final dominant = <String, int>{};
    for (var i = 0; i < sorted.length && i < 4; i++) {
      dominant[sorted[i].key] = sorted[i].value;
    }

    final patterns = <String>[];
    if (week.isEmpty) {
      patterns.add('No check-ins this week yet — gentle consistency helps you notice patterns.');
    } else {
      if (sorted.isNotEmpty) {
        patterns.add('Your most logged mood was “${sorted.first.key}” (${sorted.first.value} times).');
      }
      final anxious = counts['Anxious'] ?? 0;
      final stressed = counts['Stressed'] ?? 0;
      if (anxious + stressed >= 3) {
        patterns.add('Stress and anxiety showed up more often — your body may be asking for rest.');
      }
      final calm = counts['Calm'] ?? 0;
      final happy = counts['Happy'] ?? 0;
      if (calm + happy >= 3) {
        patterns.add('You also made space for calmer or brighter moments — that matters.');
      }
    }

    final suggestions = <String>[
      'Try a 3-minute breathing reset in Calm Tools when the day feels loud.',
      'Name one small win before bed — it trains your mind to notice balance.',
      'If worry spikes, write one sentence in Mood notes; it often shrinks the noise.',
    ];

    if (week.length < 3) {
      suggestions.insert(
        0,
        'A few more mood check-ins this week will make insights more accurate.',
      );
    }

    final summary = week.isEmpty
        ? 'This week is still open — your next check-in will start the story.'
        : 'You checked in ${week.length} time${week.length == 1 ? '' : 's'} this week. '
            'Trends are private, kind, and only for your awareness.';

    return EmotionalInsight(
      weekLabel: label,
      summary: summary,
      patterns: patterns,
      suggestions: suggestions.take(5).toList(),
      dominantMoods: dominant,
      checkInCount: week.length,
    );
  }

  String _d(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
