// lib/data/models/surah_model.dart

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
        number: json['number'] as int,
        name: json['name'] as String? ?? '',
        englishName: json['englishName'] as String? ?? '',
        englishNameTranslation: json['englishNameTranslation'] as String? ?? '',
        numberOfAyahs: json['numberOfAyahs'] as int? ?? 0,
        revelationType: json['revelationType'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'name': name,
        'englishName': englishName,
        'englishNameTranslation': englishNameTranslation,
        'numberOfAyahs': numberOfAyahs,
        'revelationType': revelationType,
      };

  @override
  String toString() => 'Surah($number: $englishName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Surah && other.number == number);

  @override
  int get hashCode => number.hashCode;
}
