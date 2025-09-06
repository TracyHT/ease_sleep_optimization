import 'package:audioplayers/audioplayers.dart';
import '../core/models/sleep_sound.dart';

/// Singleton service for managing audio playback
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  SleepSound? _currentSound;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Getters
  bool get isPlaying => _isPlaying;
  SleepSound? get currentSound => _currentSound;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  AudioPlayer get audioPlayer => _audioPlayer;

  /// Initialize the audio player with listeners
  Future<void> initialize() async {
    // Listen for player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
    });

    // Listen for position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      _currentPosition = position;
    });

    // Listen for duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      _totalDuration = duration;
    });

    // Handle playback completion
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      _currentPosition = Duration.zero;
      
      // If looping is enabled, restart the track
      if (_currentSound?.isLooping == true) {
        playSound(_currentSound!);
      }
    });
  }

  /// Play a sleep sound
  Future<void> playSound(SleepSound sound) async {
    try {
      _currentSound = sound;
      
      // Stop current playback if any
      await _audioPlayer.stop();
      
      // Try to play the sound, handling different audio sources
      try {
        // Check if it's a URL (from database/server) or local asset
        if (sound.audioPath.startsWith('http://') || sound.audioPath.startsWith('https://')) {
          // Remote URL from server
          await _audioPlayer.play(UrlSource(sound.audioPath));
        } else {
          // Handle MongoDB relative paths and local assets
          // Files are now in assets/audio/ directory
          String assetPath;
          
          if (sound.audioPath.startsWith('assets/')) {
            // Already has assets/ prefix - use as is
            assetPath = sound.audioPath;
          } else if (sound.audioPath.startsWith('audio/')) {
            // MongoDB path format - already perfect for AssetSource
            // AssetSource will add "assets/" making it "assets/audio/rain_heavy.mp3"
            assetPath = sound.audioPath;
          } else if (sound.audioPath.startsWith('lib/assets/')) {
            // Old format from fallback data - strip lib/assets/ and keep audio/
            assetPath = sound.audioPath.substring(11); // Remove "lib/assets/"
          } else {
            // Default - assume it's just the filename
            assetPath = 'audio/${sound.audioPath}';
          }
          
          // Debug logging
          print('Playing audio - Original: ${sound.audioPath} -> Asset path for AssetSource: $assetPath');
          
          // AssetSource will prepend "assets/" to make "assets/audio/file.mp3"
          await _audioPlayer.play(AssetSource(assetPath));
        }
      } catch (audioError) {
        print('Audio file not found or failed to play: ${sound.audioPath}');
        print('Error: $audioError');
        // For demo purposes, simulate playback even without actual audio files
        _isPlaying = true;
        
        // Simulate duration
        _totalDuration = sound.duration;
        
        // If the actual file is missing, we'll just track time without audio
        _simulatePlayback(sound);
        return;
      }
      
      // Set loop mode if needed
      if (sound.isLooping) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayer.setReleaseMode(ReleaseMode.release);
      }
      
    } catch (e) {
      print('Error playing sound: $e');
      throw AudioException('Failed to play sound: ${sound.title}');
    }
  }

  /// Simulate playback for demo purposes when audio files are missing
  void _simulatePlayback(SleepSound sound) {
    // This is a simple simulation for demo purposes
    // In a real app, you would want proper audio files
    print('Simulating playback of: ${sound.title}');
    
    // You could implement a timer here to simulate progress
    // For now, just set the state to playing
    _isPlaying = true;
  }

  /// Pause the current playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing playback: $e');
    }
  }

  /// Resume the current playback
  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      print('Error resuming playback: $e');
    }
  }

  /// Stop the current playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentSound = null;
      _currentPosition = Duration.zero;
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  /// Set the volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      if (_currentSound != null) {
        await resume();
      }
    }
  }

  /// Dispose of the audio player
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

/// Custom exception for audio-related errors
class AudioException implements Exception {
  final String message;
  AudioException(this.message);

  @override
  String toString() => 'AudioException: $message';
}