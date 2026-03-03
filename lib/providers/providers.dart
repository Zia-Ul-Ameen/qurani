// lib/providers/providers.dart
// Central barrel — all Riverpod providers for the Quran app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models/app_settings_model.dart';
import '../data/models/bookmark_model.dart';
import '../data/models/hasanat_stats_model.dart';
import '../data/models/reading_progress_model.dart';
import '../data/models/surah_model.dart';
import '../data/models/surah_detail_model.dart';
import '../data/models/ayah_model.dart';
import '../data/models/edition_model.dart';
import '../data/services/api_service.dart';
import '../data/services/bookmark_service.dart';
import '../data/services/hasanat_service.dart';
import '../data/services/persistence_service.dart';
import '../data/services/ramadan_mode_service.dart';
import '../data/services/reading_progress_service.dart';
import '../data/services/storage_manager.dart';
import '../data/services/download_service.dart';

// ─── Service Providers ─────────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final bookmarkServiceProvider =
    Provider<BookmarkService>((ref) => BookmarkService());

final hasanatServiceProvider =
    Provider<HasanatService>((ref) => HasanatService());

final readingProgressServiceProvider =
    Provider<ReadingProgressService>((ref) => ReadingProgressService());

final storageManagerProvider =
    Provider<StorageManager>((ref) => StorageManager());

final ramadanServiceProvider =
    Provider<RamadanModeService>((ref) => RamadanModeService());

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final svc = DownloadService();
  ref.onDispose(svc.dispose);
  return svc;
});

// ─── Settings ─────────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings.defaults()) {
    _load();
  }

  void _load() {
    state = PersistenceService.settingsBox.get('settings') ??
        AppSettings.defaults();
  }

  Future<void> _save() async =>
      PersistenceService.settingsBox.put('settings', state);

  Future<void> setReciter(String id) async {
    state = AppSettings(
      reciterId: id,
      translationEditionId: state.translationEditionId,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: state.translationFontSize,
      themeModeIndex: state.themeModeIndex,
      highContrast: state.highContrast,
      reduceMotion: state.reduceMotion,
      defaultAudioSpeed: state.defaultAudioSpeed,
      showTranslation: state.showTranslation,
    );
    await _save();
  }

  Future<void> setTranslation(String id) async {
    state = AppSettings(
      reciterId: state.reciterId,
      translationEditionId: id,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: state.translationFontSize,
      themeModeIndex: state.themeModeIndex,
      highContrast: state.highContrast,
      reduceMotion: state.reduceMotion,
      defaultAudioSpeed: state.defaultAudioSpeed,
      showTranslation: state.showTranslation,
    );
    await _save();
  }

  Future<void> setArabicFontSize(double size) async {
    state = AppSettings(
      reciterId: state.reciterId,
      translationEditionId: state.translationEditionId,
      arabicFontSize: size,
      translationFontSize: state.translationFontSize,
      themeModeIndex: state.themeModeIndex,
      highContrast: state.highContrast,
      reduceMotion: state.reduceMotion,
      defaultAudioSpeed: state.defaultAudioSpeed,
      showTranslation: state.showTranslation,
    );
    await _save();
  }

  Future<void> setTranslationFontSize(double size) async {
    state = AppSettings(
      reciterId: state.reciterId,
      translationEditionId: state.translationEditionId,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: size,
      themeModeIndex: state.themeModeIndex,
      highContrast: state.highContrast,
      reduceMotion: state.reduceMotion,
      defaultAudioSpeed: state.defaultAudioSpeed,
      showTranslation: state.showTranslation,
    );
    await _save();
  }

  Future<void> setThemeMode(int index) async {
    state = AppSettings(
      reciterId: state.reciterId,
      translationEditionId: state.translationEditionId,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: state.translationFontSize,
      themeModeIndex: index,
      highContrast: state.highContrast,
      reduceMotion: state.reduceMotion,
      defaultAudioSpeed: state.defaultAudioSpeed,
      showTranslation: state.showTranslation,
    );
    await _save();
  }

  Future<void> setHighContrast(bool value) async {
    state = AppSettings(
      reciterId: state.reciterId,
      translationEditionId: state.translationEditionId,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: state.translationFontSize,
      themeModeIndex: state.themeModeIndex,
      highContrast: value,
      reduceMotion: state.reduceMotion,
      defaultAudioSpeed: state.defaultAudioSpeed,
      showTranslation: state.showTranslation,
    );
    await _save();
  }

  Future<void> setReduceMotion(bool value) async {
    state = AppSettings(
      reciterId: state.reciterId,
      translationEditionId: state.translationEditionId,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: state.translationFontSize,
      themeModeIndex: state.themeModeIndex,
      highContrast: state.highContrast,
      reduceMotion: value,
      defaultAudioSpeed: state.defaultAudioSpeed,
      showTranslation: state.showTranslation,
    );
    await _save();
  }

  Future<void> setAudioSpeed(double speed) async {
    state = AppSettings(
      reciterId: state.reciterId,
      translationEditionId: state.translationEditionId,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: state.translationFontSize,
      themeModeIndex: state.themeModeIndex,
      highContrast: state.highContrast,
      reduceMotion: state.reduceMotion,
      defaultAudioSpeed: speed,
      showTranslation: state.showTranslation,
    );
    await _save();
  }

  Future<void> setShowTranslation(bool value) async {
    state = AppSettings(
      reciterId: state.reciterId,
      translationEditionId: state.translationEditionId,
      arabicFontSize: state.arabicFontSize,
      translationFontSize: state.translationFontSize,
      themeModeIndex: state.themeModeIndex,
      highContrast: state.highContrast,
      reduceMotion: state.reduceMotion,
      defaultAudioSpeed: state.defaultAudioSpeed,
      showTranslation: value,
    );
    await _save();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

// ─── Data Providers ────────────────────────────────────────────────────────

final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  return ref.watch(apiServiceProvider).fetchSurahList();
});

final surahDetailProvider =
    FutureProvider.family<SurahDetail, (int, String)>((ref, args) async {
  final (surahNumber, translationEdition) = args;
  return ref.watch(apiServiceProvider).fetchSurahDetail(surahNumber, translationEdition);
});

final juzProvider =
    FutureProvider.family<List<Ayah>, int>((ref, juzNumber) async {
  return ref.watch(apiServiceProvider).fetchJuz(juzNumber);
});

final pageProvider =
    FutureProvider.family<List<Ayah>, int>((ref, pageNumber) async {
  return ref.watch(apiServiceProvider).fetchPage(pageNumber);
});

final audioEditionsProvider = FutureProvider<List<Edition>>((ref) async {
  return ref.watch(apiServiceProvider).fetchAudioEditions();
});

// ─── Bookmarks ─────────────────────────────────────────────────────────────

class BookmarkNotifier extends StateNotifier<List<Bookmark>> {
  final BookmarkService _service;

  BookmarkNotifier(this._service) : super(_service.getAll()) {
    _service.changes.listen((_) {
      state = _service.getAll();
    });
  }

  Future<void> toggle({
    required int surahNumber,
    required int ayahNumber,
    required String ayahText,
    required String surahName,
  }) async {
    await _service.toggle(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      ayahText: ayahText,
      surahName: surahName,
    );
    state = _service.getAll();
  }

  bool isBookmarked(int surahNumber, int ayahNumber) =>
      _service.isBookmarked(surahNumber, ayahNumber);

  Future<void> remove(String id) async {
    await _service.remove(id);
    state = _service.getAll();
  }
}

final bookmarkProvider =
    StateNotifierProvider<BookmarkNotifier, List<Bookmark>>((ref) {
  return BookmarkNotifier(ref.watch(bookmarkServiceProvider));
});

// ─── Hasanāt ───────────────────────────────────────────────────────────────

class HasanatNotifier extends StateNotifier<AsyncValue<HasanatStats>> {
  final HasanatService _service;

  HasanatNotifier(this._service) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _service.getStats());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> maybeCountAyah(String ayahId, String arabicText) async {
    final updated = await _service.maybeCountAyah(ayahId, arabicText);
    if (updated != null) {
      state = AsyncValue.data(updated);
    }
  }

  Future<void> reset() async {
    await _service.resetAllTime();
    await _load();
  }
}

final hasanatProvider = StateNotifierProvider<HasanatNotifier, AsyncValue<HasanatStats>>(
    (ref) => HasanatNotifier(ref.watch(hasanatServiceProvider)));

// ─── Reading Progress ──────────────────────────────────────────────────────

class ReadingProgressNotifier extends StateNotifier<ReadingProgress> {
  final ReadingProgressService _service;

  ReadingProgressNotifier(this._service) : super(_service.getProgress());

  Future<void> markAyahRead({
    required Ayah ayah,
    required int totalAyahsInSurah,
  }) async {
    state = await _service.markAyahRead(
      ayah: ayah,
      totalAyahsInSurah: totalAyahsInSurah,
    );
  }

  List<int> get weeklyAyahCounts => _service.weeklyAyahCounts();

  Future<void> reset() async {
    await _service.reset();
    state = _service.getProgress();
  }
}

final readingProgressProvider =
    StateNotifierProvider<ReadingProgressNotifier, ReadingProgress>(
        (ref) => ReadingProgressNotifier(ref.watch(readingProgressServiceProvider)));

// ─── Storage ───────────────────────────────────────────────────────────────

final storageInfoProvider = FutureProvider<StorageInfo>((ref) async {
  return ref.watch(storageManagerProvider).calculateUsage();
});

// ─── Accessibility ─────────────────────────────────────────────────────────
// Reads system-level accessibility preferences.

class AccessibilityState {
  final bool reduceMotion;
  final bool boldText;

  const AccessibilityState({
    required this.reduceMotion,
    required this.boldText,
  });
}

final accessibilityProvider = Provider<bool>((ref) {
  // True if user has enabled "Reduce Motion" via Settings or accessibility prefs.
  // We read from AppSettings as user override, OR system MediaQuery.
  final settings = ref.watch(settingsProvider);
  return settings.reduceMotion;
});

// ─── Effective Theme ───────────────────────────────────────────────────────

final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.themeMode;
});

final highContrastProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).highContrast;
});

class ThemeSet {
  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;
  ThemeSet(this.light, this.dark, this.mode);
}

final effectiveThemeProvider = Provider<ThemeSet>((ref) {
  final mode = ref.watch(effectiveThemeModeProvider);
  final isHighContrast = ref.watch(highContrastProvider);

  if (isHighContrast) {
    return ThemeSet(AppTheme.highContrast, AppTheme.highContrast, ThemeMode.dark);
  }

  return ThemeSet(AppTheme.light, AppTheme.dark, mode);
});

// ─── Download Helpers ──────────────────────────────────────────────────────

final ayahDownloadedProvider =
    FutureProvider.family<bool, (String, int, int)>((ref, args) async {
  final (reciterId, surahNum, ayahNum) = args;
  return ref.watch(downloadServiceProvider).isDownloaded(reciterId, surahNum, ayahNum);
});
