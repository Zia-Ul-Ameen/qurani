// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // Grid system (8pt)
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double space2XL = 48.0;

  // Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  // Font sizes — Arabic
  static const double arabicFontSizeMin = 18.0;
  static const double arabicFontSizeDefault = 24.0;
  static const double arabicFontSizeMax = 42.0;

  // Font sizes — Translation
  static const double translationFontSizeMin = 12.0;
  static const double translationFontSizeDefault = 15.0;
  static const double translationFontSizeMax = 24.0;

  // Audio speeds
  static const List<double> audioSpeeds = [0.75, 1.0, 1.25, 1.5];

  // Download thresholds
  static const int downloadWarnSingleMB = 100;       // 100 MB
  static const int downloadWarnTotalMB = 1024;       // 1 GB

  // Hasanat
  static const int hasanatPerLetter = 10;
  static const double hasanatScrollThreshold = 0.80; // 80% scrolled
  static const double hasanatAudioThreshold = 0.80;  // 80% audio played

  // Quran metadata
  static const int totalSurahs = 114;
  static const int totalJuz = 30;
  static const int totalPages = 604;
  static const int totalAyahs = 6236;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Storage paths
  static const String audioStorageSubPath = 'quran_audio';

  // App info
  static const String appName = 'qurani';
  static const String hasanatDisclaimer =
      'Hasanāt count is an estimate based on letter count (1 letter = 10 rewards). True reward is with Allah.';

  // Daily ayah: rotate through all 6236 ayahs by day-of-year
  static int dailyAyahNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays;
    return (dayOfYear % totalAyahs) + 1;
  }

  // Hive box names
  static const String boxSettings = 'settings';
  static const String boxBookmarks = 'bookmarks';
  static const String boxHasanat = 'hasanat';
  static const String boxProgress = 'progress';
  static const String boxDownloads = 'downloads';
}
