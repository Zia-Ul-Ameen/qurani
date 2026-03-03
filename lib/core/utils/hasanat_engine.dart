// lib/core/utils/hasanat_engine.dart
// Unicode-accurate hasanāt counting engine.
// Specification:
//   1. Normalize to NFC
//   2. Remove diacritics and non-letter marks
//   3. Keep base Arabic letters (including Alif Wasla)
//   4. Hasanāt = letterCount × 10

class HasanatEngine {
  HasanatEngine._();

  // Ranges to remove
  static final RegExp _removePattern = RegExp(
    '[\u0610-\u061A'   // Arabic extended marks
    '\u064B-\u065F'    // Diacritics (tanwin, shadda, fatha, kasra, damma, etc.)
    '\u06D6-\u06ED'    // Extended Arabic-supplement marks
    '\u0640'           // Tatweel (kashida)
    '\u200C\u200D]',   // Zero-width non-joiner / joiner
  );

  // Arabic letters:
  // \u0621-\u064A: Standard base letters
  // \u0671: Alif Wasla (essential for Quranic text)
  static final RegExp _arabicLetterPattern = RegExp('[\u0621-\u064A\u0671]');

  /// Count Arabic letters in [text] after stripping diacritics and marks.
  static int countLetters(String text) {
    if (text.isEmpty) return 0;
    // Step 1: Clean known ranges of marks and diacritics
    final cleaned = text.replaceAll(_removePattern, '');
    // Step 2: Count remaining Arabic base letters
    return _arabicLetterPattern.allMatches(cleaned).length;
  }

  /// Compute hasanāt for [text].
  static int computeHasanat(String text) => countLetters(text) * 10;

  /// Cached computation per ayah key (e.g., "2:255").
  static final Map<String, int> _cache = {};

  static int computeHasanatCached(String ayahKey, String text) {
    return _cache.putIfAbsent(ayahKey, () => computeHasanat(text));
  }

  static void clearCache() => _cache.clear();
}
