// lib/data/services/storage_manager.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';

class StorageInfo {
  final int totalBytes;
  final Map<String, int> perReciterBytes;
  final Map<String, Map<int, int>> perSurahBytes; // reciter -> surahNum -> bytes

  const StorageInfo({
    required this.totalBytes,
    required this.perReciterBytes,
    required this.perSurahBytes,
  });

  double get totalMB => totalBytes / (1024 * 1024);
  double get totalGB => totalBytes / (1024 * 1024 * 1024);

  String get totalFormatted {
    if (totalMB >= 1024) return '${totalGB.toStringAsFixed(1)} GB';
    if (totalMB >= 1) return '${totalMB.toStringAsFixed(0)} MB';
    return '${(totalBytes / 1024).toStringAsFixed(0)} KB';
  }
}

class StorageManager {
  Future<String> get _audioRootPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/${AppConstants.audioStorageSubPath}';
  }

  Future<StorageInfo> calculateUsage() async {
    final root = Directory(await _audioRootPath);
    if (!root.existsSync()) {
      return const StorageInfo(
          totalBytes: 0, perReciterBytes: {}, perSurahBytes: {});
    }

    int total = 0;
    final perReciter = <String, int>{};
    final perSurah = <String, Map<int, int>>{};

    await for (final entity in root.list(recursive: false)) {
      if (entity is Directory) {
        final reciterId = entity.path.split(Platform.pathSeparator).last;
        int reciterTotal = 0;
        perSurah[reciterId] = {};

        await for (final surahDir in entity.list(recursive: false)) {
          if (surahDir is Directory) {
            final surahNum =
                int.tryParse(surahDir.path.split(Platform.pathSeparator).last) ?? 0;
            int surahBytes = 0;
            await for (final file in surahDir.list(recursive: false)) {
              if (file is File) {
                surahBytes += await file.length();
              }
            }
            reciterTotal += surahBytes;
            perSurah[reciterId]![surahNum] = surahBytes;
          }
        }

        perReciter[reciterId] = reciterTotal;
        total += reciterTotal;
      }
    }

    return StorageInfo(
      totalBytes: total,
      perReciterBytes: perReciter,
      perSurahBytes: perSurah,
    );
  }

  /// Estimate download size for a surah (based on ~64KB avg per ayah at 128kbps).
  int estimateSurahBytes(int totalAyahs) => totalAyahs * 64 * 1024;

  bool wouldExceedSingleWarning(int additionalBytes) =>
      additionalBytes > AppConstants.downloadWarnSingleMB * 1024 * 1024;

  Future<bool> wouldExceedTotalWarning(int additionalBytes) async {
    final info = await calculateUsage();
    final projected = info.totalBytes + additionalBytes;
    return projected > AppConstants.downloadWarnTotalMB * 1024 * 1024;
  }

  /// Returns surahs sorted by size (largest first) for cleanup suggestions.
  List<MapEntry<int, int>> getLruSuggestions(
      String reciterId, StorageInfo info) {
    final surahInfo = info.perSurahBytes[reciterId] ?? {};
    final entries = surahInfo.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Check approximate free space (rough estimate via temp directory).
  Future<int?> estimateFreeBytesApprox() async {
    return null; // Platform-specific; would need platform channel for accurate value
  }
}
