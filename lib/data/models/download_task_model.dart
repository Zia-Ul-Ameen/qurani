// lib/data/models/download_task_model.dart

enum DownloadStatus { pending, downloading, completed, failed, paused }

class DownloadTask {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String reciterId;
  final int statusIndex;
  final int bytesDownloaded;
  final int totalBytes;
  final DateTime createdAt;

  DownloadTask({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.reciterId,
    required this.statusIndex,
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.createdAt,
  });

  factory DownloadTask.pending({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) =>
      DownloadTask(
        id: '${reciterId}_${surahNumber}_$ayahNumber',
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        reciterId: reciterId,
        statusIndex: DownloadStatus.pending.index,
        bytesDownloaded: 0,
        totalBytes: 0,
        createdAt: DateTime.now(),
      );

  DownloadStatus get status => DownloadStatus.values[statusIndex];
  double get progress => totalBytes > 0 ? bytesDownloaded / totalBytes : 0.0;

  DownloadTask copyWith({
    int? statusIndex,
    int? bytesDownloaded,
    int? totalBytes,
  }) =>
      DownloadTask(
        id: id,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        reciterId: reciterId,
        statusIndex: statusIndex ?? this.statusIndex,
        bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
        totalBytes: totalBytes ?? this.totalBytes,
        createdAt: createdAt,
      );
}
