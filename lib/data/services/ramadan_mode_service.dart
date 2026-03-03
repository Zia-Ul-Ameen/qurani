// lib/data/services/ramadan_mode_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/date_utils_ext.dart';
import '../../core/constants/app_constants.dart';

class RamadanProgress {
  final bool isRamadan;
  final int? ramadanDay;
  final int? suggestedJuz;
  final List<bool> khatmDays; // 30 booleans

  const RamadanProgress({
    required this.isRamadan,
    this.ramadanDay,
    this.suggestedJuz,
    required this.khatmDays,
  });

  int get completedDays => khatmDays.where((d) => d).length;
  double get khatmProgress => completedDays / 30;
}

/// Key used to store Ramadan Khatm progress in Hive under boxSettings.
const _kKhatmKey = 'ramadan_khatm';

class RamadanModeService {
  RamadanProgress getProgress() {
    final now = DateTime.now();
    final ramadan = DateUtilsExt.isRamadan(now);
    final day = DateUtilsExt.ramadanDay(now);

    final khatmRaw =
        Hive.box(AppConstants.boxSettings).get(_kKhatmKey) as List?;
    List<bool> khatm;
    if (khatmRaw != null && khatmRaw.length == 30) {
      khatm = khatmRaw.cast<bool>();
    } else {
      khatm = List.filled(30, false);
    }

    return RamadanProgress(
      isRamadan: ramadan,
      ramadanDay: day,
      suggestedJuz: day,
      khatmDays: khatm,
    );
  }

  Future<void> markDayComplete(int day) async {
    // day is 1-indexed
    final progress = getProgress();
    final khatm = List<bool>.from(progress.khatmDays);
    if (day >= 1 && day <= 30) khatm[day - 1] = true;
    await Hive.box(AppConstants.boxSettings).put(_kKhatmKey, khatm);
  }

  Future<void> resetKhatm() async {
    await Hive.box(AppConstants.boxSettings)
        .put(_kKhatmKey, List.filled(30, false));
  }

  /// Daily ayah suggestion — deterministic, date-based.
  int dailyAyahNumber(DateTime date) =>
      AppConstants.dailyAyahNumber(date) % AppConstants.totalAyahs + 1;
}
