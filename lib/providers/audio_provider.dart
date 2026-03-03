// lib/providers/audio_provider.dart
// Riverpod provider for audio state management.

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/audio_player_service.dart';
import '../data/models/ayah_model.dart';
import 'providers.dart';

class AudioState {
  final bool isPlaying;
  final int currentAyahIndex;
  final int? currentSurahNumber;
  final double speed;
  final LoopMode loopMode;
  final bool hasActiveSession;

  const AudioState({
    required this.isPlaying,
    required this.currentAyahIndex,
    this.currentSurahNumber,
    required this.speed,
    required this.loopMode,
    required this.hasActiveSession,
  });

  const AudioState.idle()
      : isPlaying = false,
        currentAyahIndex = 0,
        currentSurahNumber = null,
        speed = 1.0,
        loopMode = LoopMode.none,
        hasActiveSession = false;

  AudioState copyWith({
    bool? isPlaying,
    int? currentAyahIndex,
    int? currentSurahNumber,
    double? speed,
    LoopMode? loopMode,
    bool? hasActiveSession,
  }) =>
      AudioState(
        isPlaying: isPlaying ?? this.isPlaying,
        currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
        currentSurahNumber: currentSurahNumber ?? this.currentSurahNumber,
        speed: speed ?? this.speed,
        loopMode: loopMode ?? this.loopMode,
        hasActiveSession: hasActiveSession ?? this.hasActiveSession,
      );
}

class AudioNotifier extends StateNotifier<AudioState> {
  AudioPlayerService? _handler;
  final Ref _ref;

  AudioNotifier(this._ref) : super(const AudioState.idle());

  Future<AudioPlayerService> _getHandler() async {
    if (_handler != null) return _handler!;
    final downloadService = _ref.read(downloadServiceProvider);
    _handler = await AudioService.init(
      builder: () => AudioPlayerService(downloadService),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.zethic.quran.audio',
        androidNotificationChannelName: 'Quran Audio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );

    // Subscribe to state updates
    _handler!.playerStateStream.listen((ps) {
      state = state.copyWith(
        isPlaying: ps.playing,
        hasActiveSession: true,
      );
    });

    _handler!.ayahCompletedStream.listen((index) {
      // Notify reading progress + hasanāt
    });

    return _handler!;
  }

  Future<void> loadAndPlayAyah({
    required List<Ayah> ayahs,
    required int startIndex,
    required String reciterId,
  }) async {
    final handler = await _getHandler();
    await handler.loadSurah(
      surahNumber: ayahs.first.surahNumber,
      ayahNumbers: ayahs.map((a) => a.numberInSurah).toList(),
      reciterId: reciterId,
      startIndex: startIndex,
    );
    await handler.play();
    state = state.copyWith(
      isPlaying: true,
      currentAyahIndex: startIndex,
      currentSurahNumber: ayahs.first.surahNumber,
      hasActiveSession: true,
    );
  }

  Future<void> play() async => (await _getHandler()).play();
  Future<void> pause() async => (await _getHandler()).pause();
  Future<void> next() async => (await _getHandler()).skipToNext();
  Future<void> previous() async => (await _getHandler()).skipToPrevious();

  Future<void> setSpeed(double speed) async {
    await (await _getHandler()).setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    (await _getHandler()).setLoopMode(mode);
    state = state.copyWith(loopMode: mode);
  }

  Future<void> stop() async {
    await (await _getHandler()).stop();
    state = const AudioState.idle();
  }

  Stream<Duration>? get positionStream => _handler?.positionStream;
  Stream<Duration?>? get durationStream => _handler?.durationStream;

  @override
  void dispose() {
    _handler?.dispose();
    super.dispose();
  }
}

final audioProvider =
    StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier(ref);
});
