import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/sleep_sound.dart';
import '../../../core/services/sleep_sounds_api_service.dart';

/// Provider for sleep sounds data from API
final sleepSoundsProvider = FutureProvider<List<SleepSound>>((ref) async {
  try {
    // Try to load from API first
    final sounds = await SleepSoundsApiService.getAllSleepSounds();
    return sounds;
  } catch (e) {
    // Fallback to static data if API fails
    print('Failed to load sounds from API, using fallback data: $e');
    return _getSampleSleepSounds();
  }
});

/// Provider for sounds filtered by category
final soundsByCategoryProvider =
    FutureProvider.family<List<SleepSound>, SoundCategory>((
      ref,
      category,
    ) async {
      try {
        // Load sounds from API with category filter
        final sounds = await SleepSoundsApiService.getSoundsByCategory(
          category.displayName,
        );
        return sounds;
      } catch (e) {
        // Fallback: get all sounds and filter locally
        final allSounds = await ref.watch(sleepSoundsProvider.future);
        return allSounds
            .where((sound) => sound.category == category.displayName)
            .toList();
      }
    });

/// Provider for recently played sounds
final recentlyPlayedProvider = StateProvider<List<SleepSound>>((ref) => []);

/// Sample sleep sounds data
List<SleepSound> _getSampleSleepSounds() {
  return [
    // Nature Sounds
    SleepSound(
      id: 'rain_1',
      title: 'Heavy Rain',
      subtitle: 'Nature Sounds',
      category: SoundCategory.nature.displayName,
      audioPath: 'audio/rain_heavy.mp3',
      imagePath: 'lib/assets/images/rain.jpg',
      duration: const Duration(minutes: 30),
      isLooping: true,
    ),
    SleepSound(
      id: 'rain_2',
      title: 'Light Rain',
      subtitle: 'Nature Sounds',
      category: SoundCategory.nature.displayName,
      audioPath: 'lib/assets/audio/rain_light.mp3',
      imagePath: 'lib/assets/images/rain_light.jpg',
      duration: const Duration(minutes: 25),
      isLooping: true,
    ),
    SleepSound(
      id: 'ocean_1',
      title: 'Ocean Waves',
      subtitle: 'Nature Sounds',
      category: SoundCategory.nature.displayName,
      audioPath: 'lib/assets/audio/ocean_waves.mp3',
      imagePath: 'lib/assets/images/ocean.jpg',
      duration: const Duration(minutes: 45),
      isLooping: true,
    ),
    SleepSound(
      id: 'forest_1',
      title: 'Forest Sounds',
      subtitle: 'Nature Sounds',
      category: SoundCategory.nature.displayName,
      audioPath: 'lib/assets/audio/forest_ambient.mp3',
      imagePath: 'lib/assets/images/forest.jpg',
      duration: const Duration(minutes: 35),
      isLooping: true,
    ),

    // White Noise
    SleepSound(
      id: 'white_1',
      title: 'White Noise',
      subtitle: 'Background Noise',
      category: SoundCategory.whiteNoise.displayName,
      audioPath: 'lib/assets/audio/white_noise.mp3',
      imagePath: 'lib/assets/images/white_noise.jpg',
      duration: const Duration(minutes: 60),
      isLooping: true,
    ),
    SleepSound(
      id: 'pink_1',
      title: 'Pink Noise',
      subtitle: 'Background Noise',
      category: SoundCategory.whiteNoise.displayName,
      audioPath: 'lib/assets/audio/pink_noise.mp3',
      imagePath: 'lib/assets/images/pink_noise.jpg',
      duration: const Duration(minutes: 60),
      isLooping: true,
    ),
    SleepSound(
      id: 'brown_1',
      title: 'Brown Noise',
      subtitle: 'Background Noise',
      category: SoundCategory.whiteNoise.displayName,
      audioPath: 'lib/assets/audio/brown_noise.mp3',
      imagePath: 'lib/assets/images/brown_noise.jpg',
      duration: const Duration(minutes: 60),
      isLooping: true,
    ),

    // Meditation
    SleepSound(
      id: 'meditation_1',
      title: 'Deep Sleep Meditation',
      subtitle: 'Guided Meditation',
      category: SoundCategory.meditation.displayName,
      audioPath: 'lib/assets/audio/meditation_deep.mp3',
      imagePath: 'lib/assets/images/meditation.jpg',
      duration: const Duration(minutes: 20),
      isLooping: false,
    ),
    SleepSound(
      id: 'meditation_2',
      title: 'Body Scan',
      subtitle: 'Relaxation',
      category: SoundCategory.meditation.displayName,
      audioPath: 'lib/assets/audio/body_scan.mp3',
      imagePath: 'lib/assets/images/body_scan.jpg',
      duration: const Duration(minutes: 15),
      isLooping: false,
    ),

    // Binaural Beats
    SleepSound(
      id: 'binaural_1',
      title: 'Delta Waves',
      subtitle: 'Deep Sleep',
      category: SoundCategory.binaural.displayName,
      audioPath: 'lib/assets/audio/delta_waves.mp3',
      imagePath: 'lib/assets/images/binaural.jpg',
      duration: const Duration(minutes: 45),
      isLooping: true,
    ),
    SleepSound(
      id: 'binaural_2',
      title: 'Theta Waves',
      subtitle: 'REM Sleep',
      category: SoundCategory.binaural.displayName,
      audioPath: 'lib/assets/audio/theta_waves.mp3',
      imagePath: 'lib/assets/images/theta.jpg',
      duration: const Duration(minutes: 40),
      isLooping: true,
    ),

    // Instrumental
    SleepSound(
      id: 'piano_1',
      title: 'Soft Piano',
      subtitle: 'Classical',
      category: SoundCategory.instrumental.displayName,
      audioPath: 'lib/assets/audio/soft_piano.mp3',
      imagePath: 'lib/assets/images/piano.jpg',
      duration: const Duration(minutes: 30),
      isLooping: true,
    ),
    SleepSound(
      id: 'guitar_1',
      title: 'Acoustic Guitar',
      subtitle: 'Relaxing',
      category: SoundCategory.instrumental.displayName,
      audioPath: 'lib/assets/audio/acoustic_guitar.mp3',
      imagePath: 'lib/assets/images/guitar.jpg',
      duration: const Duration(minutes: 25),
      isLooping: true,
    ),

    // Ambient
    SleepSound(
      id: 'ambient_1',
      title: 'Space Ambient',
      subtitle: 'Cosmic Sounds',
      category: SoundCategory.ambient.displayName,
      audioPath: 'lib/assets/audio/space_ambient.mp3',
      imagePath: 'lib/assets/images/space.jpg',
      duration: const Duration(minutes: 50),
      isLooping: true,
    ),
    SleepSound(
      id: 'ambient_2',
      title: 'Dream Pad',
      subtitle: 'Ethereal',
      category: SoundCategory.ambient.displayName,
      audioPath: 'lib/assets/audio/dream_pad.mp3',
      imagePath: 'lib/assets/images/dream.jpg',
      duration: const Duration(minutes: 40),
      isLooping: true,
    ),
  ];
}
