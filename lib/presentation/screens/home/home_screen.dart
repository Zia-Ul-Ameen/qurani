// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/ramadan_mode_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(readingProgressProvider);
    final hasanatAsync = ref.watch(hasanatProvider);
    final ramadan = ref.watch(ramadanServiceProvider).getProgress();
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Row(
              children: [
                Text(
                  'بِسْمِ اللّه',
                  style: TextStyle(
                    fontFamily: 'KFGQPCUthmanTaha',
                    fontSize: 18,
                    color: AppColors.accent,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.go('/settings'),
                tooltip: 'Settings',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Greeting
                Text(
                  _greeting(),
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  'Keep up your beautiful habit.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Hasanāt Row
                hasanatAsync.when(
                  data: (stats) => _StatRow(
                    today: stats.todayHasanat,
                    total: stats.totalHasanat,
                    streak: progress.currentStreak,
                  ),
                  loading: () => const SizedBox(height: 80),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Resume Reading card
                if (progress.lastSurahNumber > 0)
                  _ResumeCard(
                    surahNumber: progress.lastSurahNumber,
                    ayahNumber: progress.lastAyahNumber,
                    onTap: () => context.push(
                      '/reader/${progress.lastSurahNumber}?ayah=${progress.lastAyahNumber}',
                    ),
                  ),
                if (progress.lastSurahNumber > 0) const SizedBox(height: 16),

                // Ramadan tracker (if active)
                if (ramadan.isRamadan) ...[
                  _RamadanCard(progress: ramadan),
                  const SizedBox(height: 16),
                ],

                // Daily Ayah
                _DailyAyahCard(dayIndex: AppConstants.dailyAyahNumber(now)),
                const SizedBox(height: 80), // MiniPlayer space
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Assalamu Alaikum 🌙';
    if (hour < 12) return 'Sabah al-khayr ☀️';
    if (hour < 17) return 'Assalamu Alaikum 🌤️';
    return 'Masa al-khayr 🌅';
  }
}

class _StatRow extends StatelessWidget {
  final int today;
  final int total;
  final int streak;

  const _StatRow({required this.today, required this.total, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: "Today's Hasanāt",
            value: _format(today),
            icon: Icons.auto_awesome,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Total Hasanāt',
            value: _format(total),
            icon: Icons.favorite,
            color: const Color(0xFFC97B2A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Day Streak',
            value: '$streak 🔥',
            icon: Icons.local_fire_department,
            color: const Color(0xFFE05A2B),
          ),
        ),
      ],
    );
  }

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall, maxLines: 2),
        ],
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final VoidCallback onTap;

  const _ResumeCard({
    required this.surahNumber,
    required this.ayahNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.15),
              AppColors.accentLight.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.play_circle_fill, color: AppColors.accent, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resume Reading', style: theme.textTheme.labelSmall),
                Text('Surah $surahNumber · Ayah $ayahNumber',
                    style: theme.textTheme.titleSmall),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class _RamadanCard extends StatelessWidget {
  final RamadanProgress progress;
  const _RamadanCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A2A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('☪️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Ramadan Khatm', style: theme.textTheme.titleSmall),
              const Spacer(),
              Text('Day ${progress.ramadanDay ?? 1}/30',
                  style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.khatmProgress,
              minHeight: 8,
              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text('${progress.completedDays}/30 Juz completed',
              style: theme.textTheme.bodySmall),
          if (progress.suggestedJuz != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Today: Juz ${progress.suggestedJuz}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DailyAyahCard extends StatelessWidget {
  final int dayIndex;
  const _DailyAyahCard({required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today_outlined, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text("Today's Reflection", style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ayah $dayIndex · Quran',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to read today\'s ayah',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
