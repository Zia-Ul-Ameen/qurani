// lib/data/services/hasanat_service.dart

import '../models/hasanat_stats_model.dart';
import 'persistence_service.dart';
import '../../core/utils/hasanat_engine.dart';
import '../../core/utils/date_utils_ext.dart';
import '../../core/constants/app_constants.dart';

class HasanatService {
  HasanatStats _getOrCreate() {
    final box = PersistenceService.hasanatBox;
    return box.get('stats') ?? HasanatStats.empty();
  }

  Future<HasanatStats> getStats() async {
    final stats = _getOrCreate();
    // Reset daily if needed
    final today = DateUtilsExt.dateOnly(DateTime.now());
    final lastReset = DateUtilsExt.dateOnly(stats.lastResetDate);
    if (!DateUtilsExt.isSameDay(today, lastReset)) {
      return _resetDaily(stats);
    }
    return stats;
  }

  Future<HasanatStats> _resetDaily(HasanatStats stats) async {
    final updated = stats.copyWith(
      todayHasanat: 0,
      countedAyahsToday: [],
      lastResetDate: DateTime.now(),
    );
    await PersistenceService.hasanatBox.put('stats', updated);
    return updated;
  }

  /// Count hasanāt for an ayah if not already counted today.
  /// Returns updated stats if counted, null if already counted.
  Future<HasanatStats?> maybeCountAyah(String ayahId, String arabicText) async {
    final stats = await getStats();

    if (stats.countedAyahsToday.contains(ayahId)) return null;

    // Compute (use cache if available)
    int letters = stats.ayahLetterCache[ayahId] ?? 0;
    if (letters == 0) {
      letters = HasanatEngine.countLetters(arabicText);
    }
    
    final newCache = Map<String, int>.from(stats.ayahLetterCache);
    newCache[ayahId] = letters;
    
    final hasanat = letters * AppConstants.hasanatPerLetter;

    final updated = stats.copyWith(
      todayHasanat: stats.todayHasanat + hasanat,
      totalHasanat: stats.totalHasanat + hasanat,
      countedAyahsToday: [...stats.countedAyahsToday, ayahId],
      ayahLetterCache: newCache,
    );

    await PersistenceService.hasanatBox.put('stats', updated);
    return updated;
  }

  Future<void> resetAllTime() async {
    final stats = HasanatStats.empty();
    await PersistenceService.hasanatBox.put('stats', stats);
  }
}
