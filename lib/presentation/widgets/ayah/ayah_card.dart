// lib/presentation/widgets/ayah/ayah_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/ayah_model.dart';
import '../../../providers/providers.dart';
import '../../../core/theme/app_colors.dart';

class AyahCard extends ConsumerWidget {
  final Ayah ayah;
  final bool isActive;          // Currently playing
  final bool showTranslation;
  final double arabicFontSize;
  final double translationFontSize;
  final VoidCallback? onPlay;
  final bool reduceMotion;

  const AyahCard({
    super.key,
    required this.ayah,
    this.isActive = false,
    this.showTranslation = true,
    this.arabicFontSize = 24,
    this.translationFontSize = 15,
    this.onPlay,
    this.reduceMotion = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isBookmarked = ref.watch(bookmarkProvider.select((list) =>
        list.any((b) => b.surahNumber == ayah.surahNumber &&
            b.ayahNumber == ayah.numberInSurah)));

    return AnimatedContainer(
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.accent.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.4)
              : theme.dividerColor,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row — ayah number + actions
            Row(
              children: [
                _AyahNumberBadge(number: ayah.numberInSurah),
                const Spacer(),
                // Bookmark button
                Semantics(
                  label: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                  button: true,
                  child: IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: isBookmarked
                          ? AppColors.accent
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    onPressed: () {
                      ref.read(bookmarkProvider.notifier).toggle(
                            surahNumber: ayah.surahNumber,
                            ayahNumber: ayah.numberInSurah,
                            ayahText: ayah.text,
                            surahName: '',
                          );
                    },
                    visualDensity: VisualDensity.compact,
                    tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
                  ),
                ),
                // Play button
                if (onPlay != null)
                  Semantics(
                    label: 'Play ayah ${ayah.numberInSurah}',
                    button: true,
                    child: IconButton(
                      icon: Icon(
                        isActive ? Icons.pause_circle : Icons.play_circle_outline,
                        color: AppColors.accent,
                        size: 22,
                      ),
                      onPressed: onPlay,
                      visualDensity: VisualDensity.compact,
                      tooltip: isActive ? 'Pause' : 'Play',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Arabic text — RTL
            Semantics(
              label: 'Arabic text of ayah ${ayah.numberInSurah}',
              child: Text(
                ayah.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'KFGQPCUthmanTaha',
                  fontSize: arabicFontSize,
                  height: 2.0,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            // Translation
            if (showTranslation && ayah.translation != null) ...[
              Divider(height: 24, color: theme.dividerColor.withValues(alpha: 0.6)),
              Semantics(
                label: 'Translation of ayah ${ayah.numberInSurah}',
                child: Text(
                  ayah.translation!,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: translationFontSize,
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AyahNumberBadge extends StatelessWidget {
  final int number;
  const _AyahNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
