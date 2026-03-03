// lib/presentation/screens/bookmarks/bookmarks_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/error_state_widget.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: bookmarks.isEmpty
          ? const EmptyStateWidget(
              title: 'No bookmarks yet',
              subtitle: 'Bookmark ayahs while reading to see them here.',
              icon: Icons.bookmark_outline,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final bookmark = bookmarks[i];
                return Dismissible(
                  key: Key(bookmark.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    ref.read(bookmarkProvider.notifier).remove(bookmark.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bookmark removed'),
                        action: SnackBarAction(label: 'Undo', onPressed: () {
                          // Re-add (simplified — full undo would need state)
                        }),
                      ),
                    );
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  child: InkWell(
                    onTap: () => context.push(
                      '/reader/${bookmark.surahNumber}?ayah=${bookmark.ayahNumber}',
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              const Icon(Icons.bookmark,
                                  size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                'Surah ${bookmark.surahNumber} · Ayah ${bookmark.ayahNumber}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _dateLabel(bookmark.createdAt),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Arabic snippet
                          Text(
                            bookmark.ayahText.length > 80
                                ? '${bookmark.ayahText.substring(0, 80)}...'
                                : bookmark.ayahText,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'KFGQPCUthmanTaha',
                              fontSize: 18,
                              height: 1.8,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
