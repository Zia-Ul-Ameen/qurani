// test/unit/streak_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/utils/date_utils_ext.dart';

void main() {
  group('DateUtilsExt - Streak Logic', () {
    test('calculateStreak counts consecutive days correctly', () {
      final now = DateTime(2023, 10, 10);
      final dates = [
        DateTime(2023, 10, 10),
        DateTime(2023, 10, 9),
        DateTime(2023, 10, 8),
      ];
      expect(DateUtilsExt.calculateStreak(dates, now), 3);
    });

    test('streak breaks when a day is missed', () {
      final now = DateTime(2023, 10, 10);
      final dates = [
        DateTime(2023, 10, 10),
        DateTime(2023, 10, 8), // Missed 9th
      ];
      expect(DateUtilsExt.calculateStreak(dates, now), 1);
    });

    test('streak is preserved if today is not recorded but yesterday was', () {
      final now = DateTime(2023, 10, 11);
      final dates = [
        DateTime(2023, 10, 10),
        DateTime(2023, 10, 9),
      ];
      // User hasn't read today yet, but yesterday was part of a streak
      expect(DateUtilsExt.calculateStreak(dates, now), 2);
    });

    test('streak resets to 0 if a full day gap is exceeded', () {
      final now = DateTime(2023, 10, 12);
      final dates = [
        DateTime(2023, 10, 10), // Gap of 11th
      ];
      expect(DateUtilsExt.calculateStreak(dates, now), 0);
    });
  });
}
