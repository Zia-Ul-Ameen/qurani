// lib/data/models/surah_detail_model.dart
// Holds a surah's ayahs with optional translations merged.

import 'surah_model.dart';
import 'ayah_model.dart';

class SurahDetail {
  final Surah surah;
  final List<Ayah> ayahs;
  final String? translationEdition;

  const SurahDetail({
    required this.surah,
    required this.ayahs,
    this.translationEdition,
  });

  /// Parse the two-edition response: editions[0] = Arabic, editions[1] = translation
  factory SurahDetail.fromEditionsJson(Map<String, dynamic> json) {
    try {
      final dataList = json['data'] as List<dynamic>;
      final arabicData = dataList[0] as Map<String, dynamic>;
      final translationData = dataList.length > 1
          ? dataList[1] as Map<String, dynamic>
          : null;

      final surahJson = arabicData['surah'] as Map<String, dynamic>? ?? {};
      final surahNumber = arabicData['number'] as int? ?? 0;
      final surah = Surah.fromJson({...surahJson, 'number': surahNumber});

      final arabicAyahs = arabicData['ayahs'] as List<dynamic>? ?? [];
      final translationAyahs =
          translationData?['ayahs'] as List<dynamic>? ?? [];

      final ayahs = List.generate(arabicAyahs.length, (i) {
        final aJson = arabicAyahs[i] as Map<String, dynamic>;
        String? translation;
        if (i < translationAyahs.length) {
          translation = (translationAyahs[i] as Map<String, dynamic>)['text']
              as String?;
        }
        return Ayah.fromJson(aJson,
            surahNumberOverride: surahNumber, translationText: translation);
      });

      return SurahDetail(
        surah: surah,
        ayahs: ayahs,
        translationEdition: translationData?['edition']?['identifier'] as String?,
      );
    } catch (e) {
      // Defensive fallback
      return SurahDetail(surah: const Surah(
        number: 0,
        name: '',
        englishName: 'Error',
        englishNameTranslation: '',
        numberOfAyahs: 0,
        revelationType: '',
      ), ayahs: const []);
    }
  }
}
