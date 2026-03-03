// lib/core/utils/date_utils_ext.dart

class DateUtilsExt {
  DateUtilsExt._();

  /// Returns true if [date] falls within an approximated Ramadan window.
  /// This uses a simplified Gregorian approximation (not Hijri calendar).
  /// Ramadan 2025: Mar 1 – Mar 30, 2025
  /// Ramadan 2026: Feb 18 – Mar 19, 2026
  /// Ramadan 2027: Feb 7 – Mar 8, 2027
  static bool isRamadan(DateTime date) {
    final year = date.year;
    final ramadanRanges = <int, (DateTime, DateTime)>{
      2024: (DateTime(2024, 3, 11), DateTime(2024, 4, 9)),
      2025: (DateTime(2025, 3, 1), DateTime(2025, 3, 30)),
      2026: (DateTime(2026, 2, 18), DateTime(2026, 3, 19)),
      2027: (DateTime(2027, 2, 7), DateTime(2027, 3, 8)),
      2028: (DateTime(2028, 1, 27), DateTime(2028, 2, 25)),
    };
    final range = ramadanRanges[year];
    if (range == null) return false;
    return !date.isBefore(range.$1) && !date.isAfter(range.$2);
  }

  /// Returns a day number within Ramadan (1-indexed), or null if not Ramadan.
  static int? ramadanDay(DateTime date) {
    final year = date.year;
    final ramadanRanges = <int, DateTime>{
      2024: DateTime(2024, 3, 11),
      2025: DateTime(2025, 3, 1),
      2026: DateTime(2026, 2, 18),
      2027: DateTime(2027, 2, 7),
      2028: DateTime(2028, 1, 27),
    };
    final start = ramadanRanges[year];
    if (start == null) return null;
    final diff = date.difference(start).inDays + 1;
    return diff.clamp(1, 30);
  }

  /// Deterministic daily ayah index (0-based) for any [date].
  static int dailyAyahIndex(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays;
    return dayOfYear % 6236;
  }

  /// Strip time component, keep date only.
  static DateTime dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Returns true if [a] and [b] are the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns true if [b] is exactly one calendar day after [a].
  static bool isConsecutiveDay(DateTime a, DateTime b) {
    final da = dateOnly(a);
    final db = dateOnly(b);
    return db.difference(da).inDays == 1;
  }

  /// Calculates the current streak from a list of [dates] (usually unique days).
  /// [now] is the reference point for "today".
  static int calculateStreak(List<DateTime> dates, DateTime now) {
    if (dates.isEmpty) return 0;

    final sorted = dates.map(dateOnly).toList()
      ..sort((a, b) => b.compareTo(a)); // Descending (latest first)
    final unique = sorted.toSet().toList();

    final today = dateOnly(now);
    final yesterday = today.subtract(const Duration(days: 1));

    // Start checking from the most recent date
    final start = unique.first;
    if (start != today && start != yesterday) return 0;

    int streak = 1;
    for (int i = 0; i < unique.length - 1; i++) {
      if (isConsecutiveDay(unique[i + 1], unique[i])) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
