// lib/data/services/audio_player_service.dart
// Wraps just_audio in an audio_service AudioHandler for background playback.

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/api_constants.dart';
import 'download_service.dart';

enum LoopMode { none, ayah, surah }

class AudioPlayerService extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final DownloadService _downloadService;

  List<MediaItem> _playlist = [];
  int _currentIndex = 0;
  LoopMode _loopMode = LoopMode.none;
  double _speed = 1.0;

  // Completion tracking — for hasanāt / reading progress
  final _ayahCompletionController = StreamController<int>.broadcast();
  Stream<int> get ayahCompletedStream => _ayahCompletionController.stream;

  AudioPlayerService(this._downloadService) {
    _player.playbackEventStream.listen(_broadcastState, onError: (e, st) {
      // Silently log; never crash on audio error
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompleted();
      }
    });

    _player.positionStream.listen((position) {
      _checkAyahCompletion(position);
    });
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> loadSurah({
    required int surahNumber,
    required List<int> ayahNumbers,
    required String reciterId,
    int startIndex = 0,
  }) async {
    _currentIndex = startIndex;

    _playlist = ayahNumbers.map((ayahNum) {
      return MediaItem(
        id: '$surahNumber:$ayahNum',
        title: 'Ayah $ayahNum',
        album: 'Surah $surahNumber',
        extras: {
          'surahNumber': surahNumber,
          'ayahNumber': ayahNum,
          'reciterId': reciterId,
        },
      );
    }).toList();

    mediaItem.add(_playlist[startIndex]);
    await _setSource(startIndex);
  }

  Future<void> _setSource(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    _currentIndex = index;
    mediaItem.add(_playlist[index]);

    final extras = _playlist[index].extras!;
    final surahNum = extras['surahNumber'] as int;
    final ayahNum = extras['ayahNumber'] as int;
    final reciter = extras['reciterId'] as String;

    try {
      // Prefer local file; fall back to network stream
      final localPath =
          await _downloadService.getLocalPath(reciter, surahNum, ayahNum);

      AudioSource source;
      if (localPath != null) {
        source = AudioSource.file(localPath);
      } else {
        final url = ApiConstants.ayahAudioUrl(reciter, surahNum, ayahNum);
        source = AudioSource.uri(Uri.parse(url));
      }

      await _player.setAudioSource(source);
      await _player.setSpeed(_speed);
    } catch (e) {
      // Defensive: if audio source fails, skip to next
      if (index + 1 < _playlist.length) {
        await _setSource(index + 1);
      }
    }
  }

  // ─── BaseAudioHandler overrides ────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    _broadcastState(_player.playbackEvent);
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _playNext();

  @override
  Future<void> skipToPrevious() => _playPrevious();

  Future<void> playAyah(int index) => _setSource(index).then((_) => play());

  Future<void> _playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      await _setSource(_currentIndex + 1);
      await play();
    } else if (_loopMode == LoopMode.surah) {
      await _setSource(0);
      await play();
    }
  }

  Future<void> _playPrevious() async {
    if (_currentIndex > 0) {
      await _setSource(_currentIndex - 1);
      await play();
    }
  }

  void _handleTrackCompleted() {
    // Notify completion for hasanāt tracking
    _ayahCompletionController.add(_currentIndex);

    switch (_loopMode) {
      case LoopMode.ayah:
        _player.seek(Duration.zero).then((_) => play());
        break;
      case LoopMode.surah:
      case LoopMode.none:
        _playNext();
        break;
    }
  }

  // 80% completion threshold for hasanāt
  Duration? _ayahDuration;
  bool _ayahCounted = false;

  void _checkAyahCompletion(Duration position) {
    _ayahDuration ??= _player.duration;
    final dur = _ayahDuration;
    if (dur != null && dur.inMilliseconds > 0) {
      final progress = position.inMilliseconds / dur.inMilliseconds;
      if (progress >= 0.80 && !_ayahCounted) {
        _ayahCounted = true;
        _ayahCompletionController.add(_currentIndex);
      }
    }
  }

  // ─── Speed ─────────────────────────────────────────────────────────────────

  @override
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _player.setSpeed(speed);
  }

  double get speed => _speed;

  // ─── Loop ──────────────────────────────────────────────────────────────────

  void setLoopMode(LoopMode mode) => _loopMode = mode;
  LoopMode get loopMode => _loopMode;

  // ─── State ─────────────────────────────────────────────────────────────────

  int get currentIndex => _currentIndex;
  List<MediaItem> get playlist => _playlist;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  bool get isPlaying => _player.playing;

  void _broadcastState(PlaybackEvent event) {
    final isPlaying = _player.playing;
    final processingState = {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState] ??
        AudioProcessingState.idle;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processingState,
      playing: isPlaying,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ));
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _ayahCompletionController.close();
  }
}
