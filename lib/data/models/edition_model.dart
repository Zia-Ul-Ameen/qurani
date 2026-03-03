// lib/data/models/edition_model.dart

class Edition {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;   // 'audio' or 'text'
  final String type;    // 'versebyverse', 'tafsir', etc.
  final String? direction; // rtl / ltr

  const Edition({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    this.direction,
  });

  factory Edition.fromJson(Map<String, dynamic> json) => Edition(
        identifier: json['identifier'] as String? ?? '',
        language: json['language'] as String? ?? '',
        name: json['name'] as String? ?? '',
        englishName: json['englishName'] as String? ?? '',
        format: json['format'] as String? ?? '',
        type: json['type'] as String? ?? '',
        direction: json['direction'] as String?,
      );

  bool get isAudio => format == 'audio';
  bool get isText => format == 'text';

  /// For audio editions, the folder name on everyayah.com
  /// defaults to identifier value.
  String get reciterFolder => identifier;

  @override
  String toString() => 'Edition($identifier: $englishName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Edition && other.identifier == identifier);

  @override
  int get hashCode => identifier.hashCode;
}
