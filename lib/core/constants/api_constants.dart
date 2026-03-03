// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.alquran.cloud/v1';
  static const String audioBaseUrl = 'https://everyayah.com/data';

  // Endpoints
  static const String surahList = '/surah';
  static const String surahDetail = '/surah/{number}/editions/{editions}';
  static const String page = '/page/{page}/quran-uthmani';
  static const String juz = '/juz/{juz}/quran-uthmani';
  static const String audioEditions = '/edition/type/audio';

  // Default editions
  static const String arabicEdition = 'quran-uthmani';
  static const String defaultTranslation = 'en.asad';
  static const String defaultReciterFolder = 'Alafasy_128kbps';
  static const String defaultReciterId = 'Alafasy_128kbps';

  static String surahDetailUrl(int number, String translationEdition) {
    return '/surah/$number/editions/$arabicEdition,$translationEdition';
  }

  static String pageUrl(int pageNumber) => '/page/$pageNumber/quran-uthmani';
  static String juzUrl(int juzNumber) => '/juz/$juzNumber/quran-uthmani';

  static String ayahAudioUrl(String reciterFolder, int surahNumber, int ayahNumber) {
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');
    return '$audioBaseUrl/$reciterFolder/$surah$ayah.mp3';
  }
}
