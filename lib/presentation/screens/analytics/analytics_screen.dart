// lib/presentation/screens/analytics/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(readingProgressProvider);
    final surahListAsync = ref.watch(surahListProvider);
    final hasanatAsync = ref.watch(hasanatProvider);
    final theme = Theme.of(context);
    final weeklyCounts =
        ref.watch(readingProgressProvider.notifier).weeklyAyahCounts;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak cards
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Current Streak',
                    value: '${progress.currentStreak} days 🔥',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFE05A2B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'Longest Streak',
                    value: '${progress.longestStreak} days ⭐',
                    icon: Icons.emoji_events,
                    color: const Color(0xFFC97B2A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Completion progress
            surahListAsync.when(
              data: (surahs) {
                final surahMap = {for (final s in surahs) s.number: s.numberOfAyahs};
                final completedSurahs =
                    progress.completedSurahCount(surahMap);
                return Row(
                  children: [
                    Expanded(
                      child: _ProgressCard(
                        label: 'Surahs',
                        current: completedSurahs,
                        total: 114,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProgressCard(
                        label: 'Juz',
                        current: 0, // Juz completion requires juz-ayah mapping
                        total: 30,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(height: 80),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Weekly chart
            Text('This Week', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            _WeeklyChart(counts: weeklyCounts),
            const SizedBox(height: 24),

            // Hasanāt Section
            hasanatAsync.when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hasanāt', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: "Today's Hasanāt",
                          value: _format(stats.todayHasanat),
                          icon: Icons.auto_awesome,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          label: 'Total Hasanāt',
                          value: _format(stats.totalHasanat),
                          icon: Icons.favorite,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      AppConstants.hasanatDisclaimer,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Reading history list
            Text('Recent Sessions', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (progress.recentSessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No sessions yet — start reading!',
                      style: theme.textTheme.bodySmall),
                ),
              )
            else
              ...progress.recentSessions.reversed.take(10).map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: AppColors.accent),
                        const SizedBox(width: 12),
                        Text(
                          '${_dateLabel(s.date)} — Surah ${s.surahNumber}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        Text('${s.ayahsRead} ayahs',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}';
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String label;
  final int current;
  final int total;

  const _ProgressCard({
    required this.label,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = current / total;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text('$current / $total',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.accent.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<int> counts;
  const _WeeklyChart({required this.counts});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b);
    final effectiveMax = max == 0 ? 1 : max;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final count = i < counts.length ? counts[i] : 0;
                final heightRatio = count / effectiveMax;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (count > 0)
                          Text(
                            '$count',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: AppColors.accent,
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: (heightRatio * 60).clamp(4.0, 60.0),
                          decoration: BoxDecoration(
                            color: count > 0
                                ? AppColors.accent
                                : AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Text(
                  _days[i],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
