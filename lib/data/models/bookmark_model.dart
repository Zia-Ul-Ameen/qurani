// lib/data/models/bookmark_model.dart

class Bookmark {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;
  final String surahName;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.surahName,
    required this.createdAt,
  });

  factory Bookmark.create({
    required int surahNumber,
    required int ayahNumber,
    required String ayahText,
    required String surahName,
  }) =>
      Bookmark(
        id: '${surahNumber}_$ayahNumber',
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        ayahText: ayahText,
        surahName: surahName,
        createdAt: DateTime.now(),
      );
}
