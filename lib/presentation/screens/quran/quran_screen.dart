// lib/presentation/screens/quran/quran_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/providers.dart';
import '../../widgets/surah/surah_list_tile.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_state_widget.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Surah'),
              Tab(text: 'Juz'),
              Tab(text: 'Page'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SurahTab(
            searchQuery: _searchQuery,
            searchController: _searchController,
            onSearchChanged: (q) => setState(() => _searchQuery = q),
          ),
          const _JuzTab(),
          const _PageTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────── SURAH TAB ────────────────────────────────

class _SurahTab extends ConsumerWidget {
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _SurahTab({
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahListAsync = ref.watch(surahListProvider);
    final progress = ref.watch(readingProgressProvider);

    return surahListAsync.when(
      loading: () => const LoadingShimmer(),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.refresh(surahListProvider),
      ),
      data: (surahs) {
        final filtered = searchQuery.isEmpty
            ? surahs
            : surahs.where((s) {
                final q = searchQuery.toLowerCase();
                return s.englishName.toLowerCase().contains(q) ||
                    s.name.contains(searchQuery) ||
                    s.number.toString() == searchQuery;
              }).toList();

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Semantics(
                label: 'Search surahs',
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search Surah...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final surah = filtered[i];
                  return SurahListTile(
                    surah: surah,
                    isCompleted: progress.isSurahComplete(
                        surah.number, surah.numberOfAyahs),
                    onTap: () => context.push('/reader/${surah.number}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────── JUZ TAB ──────────────────────────────────

class _JuzTab extends ConsumerWidget {
  const _JuzTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: 30,
      itemBuilder: (ctx, i) {
        final juzNumber = i + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () {
              // Go to reader at first ayah of juz
              // For now navigate to surah that begins the juz
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      '$juzNumber',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Juz $juzNumber',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────── PAGE TAB ─────────────────────────────────

class _PageTab extends StatelessWidget {
  const _PageTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 604,
      itemBuilder: (ctx, i) {
        final page = i + 1;
        return InkWell(
          onTap: () {
            // Navigate to page reader
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            alignment: Alignment.center,
            child: Text(
              '$page',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        );
      },
    );
  }
}
