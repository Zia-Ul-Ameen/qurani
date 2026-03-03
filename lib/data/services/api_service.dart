// lib/data/services/api_service.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../models/surah_model.dart';
import '../models/surah_detail_model.dart';
import '../models/edition_model.dart';
import '../models/ayah_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));
    _dio.interceptors.add(_RetryInterceptor(_dio));
  }

  /// Fetch all 114 surahs.
  Future<List<Surah>> fetchSurahList() async {
    try {
      final response = await _dio.get(ApiConstants.surahList);
      final data = _extractData(response);
      if (data is! List) throw const ParseFailure('Expected list for surah list');
      return data
          .whereType<Map<String, dynamic>>()
          .map(Surah.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ParseFailure {
      rethrow;
    } catch (e) {
      throw ParseFailure('Unexpected error parsing surah list: $e');
    }
  }

  /// Fetch surah with both Arabic and translation editions.
  Future<SurahDetail> fetchSurahDetail(
    int number,
    String translationEdition,
  ) async {
    try {
      final url = ApiConstants.surahDetailUrl(number, translationEdition);
      final response = await _dio.get(url);
      final rawJson = response.data;
      if (rawJson is! Map<String, dynamic>) {
        throw const ParseFailure('Unexpected surah detail format');
      }
      return SurahDetail.fromEditionsJson(rawJson);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ParseFailure {
      rethrow;
    } catch (e) {
      throw ParseFailure('Unexpected error parsing surah detail: $e');
    }
  }

  /// Fetch all ayahs on a specific page.
  Future<List<Ayah>> fetchPage(int pageNumber) async {
    try {
      final response = await _dio.get(ApiConstants.pageUrl(pageNumber));
      final data = _extractData(response);
      if (data is! Map) throw const ParseFailure('Unexpected page format');
      final ayahsList = data['ayahs'] as List? ?? [];
      return ayahsList
          .whereType<Map<String, dynamic>>()
          .map((j) => Ayah.fromJson(j))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ParseFailure('Unexpected error parsing page: $e');
    }
  }

  /// Fetch all ayahs in a specific juz.
  Future<List<Ayah>> fetchJuz(int juzNumber) async {
    try {
      final response = await _dio.get(ApiConstants.juzUrl(juzNumber));
      final data = _extractData(response);
      if (data is! Map) throw const ParseFailure('Unexpected juz format');
      final ayahsList = data['ayahs'] as List? ?? [];
      return ayahsList
          .whereType<Map<String, dynamic>>()
          .map((j) => Ayah.fromJson(j))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ParseFailure('Unexpected error parsing juz: $e');
    }
  }

  /// Fetch all audio editions (reciters).
  Future<List<Edition>> fetchAudioEditions() async {
    try {
      final response = await _dio.get(ApiConstants.audioEditions);
      final data = _extractData(response);
      if (data is! List) throw const ParseFailure('Expected list for editions');
      return data
          .whereType<Map<String, dynamic>>()
          .map(Edition.fromJson)
          .where((e) => e.isAudio)
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ParseFailure('Unexpected error parsing editions: $e');
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  dynamic _extractData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      if (body['status'] != 'OK' && body['code'] != 200) {
        throw NetworkFailure(
          body['data']?.toString() ?? 'API error',
          statusCode: body['code'] as int?,
        );
      }
      return body['data'];
    }
    return body;
  }

  Failure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure('Connection timed out. Check your internet connection.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('No internet connection.');
    }
    return NetworkFailure(
      e.message ?? 'Unknown network error',
      statusCode: e.response?.statusCode,
    );
  }
}

// ─── Retry Interceptor ─────────────────────────────────────────────────────

class _RetryInterceptor extends Interceptor {
  final Dio dio;
  static const int _maxRetries = 2;

  _RetryInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final retryCount = requestOptions.extra['retryCount'] as int? ?? 0;
    if (retryCount < _maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError)) {
      requestOptions.extra['retryCount'] = retryCount + 1;
      await Future.delayed(Duration(seconds: retryCount + 1));
      try {
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // Fall through to original error
      }
    }
    return handler.next(err);
  }
}
