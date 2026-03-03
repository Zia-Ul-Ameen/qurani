// lib/data/services/reading_progress_service.dart

import '../models/reading_progress_model.dart';
import '../models/ayah_model.dart';
import 'persistence_service.dart';
import '../../core/utils/date_utils_ext.dart';

class ReadingProgressService {
  ReadingProgress _getOrCreate() {
    return PersistenceService.progressBox.get('progress') ??
        ReadingProgress.empty();
  }

  ReadingProgress getProgress() => _getOrCreate();

  /// Mark an ayah as read. Updates streak, session, completion.
  Future<ReadingProgress> markAyahRead({
    required Ayah ayah,
    required int totalAyahsInSurah,
  }) async {
    final progress = _getOrCreate();
    final surahKey = '${ayah.surahNumber}';
    final ayahId = ayah.id;

    // Update completed ayahs
    final map = Map<String, List<String>>.from(progress.completedAyahsBySurah);
    final list = List<String>.from(map[surahKey] ?? []);
    if (!list.contains(ayahId)) {
      list.add(ayahId);
      map[surahKey] = list;
    }

    // Update streak and session
    var updated = progress.copyWith(
      completedAyahsBySurah: map,
      lastSurahNumber: ayah.surahNumber,
      lastAyahNumber: ayah.numberInSurah,
    );

    updated = _updateStreak(updated);
    updated = _updateTodaySession(updated, ayah.surahNumber);

    await PersistenceService.progressBox.put('progress', updated);
    return updated;
  }

  ReadingProgress _updateStreak(ReadingProgress progress) {
    final today = DateUtilsExt.dateOnly(DateTime.now());
    final lastRead = progress.lastReadDate;

    int newCurrent = progress.currentStreak;
    int newLongest = progress.longestStreak;

    if (lastRead == null) {
      newCurrent = 1;
    } else if (DateUtilsExt.isSameDay(today, lastRead)) {
      // Already read today, no change
    } else if (DateUtilsExt.isConsecutiveDay(lastRead, today)) {
      newCurrent += 1;
    } else {
      newCurrent = 1;
    }

    if (newCurrent > newLongest) {
      newLongest = newCurrent;
    }

    return progress.copyWith(
      currentStreak: newCurrent,
      longestStreak: newLongest,
      lastReadDate: today,
    );
  }

  ReadingProgress _updateTodaySession(ReadingProgress progress, int surahNumber) {
    final today = DateUtilsExt.dateOnly(DateTime.now());
    final sessions = List<ReadingSession>.from(progress.recentSessions);

    final idx = sessions.indexWhere((s) => DateUtilsExt.isSameDay(s.date, today));

    if (idx >= 0) {
      final old = sessions[idx];
      sessions[idx] = ReadingSession(
        date: old.date,
        surahNumber: surahNumber,
        ayahsRead: old.ayahsRead + 1,
      );
    } else {
      sessions.add(ReadingSession(
        date: today,
        surahNumber: surahNumber,
        ayahsRead: 1,
      ));
    }

    // Keep last 30
    if (sessions.length > 30) {
      sessions.removeAt(0);
    }

    return progress.copyWith(recentSessions: sessions);
  }

  List<int> weeklyAyahCounts() {
    final progress = _getOrCreate();
    final today = DateUtilsExt.dateOnly(DateTime.now());
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final session = progress.recentSessions.where(
        (s) => DateUtilsExt.isSameDay(s.date, day),
      );
      return session.isEmpty ? 0 : session.first.ayahsRead;
    });
  }

  Future<void> reset() async {
    await PersistenceService.progressBox.put('progress', ReadingProgress.empty());
  }
}
