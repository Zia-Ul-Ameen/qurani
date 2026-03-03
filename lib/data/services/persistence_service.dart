// lib/data/services/persistence_service.dart
// Initializes Hive and registers all adapters.
// We use manually-written adapters (no code-gen) for simplicity.

import 'package:hive_flutter/hive_flutter.dart';
import '../models/bookmark_model.dart';
import '../models/hasanat_stats_model.dart';
import '../models/app_settings_model.dart';
import '../models/reading_progress_model.dart';
import '../models/download_task_model.dart';
import '../models/hive_adapters.dart';
import '../../core/constants/app_constants.dart';

class PersistenceService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
    _initialized = true;
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(BookmarkAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(HasanatStatsAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(AppSettingsAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ReadingProgressAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ReadingSessionAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(DownloadTaskAdapter());
  }

  static Future<void> _openBoxes() async {
    await Hive.openBox<Bookmark>(AppConstants.boxBookmarks);
    await Hive.openBox<HasanatStats>(AppConstants.boxHasanat);
    await Hive.openBox<AppSettings>(AppConstants.boxSettings);
    await Hive.openBox<ReadingProgress>(AppConstants.boxProgress);
    await Hive.openBox<DownloadTask>(AppConstants.boxDownloads);
  }

  static Box<Bookmark> get bookmarksBox =>
      Hive.box<Bookmark>(AppConstants.boxBookmarks);
  static Box<HasanatStats> get hasanatBox =>
      Hive.box<HasanatStats>(AppConstants.boxHasanat);
  static Box<AppSettings> get settingsBox =>
      Hive.box<AppSettings>(AppConstants.boxSettings);
  static Box<ReadingProgress> get progressBox =>
      Hive.box<ReadingProgress>(AppConstants.boxProgress);
  static Box<DownloadTask> get downloadsBox =>
      Hive.box<DownloadTask>(AppConstants.boxDownloads);

  static Future<void> closeAll() => Hive.close();
}
