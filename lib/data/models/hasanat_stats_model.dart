// lib/data/models/hasanat_stats_model.dart

class HasanatStats {
  final int totalHasanat;
  final int todayHasanat;
  final DateTime lastResetDate;
  final List<String> countedAyahsToday;
  final Map<String, int> ayahLetterCache;

  HasanatStats({
    required this.totalHasanat,
    required this.todayHasanat,
    required this.lastResetDate,
    required this.countedAyahsToday,
    required this.ayahLetterCache,
  });

  factory HasanatStats.empty() => HasanatStats(
        totalHasanat: 0,
        todayHasanat: 0,
        lastResetDate: DateTime(2000),
        countedAyahsToday: [],
        ayahLetterCache: {},
      );

  HasanatStats copyWith({
    int? totalHasanat,
    int? todayHasanat,
    DateTime? lastResetDate,
    List<String>? countedAyahsToday,
    Map<String, int>? ayahLetterCache,
  }) =>
      HasanatStats(
        totalHasanat: totalHasanat ?? this.totalHasanat,
        todayHasanat: todayHasanat ?? this.todayHasanat,
        lastResetDate: lastResetDate ?? this.lastResetDate,
        countedAyahsToday: countedAyahsToday ?? this.countedAyahsToday,
        ayahLetterCache: ayahLetterCache ?? this.ayahLetterCache,
      );
}
