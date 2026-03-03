// lib/presentation/widgets/audio/mini_audio_player.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/audio_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class MiniAudioPlayer extends ConsumerWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioProvider);
    if (!audio.hasActiveSession) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Quran icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      audio.currentSurahNumber != null
                          ? 'Surah ${audio.currentSurahNumber}'
                          : 'Quran',
                      style: theme.textTheme.labelSmall,
                    ),
                    Text(
                      'Ayah ${audio.currentAyahIndex + 1}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              // Speed chip
              _SpeedChip(speed: audio.speed),
              const SizedBox(width: 8),
              // Previous
              Semantics(
                label: 'Previous ayah',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 22,
                  onPressed: () => ref.read(audioProvider.notifier).previous(),
                  tooltip: 'Previous',
                ),
              ),
              // Play/Pause
              Semantics(
                label: audio.isPlaying ? 'Pause' : 'Play',
                button: true,
                child: IconButton(
                  icon: Icon(
                    audio.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: AppColors.accent,
                    size: 36,
                  ),
                  onPressed: () {
                    if (audio.isPlaying) {
                      ref.read(audioProvider.notifier).pause();
                    } else {
                      ref.read(audioProvider.notifier).play();
                    }
                  },
                ),
              ),
              // Next
              Semantics(
                label: 'Next ayah',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 22,
                  onPressed: () => ref.read(audioProvider.notifier).next(),
                  tooltip: 'Next',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedChip extends ConsumerWidget {
  final double speed;
  const _SpeedChip({required this.speed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _cycleSpeed(ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${speed}x',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  void _cycleSpeed(WidgetRef ref) {
    final speeds = AppConstants.audioSpeeds;
    final currentIdx = speeds.indexWhere((s) => (s - speed).abs() < 0.01);
    final nextIdx = (currentIdx + 1) % speeds.length;
    ref.read(audioProvider.notifier).setSpeed(speeds[nextIdx]);
  }
}
