import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/sleep_sound.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../core/services/sleep_sounds_api_service.dart';

/// Provider for the audio player service
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService();
});

/// Provider for the current playing sound
final currentSoundProvider = StateProvider<SleepSound?>((ref) => null);

/// Provider for play/pause state
final isPlayingProvider = StateProvider<bool>((ref) => false);

/// Provider for current position
final currentPositionProvider = StateProvider<Duration>((ref) => Duration.zero);

/// Provider for total duration
final totalDurationProvider = StateProvider<Duration>((ref) => Duration.zero);

/// Provider for volume
final volumeProvider = StateProvider<double>((ref) => 1.0);

/// Notifier for managing audio playback state
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayerService _audioService;
  final Ref _ref;

  AudioPlayerNotifier(this._audioService, this._ref) : super(AudioPlayerState.initial()) {
    _initializeListeners();
  }

  void _initializeListeners() {
    _audioService.initialize();
  }

  /// Play a sound
  Future<void> playSound(SleepSound sound) async {
    try {
      state = state.copyWith(isLoading: true);
      
      await _audioService.playSound(sound);
      
      // Track play in database for analytics
      SleepSoundsApiService.incrementPopularity(sound.id);
      
      _ref.read(currentSoundProvider.notifier).state = sound;
      _ref.read(isPlayingProvider.notifier).state = true;
      
      state = state.copyWith(
        currentSound: sound,
        isPlaying: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _audioService.pause();
      _ref.read(isPlayingProvider.notifier).state = false;
      state = state.copyWith(isPlaying: false);
    } else {
      await _audioService.resume();
      _ref.read(isPlayingProvider.notifier).state = true;
      state = state.copyWith(isPlaying: true);
    }
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioService.stop();
    _ref.read(currentSoundProvider.notifier).state = null;
    _ref.read(isPlayingProvider.notifier).state = false;
    _ref.read(currentPositionProvider.notifier).state = Duration.zero;
    
    state = state.copyWith(
      currentSound: null,
      isPlaying: false,
      currentPosition: Duration.zero,
    );
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
    _ref.read(volumeProvider.notifier).state = volume;
    state = state.copyWith(volume: volume);
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
    _ref.read(currentPositionProvider.notifier).state = position;
    state = state.copyWith(currentPosition: position);
  }
}

/// Provider for the audio player notifier
final audioPlayerProvider = StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  final audioService = ref.read(audioPlayerServiceProvider);
  return AudioPlayerNotifier(audioService, ref);
});

/// State class for audio player
class AudioPlayerState {
  final SleepSound? currentSound;
  final bool isPlaying;
  final bool isLoading;
  final Duration currentPosition;
  final Duration totalDuration;
  final double volume;
  final String? error;

  const AudioPlayerState({
    this.currentSound,
    required this.isPlaying,
    required this.isLoading,
    required this.currentPosition,
    required this.totalDuration,
    required this.volume,
    this.error,
  });

  factory AudioPlayerState.initial() => const AudioPlayerState(
    isPlaying: false,
    isLoading: false,
    currentPosition: Duration.zero,
    totalDuration: Duration.zero,
    volume: 1.0,
  );

  AudioPlayerState copyWith({
    SleepSound? currentSound,
    bool? isPlaying,
    bool? isLoading,
    Duration? currentPosition,
    Duration? totalDuration,
    double? volume,
    String? error,
  }) {
    return AudioPlayerState(
      currentSound: currentSound ?? this.currentSound,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      volume: volume ?? this.volume,
      error: error,
    );
  }
}