// lib/presentation/screens/reader/surah_reader_screen.dart
// Full-featured Surah Reader with audio, hasanāt tracking, bookmarks, scroll.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../data/models/ayah_model.dart';
import '../../../data/models/surah_detail_model.dart';
import '../../../providers/providers.dart';
import '../../../providers/audio_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/audio_player_service.dart';
import '../../widgets/ayah/ayah_card.dart';
import '../../widgets/audio/mini_audio_player.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_state_widget.dart';

class SurahReaderScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int startAyah;

  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    this.startAyah = 1,
  });

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  int _activeAyahIndex = -1;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _activeAyahIndex = widget.startAyah - 1;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final audio = ref.watch(audioProvider);
    final reduceMotion = ref.watch(accessibilityProvider);

    // Derive active ayah from audio state
    final audioAyahIndex = audio.hasActiveSession &&
            audio.currentSurahNumber == widget.surahNumber
        ? audio.currentAyahIndex
        : -1;

    final detailAsync = ref.watch(surahDetailProvider(
      (widget.surahNumber, settings.translationEditionId),
    ));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const AyahLoadingShimmer(),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(surahDetailProvider(
            (widget.surahNumber, settings.translationEditionId),
          )),
        ),
        data: (detail) => _ReaderContent(
          detail: detail,
          activeAyahIndex: audioAyahIndex >= 0 ? audioAyahIndex : _activeAyahIndex,
          showTranslation: _showTranslation,
          settings: settings,
          scrollController: _scrollController,
          reduceMotion: reduceMotion,
          onPlayAyah: (index) => _playAyah(detail.ayahs, index, settings.reciterId, settings.defaultAudioSpeed),
          onAyahVisible: (ayah, fraction) => _onAyahVisible(ayah, fraction, detail),
          onToggleTranslation: () =>
              setState(() => _showTranslation = !_showTranslation),
          loopMode: audio.loopMode,
          onLoopModeChange: (mode) =>
              ref.read(audioProvider.notifier).setLoopMode(mode),
          speed: audio.speed,
          onSpeedChange: (s) => ref.read(audioProvider.notifier).setSpeed(s),
        ),
      ),
      bottomNavigationBar: const MiniAudioPlayer(),
    );
  }

  Future<void> _playAyah(
      List<Ayah> ayahs, int index, String reciterId, double speed) async {
    setState(() => _activeAyahIndex = index);
    await ref.read(audioProvider.notifier).loadAndPlayAyah(
          ayahs: ayahs,
          startIndex: index,
          reciterId: reciterId,
        );
    await ref.read(audioProvider.notifier).setSpeed(speed);
  }

  void _onAyahVisible(Ayah ayah, double fraction, SurahDetail detail) {
    if (fraction >= AppConstants.hasanatScrollThreshold) {
      // Count hasanāt
      ref.read(hasanatProvider.notifier).maybeCountAyah(ayah.id, ayah.text);
      // Count reading progress
      ref.read(readingProgressProvider.notifier).markAyahRead(
            ayah: ayah,
            totalAyahsInSurah: detail.surah.numberOfAyahs,
          );
    }
  }
}

class _ReaderContent extends StatelessWidget {
  final SurahDetail detail;
  final int activeAyahIndex;
  final bool showTranslation;
  final dynamic settings;
  final ScrollController scrollController;
  final bool reduceMotion;
  final void Function(int) onPlayAyah;
  final void Function(Ayah, double) onAyahVisible;
  final VoidCallback onToggleTranslation;
  final LoopMode loopMode;
  final void Function(LoopMode) onLoopModeChange;
  final double speed;
  final void Function(double) onSpeedChange;

  const _ReaderContent({
    required this.detail,
    required this.activeAyahIndex,
    required this.showTranslation,
    required this.settings,
    required this.scrollController,
    required this.reduceMotion,
    required this.onPlayAyah,
    required this.onAyahVisible,
    required this.onToggleTranslation,
    required this.loopMode,
    required this.onLoopModeChange,
    required this.speed,
    required this.onSpeedChange,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(detail.surah.englishName),
          actions: [
            // Translation toggle
            IconButton(
              icon: Icon(
                showTranslation ? Icons.translate : Icons.translate_outlined,
                color: showTranslation ? AppColors.accent : null,
              ),
              onPressed: onToggleTranslation,
              tooltip: showTranslation ? 'Hide translation' : 'Show translation',
            ),
            // Loop mode
            IconButton(
              icon: Icon(_loopIcon(loopMode)),
              color: loopMode != LoopMode.none ? AppColors.accent : null,
              onPressed: () => onLoopModeChange(_nextLoopMode(loopMode)),
              tooltip: 'Loop: ${loopMode.name}',
            ),
          ],
        ),

        // Surah header
        SliverToBoxAdapter(
          child: _SurahHeader(surah: detail.surah),
        ),

        // Bismillah (except Al-Fatiha and At-Tawbah)
        if (detail.surah.number != 9)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'KFGQPCUthmanTaha',
                  fontSize: settings.arabicFontSize + 2,
                  color: AppColors.accent,
                  height: 2.0,
                ),
              ),
            ),
          ),

        // Ayah list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final ayah = detail.ayahs[i];
              return VisibilityDetector(
                key: Key('ayah_${ayah.id}'),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction >= AppConstants.hasanatScrollThreshold) {
                    onAyahVisible(ayah, info.visibleFraction);
                  }
                },
                child: AyahCard(
                  ayah: ayah,
                  isActive: i == activeAyahIndex,
                  showTranslation: showTranslation,
                  arabicFontSize: settings.arabicFontSize,
                  translationFontSize: settings.translationFontSize,
                  onPlay: () => onPlayAyah(i),
                  reduceMotion: reduceMotion,
                ),
              );
            },
            childCount: detail.ayahs.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  IconData _loopIcon(LoopMode mode) {
    switch (mode) {
      case LoopMode.none:
        return Icons.repeat;
      case LoopMode.ayah:
        return Icons.repeat_one;
      case LoopMode.surah:
        return Icons.repeat;
    }
  }

  LoopMode _nextLoopMode(LoopMode current) {
    switch (current) {
      case LoopMode.none:
        return LoopMode.ayah;
      case LoopMode.ayah:
        return LoopMode.surah;
      case LoopMode.surah:
        return LoopMode.none;
    }
  }
}

class _SurahHeader extends StatelessWidget {
  final dynamic surah;
  const _SurahHeader({required this.surah});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.12),
            AppColors.accentLight.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            surah.name ?? '',
            style: const TextStyle(
              fontFamily: 'KFGQPCUthmanTaha',
              fontSize: 32,
              color: AppColors.accent,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 4),
          Text(
            surah.englishName ?? '',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${surah.numberOfAyahs} Ayahs · ${surah.revelationType}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
