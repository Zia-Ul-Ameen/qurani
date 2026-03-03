// lib/data/models/hive_adapters.dart
// Hand-written Hive TypeAdapters to avoid build_runner requirement.

import 'package:hive_flutter/hive_flutter.dart';
import 'bookmark_model.dart';
import 'hasanat_stats_model.dart';
import 'app_settings_model.dart';
import 'reading_progress_model.dart';
import 'download_task_model.dart';

// ─── Bookmark ──────────────────────────────────────────────────────────────

class BookmarkAdapter extends TypeAdapter<Bookmark> {
  @override
  final int typeId = 0;

  @override
  Bookmark read(BinaryReader reader) => Bookmark(
        id: reader.readString(),
        surahNumber: reader.readInt(),
        ayahNumber: reader.readInt(),
        ayahText: reader.readString(),
        surahName: reader.readString(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      );

  @override
  void write(BinaryWriter writer, Bookmark obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.surahNumber)
      ..writeInt(obj.ayahNumber)
      ..writeString(obj.ayahText)
      ..writeString(obj.surahName)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}

// ─── HasanatStats ──────────────────────────────────────────────────────────

class HasanatStatsAdapter extends TypeAdapter<HasanatStats> {
  @override
  final int typeId = 1;

  @override
  HasanatStats read(BinaryReader reader) {
    final total = reader.readInt();
    final today = reader.readInt();
    final lastReset = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final countedLen = reader.readInt();
    final counted = List.generate(countedLen, (_) => reader.readString());
    final cacheLen = reader.readInt();
    final cache = <String, int>{};
    for (var i = 0; i < cacheLen; i++) {
      final k = reader.readString();
      final v = reader.readInt();
      cache[k] = v;
    }
    return HasanatStats(
      totalHasanat: total,
      todayHasanat: today,
      lastResetDate: lastReset,
      countedAyahsToday: counted,
      ayahLetterCache: cache,
    );
  }

  @override
  void write(BinaryWriter writer, HasanatStats obj) {
    writer
      ..writeInt(obj.totalHasanat)
      ..writeInt(obj.todayHasanat)
      ..writeInt(obj.lastResetDate.millisecondsSinceEpoch)
      ..writeInt(obj.countedAyahsToday.length);
    for (final id in obj.countedAyahsToday) {
      writer.writeString(id);
    }
    writer.writeInt(obj.ayahLetterCache.length);
    for (final entry in obj.ayahLetterCache.entries) {
      writer..writeString(entry.key)..writeInt(entry.value);
    }
  }
}

// ─── AppSettings ───────────────────────────────────────────────────────────

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 2;

  @override
  AppSettings read(BinaryReader reader) => AppSettings(
        reciterId: reader.readString(),
        translationEditionId: reader.readString(),
        arabicFontSize: reader.readDouble(),
        translationFontSize: reader.readDouble(),
        themeModeIndex: reader.readInt(),
        highContrast: reader.readBool(),
        reduceMotion: reader.readBool(),
        defaultAudioSpeed: reader.readDouble(),
        showTranslation: reader.readBool(),
      );

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeString(obj.reciterId)
      ..writeString(obj.translationEditionId)
      ..writeDouble(obj.arabicFontSize)
      ..writeDouble(obj.translationFontSize)
      ..writeInt(obj.themeModeIndex)
      ..writeBool(obj.highContrast)
      ..writeBool(obj.reduceMotion)
      ..writeDouble(obj.defaultAudioSpeed)
      ..writeBool(obj.showTranslation);
  }
}

// ─── ReadingSession ─────────────────────────────────────────────────────────

class ReadingSessionAdapter extends TypeAdapter<ReadingSession> {
  @override
  final int typeId = 4;

  @override
  ReadingSession read(BinaryReader reader) => ReadingSession(
        date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
        surahNumber: reader.readInt(),
        ayahsRead: reader.readInt(),
      );

  @override
  void write(BinaryWriter writer, ReadingSession obj) {
    writer
      ..writeInt(obj.date.millisecondsSinceEpoch)
      ..writeInt(obj.surahNumber)
      ..writeInt(obj.ayahsRead);
  }
}

// ─── ReadingProgress ────────────────────────────────────────────────────────

class ReadingProgressAdapter extends TypeAdapter<ReadingProgress> {
  @override
  final int typeId = 3;

  @override
  ReadingProgress read(BinaryReader reader) {
    // completedAyahsBySurah
    final mapLen = reader.readInt();
    final map = <String, List<String>>{};
    for (var i = 0; i < mapLen; i++) {
      final key = reader.readString();
      final listLen = reader.readInt();
      map[key] = List.generate(listLen, (_) => reader.readString());
    }
    final currentStreak = reader.readInt();
    final longestStreak = reader.readInt();
    final hasLastRead = reader.readBool();
    final lastReadDate = hasLastRead
        ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
        : null;
    final sessionsLen = reader.readInt();
    final sessions = List.generate(
      sessionsLen,
      (_) => ReadingSession(
        date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
        surahNumber: reader.readInt(),
        ayahsRead: reader.readInt(),
      ),
    );
    final lastSurah = reader.readInt();
    final lastAyah = reader.readInt();
    return ReadingProgress(
      completedAyahsBySurah: map,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastReadDate: lastReadDate,
      recentSessions: sessions,
      lastSurahNumber: lastSurah,
      lastAyahNumber: lastAyah,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingProgress obj) {
    writer.writeInt(obj.completedAyahsBySurah.length);
    for (final entry in obj.completedAyahsBySurah.entries) {
      writer.writeString(entry.key);
      writer.writeInt(entry.value.length);
      for (final id in entry.value) {
        writer.writeString(id);
      }
    }
    writer
      ..writeInt(obj.currentStreak)
      ..writeInt(obj.longestStreak)
      ..writeBool(obj.lastReadDate != null);
    if (obj.lastReadDate != null) {
      writer.writeInt(obj.lastReadDate!.millisecondsSinceEpoch);
    }
    writer.writeInt(obj.recentSessions.length);
    for (final s in obj.recentSessions) {
      writer
        ..writeInt(s.date.millisecondsSinceEpoch)
        ..writeInt(s.surahNumber)
        ..writeInt(s.ayahsRead);
    }
    writer
      ..writeInt(obj.lastSurahNumber)
      ..writeInt(obj.lastAyahNumber);
  }
}

// ─── DownloadTask ───────────────────────────────────────────────────────────

class DownloadTaskAdapter extends TypeAdapter<DownloadTask> {
  @override
  final int typeId = 5;

  @override
  DownloadTask read(BinaryReader reader) => DownloadTask(
        id: reader.readString(),
        surahNumber: reader.readInt(),
        ayahNumber: reader.readInt(),
        reciterId: reader.readString(),
        statusIndex: reader.readInt(),
        bytesDownloaded: reader.readInt(),
        totalBytes: reader.readInt(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      );

  @override
  void write(BinaryWriter writer, DownloadTask obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.surahNumber)
      ..writeInt(obj.ayahNumber)
      ..writeString(obj.reciterId)
      ..writeInt(obj.statusIndex)
      ..writeInt(obj.bytesDownloaded)
      ..writeInt(obj.totalBytes)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
