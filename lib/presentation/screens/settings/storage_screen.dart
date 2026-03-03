// lib/presentation/screens/settings/storage_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import '../../../core/theme/app_colors.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageAsync = ref.watch(storageInfoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Storage Management')),
      body: storageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (info) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Total Usage
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.1),
                    AppColors.accentLight.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.storage, color: AppColors.accent, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    info.totalFormatted,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  Text('Total downloaded audio', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Per-reciter breakdown
            if (info.perReciterBytes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No audio downloaded yet.\nDownload surahs from the reader.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              )
            else
              ...info.perReciterBytes.entries.map((e) {
                final reciter = e.key;
                final bytes = e.value;
                final mb = bytes / (1024 * 1024);
                
                final surahs = (info.perSurahBytes[reciter]?.entries.toList() ?? [])
                  ..sort((a, b) => a.key.compareTo(b.key));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(reciter,
                                style: theme.textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text('${mb.toStringAsFixed(0)} MB',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Surah breakdown
                      ...surahs.map((se) {
                        final surahMb = se.value / (1024 * 1024);
                        if (surahMb < 0.1) return const SizedBox.shrink();
                        
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                AppColors.accent.withValues(alpha: 0.1),
                            child: Text(
                              '${se.key}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.accent),
                            ),
                          ),
                          title: Text('Surah ${se.key}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${surahMb.toStringAsFixed(1)} MB',
                                  style: theme.textTheme.bodySmall),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                                onPressed: () =>
                                    _confirmDeleteSurah(context, ref, reciter, se.key),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),

            // Clear all button
            if (info.totalBytes > 0) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Clear All Downloads'),
                onPressed: () => _confirmClearAll(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSurah(BuildContext context, WidgetRef ref, String reciter, int surah) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Surah'),
        content: Text('Delete downloaded audio for Surah $surah?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(downloadServiceProvider)
                  .deleteSurah(reciterId: reciter, surahNumber: surah, totalAyahs: 286);
              // Invalidate to trigger re-fetch
              ref.invalidate(storageInfoProvider);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Downloads'),
        content: const Text('This will delete all downloaded Quran audio. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(downloadServiceProvider).deleteAllDownloads();
              // Invalidate to trigger re-fetch
              ref.invalidate(storageInfoProvider);
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
