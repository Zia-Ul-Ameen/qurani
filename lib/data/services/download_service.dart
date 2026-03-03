// lib/data/services/download_service.dart

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../models/download_task_model.dart';
import 'persistence_service.dart';

class DownloadProgress {
  final String taskId;
  final int surahNumber;
  final int ayahNumber;
  final double progress; // 0.0–1.0
  final DownloadStatus status;

  const DownloadProgress({
    required this.taskId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.progress,
    required this.status,
  });
}

class DownloadService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5),
  ));

  final _progressController = StreamController<DownloadProgress>.broadcast();

  Stream<DownloadProgress> get progressStream => _progressController.stream;

  final Map<String, CancelToken> _cancelTokens = {};

  // ─── Path Helpers ──────────────────────────────────────────────────────────

  Future<String> _audioFilePath(
      String reciterId, int surahNumber, int ayahNumber) async {
    final dir = await getApplicationDocumentsDirectory();
    final surahStr = surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayahNumber.toString().padLeft(3, '0');
    final path =
        '${dir.path}/${AppConstants.audioStorageSubPath}/$reciterId/$surahStr';
    await Directory(path).create(recursive: true);
    return '$path/$ayahStr.mp3';
  }

  bool _isValidFile(String path) {
    final file = File(path);
    return file.existsSync() && file.lengthSync() > 1024; // > 1KB
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Check if ayah is already downloaded.
  Future<bool> isDownloaded(
      String reciterId, int surahNumber, int ayahNumber) async {
    final path = await _audioFilePath(reciterId, surahNumber, ayahNumber);
    return _isValidFile(path);
  }

  /// Get local file path if downloaded, null otherwise.
  Future<String?> getLocalPath(
      String reciterId, int surahNumber, int ayahNumber) async {
    final path = await _audioFilePath(reciterId, surahNumber, ayahNumber);
    return _isValidFile(path) ? path : null;
  }

  /// Download a single ayah. Returns local file path.
  Future<String> downloadAyah({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final taskId = '${reciterId}_${surahNumber}_$ayahNumber';
    final path = await _audioFilePath(reciterId, surahNumber, ayahNumber);

    // Check if already downloaded
    if (_isValidFile(path)) return path;

    // Get or create task
    var task = PersistenceService.downloadsBox.get(taskId) ??
        DownloadTask.pending(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          reciterId: reciterId,
        );

    // Prevent duplicate concurrent downloads
    if (_cancelTokens.containsKey(taskId)) return path;

    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;

    task = task.copyWith(statusIndex: DownloadStatus.downloading.index);
    await PersistenceService.downloadsBox.put(taskId, task);

    final url = ApiConstants.ayahAudioUrl(reciterId, surahNumber, ayahNumber);

    try {
      final startBytes = task.bytesDownloaded;

      await _dio.download(
        url,
        path,
        cancelToken: cancelToken,
        options: Options(
          headers: startBytes > 0 ? {'Range': 'bytes=$startBytes-'} : null,
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            // We can't update Hive on every byte, so we just update the stream
            _progressController.add(DownloadProgress(
              taskId: taskId,
              surahNumber: surahNumber,
              ayahNumber: ayahNumber,
              progress: received / total,
              status: DownloadStatus.downloading,
            ));
          }
        },
        deleteOnError: false, // Keep partial file for resume
      );

      task = task.copyWith(
        statusIndex: DownloadStatus.completed.index,
        bytesDownloaded: File(path).lengthSync(),
        totalBytes: File(path).lengthSync(),
      );
      await PersistenceService.downloadsBox.put(taskId, task);
      
      _progressController.add(DownloadProgress(
        taskId: taskId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        progress: 1.0,
        status: DownloadStatus.completed,
      ));
      return path;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        task = task.copyWith(statusIndex: DownloadStatus.paused.index);
      } else {
        task = task.copyWith(statusIndex: DownloadStatus.failed.index);
        // Remove corrupted partial file
        final f = File(path);
        if (f.existsSync() && f.lengthSync() == 0) await f.delete();
      }
      await PersistenceService.downloadsBox.put(taskId, task);
      throw DownloadFailure(e.message ?? 'Download failed');
    } finally {
      _cancelTokens.remove(taskId);
    }
  }

  /// Download all ayahs for a surah.
  Future<void> downloadSurah({
    required String reciterId,
    required int surahNumber,
    required int totalAyahs,
  }) async {
    for (var ayah = 1; ayah <= totalAyahs; ayah++) {
      try {
        await downloadAyah(
          reciterId: reciterId,
          surahNumber: surahNumber,
          ayahNumber: ayah,
        );
      } catch (_) {
        // Continue with next ayah even if one fails
      }
    }
  }

  /// Cancel/pause a download.
  void pauseDownload(String taskId) {
    _cancelTokens[taskId]?.cancel('Paused by user');
  }

  /// Delete downloaded surah files.
  Future<void> deleteSurah({
    required String reciterId,
    required int surahNumber,
    required int totalAyahs,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final surahStr = surahNumber.toString().padLeft(3, '0');
    final path =
        '${dir.path}/${AppConstants.audioStorageSubPath}/$reciterId/$surahStr';
    final directory = Directory(path);
    if (directory.existsSync()) await directory.delete(recursive: true);

    // Clean up tasks from Hive
    for (var ayah = 1; ayah <= totalAyahs; ayah++) {
      final taskId = '${reciterId}_${surahNumber}_$ayah';
      await PersistenceService.downloadsBox.delete(taskId);
    }
  }

  /// Delete all downloads.
  Future<void> deleteAllDownloads() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${AppConstants.audioStorageSubPath}';
    final directory = Directory(path);
    if (directory.existsSync()) await directory.delete(recursive: true);
    await PersistenceService.downloadsBox.clear();
  }

  void dispose() {
    for (final token in _cancelTokens.values) {
      token.cancel('Service disposed');
    }
    _progressController.close();
  }
}
