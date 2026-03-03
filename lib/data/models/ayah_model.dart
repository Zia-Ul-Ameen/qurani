// lib/data/models/ayah_model.dart

class Ayah {
  final int number;         // Global ayah number (1–6236)
  final int numberInSurah; // Ayah number within surah
  final String text;        // Arabic text (Uthmani)
  final String? translation;
  final int juz;
  final int page;
  final int hizbQuarter;
  final int surahNumber;
  final bool sajda;

  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.translation,
    required this.juz,
    required this.page,
    required this.hizbQuarter,
    required this.surahNumber,
    this.sajda = false,
  });

  String get id => '$surahNumber:$numberInSurah';

  factory Ayah.fromJson(Map<String, dynamic> json, {
    int? surahNumberOverride,
    String? translationText,
  }) {
    final sajdaRaw = json['sajda'];
    final bool hasSajda = sajdaRaw is bool
        ? sajdaRaw
        : (sajdaRaw is Map && (sajdaRaw['recommended'] == true || sajdaRaw['obligatory'] == true));

    return Ayah(
      number: json['number'] as int? ?? 0,
      numberInSurah: json['numberInSurah'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      translation: translationText,
      juz: json['juz'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      hizbQuarter: json['hizbQuarter'] as int? ?? 0,
      surahNumber: surahNumberOverride ??
          (json['surah'] is Map ? json['surah']['number'] as int? ?? 0 : 0),
      sajda: hasSajda,
    );
  }

  Ayah copyWith({String? translation}) => Ayah(
        number: number,
        numberInSurah: numberInSurah,
        text: text,
        translation: translation ?? this.translation,
        juz: juz,
        page: page,
        hizbQuarter: hizbQuarter,
        surahNumber: surahNumber,
        sajda: sajda,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ayah && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
