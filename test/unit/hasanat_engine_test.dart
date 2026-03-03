// test/unit/hasanat_engine_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/core/utils/hasanat_engine.dart';

void main() {
  group('HasanatEngine', () {
    test('counts base Arabic letters correctly (10 hasanat per letter)', () {
      // "Alhamdulillah" in Arabic: الـحـمـد لله
      // Letters: ا ل ح م د ل ل ه (8 letters)
      const text = 'الحمد لله';
      expect(HasanatEngine.computeHasanat(text), 80);
    });

    test('strips diacritics before counting', () {
      // "Bismillah" with harakat: بِسْمِ ٱللَّهِ
      // Letters: ب س م ا ل ل ه (7 letters)
      const text = 'بِسْمِ ٱللَّهِ';
      expect(HasanatEngine.computeHasanat(text), 70);
    });

    test('handles tatweel (kashida) correctly', () {
      // "Al-hamdu" with tatweel: الـحـمـد
      // Letters: ا ل ح م د (5 letters)
      const text = 'الـحـمـد';
      expect(HasanatEngine.computeHasanat(text), 50);
    });

    test('ignores non-Arabic characters', () {
      const text = 'Sura 1: الحمد';
      // Only "الحمد" (5 letters) should be counted
      expect(HasanatEngine.computeHasanat(text), 50);
    });

    test('memoization returns cached results', () {
      const text = 'قل هو الله أحد';
      final firstRun = HasanatEngine.computeHasanat(text);
      final secondRun = HasanatEngine.computeHasanat(text);
      expect(firstRun, secondRun);
      expect(firstRun, 110); // ق ل ه و ا ل ل ه ا ح د (11 letters)
    });
  });
}
