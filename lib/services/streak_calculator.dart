import '../models/mood_entry.dart';

class StreakResult {
  StreakResult({required this.currentStreak, required this.bestStreak});

  final int currentStreak;
  final int bestStreak;
}

/// Computes streaks from mood check-in calendar days (local).
class StreakCalculator {
  StreakResult calculate(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return StreakResult(currentStreak: 0, bestStreak: 0);
    }

    final daySet = <DateTime>{};
    for (final e in entries) {
      final d = e.createdAt;
      daySet.add(DateTime(d.year, d.month, d.day));
    }
    final days = daySet.toList()..sort();

    var best = 0;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        run++;
      } else if (diff > 1) {
        if (run > best) best = run;
        run = 1;
      }
    }
    if (run > best) best = run;

    final today = DateTime.now();
    final todayD = DateTime(today.year, today.month, today.day);

    int current = 0;
    void walk(DateTime start) {
      var d = start;
      while (daySet.contains(d)) {
        current++;
        d = d.subtract(const Duration(days: 1));
      }
    }

    if (daySet.contains(todayD)) {
      walk(todayD);
    } else {
      final y = todayD.subtract(const Duration(days: 1));
      if (daySet.contains(y)) {
        walk(y);
      }
    }

    return StreakResult(currentStreak: current, bestStreak: best);
  }
}
