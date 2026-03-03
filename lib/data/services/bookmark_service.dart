// lib/data/services/bookmark_service.dart

import 'dart:async';
import '../models/bookmark_model.dart';
import 'persistence_service.dart';

class BookmarkService {
  final _changeController = StreamController<void>.broadcast();

  Stream<void> get changes => _changeController.stream;

  List<Bookmark> getAll() {
    final items = PersistenceService.bookmarksBox.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    final id = '${surahNumber}_$ayahNumber';
    return PersistenceService.bookmarksBox.containsKey(id);
  }

  Future<void> toggle({
    required int surahNumber,
    required int ayahNumber,
    required String ayahText,
    required String surahName,
  }) async {
    final id = '${surahNumber}_$ayahNumber';
    final box = PersistenceService.bookmarksBox;

    if (box.containsKey(id)) {
      await box.delete(id);
    } else {
      final bookmark = Bookmark.create(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        ayahText: ayahText,
        surahName: surahName,
      );
      await box.put(id, bookmark);
    }
    _changeController.add(null);
  }

  Future<void> remove(String id) async {
    await PersistenceService.bookmarksBox.delete(id);
    _changeController.add(null);
  }
}
