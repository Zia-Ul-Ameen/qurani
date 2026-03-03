// lib/presentation/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/quran/quran_screen.dart';
import '../screens/reader/surah_reader_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/storage_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/quran',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: QuranScreen()),
        ),
        GoRoute(
          path: '/analytics',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: AnalyticsScreen()),
        ),
        GoRoute(
          path: '/bookmarks',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: BookmarksScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/reader/:surahNumber',
      builder: (context, state) {
        final surahNumber = int.parse(state.pathParameters['surahNumber']!);
        final startAyah =
            int.tryParse(state.uri.queryParameters['ayah'] ?? '1') ?? 1;
        return SurahReaderScreen(
          surahNumber: surahNumber,
          startAyah: startAyah,
        );
      },
    ),
    GoRoute(
      path: '/settings/storage',
      builder: (context, state) => const StorageScreen(),
    ),
  ],
);

class _AppShell extends StatefulWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  static const _tabs = ['/home', '/quran', '/analytics', '/bookmarks', '/settings'];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Quran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
