import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../models/mood_entry.dart';

/// Simple weekly bar chart: count of check-ins per weekday (last 7 days window).
class MoodWeekChart extends StatelessWidget {
  const MoodWeekChart({super.key, required this.entries});

  final List<MoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final buckets = List<int>.filled(7, 0);
    final labels = <String>[];

    for (var i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      labels.add(DateFormat.E().format(d));
      for (final e in entries) {
        final ed = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
        if (ed == DateTime(d.year, d.month, d.day)) {
          buckets[i]++;
        }
      }
    }

    final peak = buckets.reduce((a, b) => a > b ? a : b);
    final maxY = (peak + 1).clamp(2, 12).toDouble();

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 12),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, m) => Text(
                    v.toInt().toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        labels[i],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.inkMuted),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < 7; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: buckets[i].toDouble(),
                      width: 14,
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.teal.withValues(alpha: 0.85),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
                        color: AppColors.teal.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
