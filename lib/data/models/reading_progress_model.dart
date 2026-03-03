// lib/data/models/reading_progress_model.dart

class ReadingSession {
  final DateTime date;
  final int surahNumber;
  final int ayahsRead;

  ReadingSession({
    required this.date,
    required this.surahNumber,
    required this.ayahsRead,
  });
}

class ReadingProgress {
  final Map<String, List<String>> completedAyahsBySurah; // surahNum -> [ayahId]
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadDate;
  final List<ReadingSession> recentSessions;
  final int lastSurahNumber;
  final int lastAyahNumber;

  ReadingProgress({
    required this.completedAyahsBySurah,
    required this.currentStreak,
    required this.longestStreak,
    this.lastReadDate,
    required this.recentSessions,
    required this.lastSurahNumber,
    required this.lastAyahNumber,
  });

  factory ReadingProgress.empty() => ReadingProgress(
        completedAyahsBySurah: {},
        currentStreak: 0,
        longestStreak: 0,
        recentSessions: [],
        lastSurahNumber: 1,
        lastAyahNumber: 1,
      );

  bool isSurahComplete(int surahNumber, int totalAyahs) {
    final read = completedAyahsBySurah[surahNumber.toString()];
    return read != null && read.length >= totalAyahs;
  }

  ReadingProgress copyWith({
    Map<String, List<String>>? completedAyahsBySurah,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    List<ReadingSession>? recentSessions,
    int? lastSurahNumber,
    int? lastAyahNumber,
  }) =>
      ReadingProgress(
        completedAyahsBySurah: completedAyahsBySurah ?? this.completedAyahsBySurah,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastReadDate: lastReadDate ?? this.lastReadDate,
        recentSessions: recentSessions ?? this.recentSessions,
        lastSurahNumber: lastSurahNumber ?? this.lastSurahNumber,
        lastAyahNumber: lastAyahNumber ?? this.lastAyahNumber,
      );

  int completedSurahCount(Map<int, int> surahAyahCounts) {
    int count = 0;
    completedAyahsBySurah.forEach((surahNumStr, ayahsRead) {
      final surahNum = int.tryParse(surahNumStr) ?? 0;
      final totalAyahs = surahAyahCounts[surahNum];
      if (totalAyahs != null && ayahsRead.length >= totalAyahs) {
        count++;
      }
    });
    return count;
  }
}
