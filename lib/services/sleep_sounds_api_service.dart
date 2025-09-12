import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/models/sleep_sound.dart';

class SleepSoundsApiService {
  static const String baseUrl = 'http://192.168.1.102:3000/api/sleep-sounds';
  
  // Get all sleep sounds
  static Future<List<SleepSound>> getAllSleepSounds({
    String? category,
    bool? isPremium,
  }) async {
    try {
      String url = baseUrl;
      List<String> queryParams = [];
      
      if (category != null) {
        queryParams.add('category=$category');
      }
      if (isPremium != null) {
        queryParams.add('isPremium=$isPremium');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> soundsData = jsonData['data'];
          return soundsData.map((soundJson) => SleepSound.fromJson(soundJson)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw HttpException('Failed to load sleep sounds: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading sleep sounds from API: $e');
      // Return fallback data if API fails
      return _getFallbackSounds();
    }
  }
  
  // Get sounds by category
  static Future<List<SleepSound>> getSoundsByCategory(String category) async {
    return await getAllSleepSounds(category: category);
  }
  
  // Initialize default sounds in database
  static Future<bool> initializeDefaultSounds() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/initialize'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      } else {
        print('Failed to initialize sounds: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error initializing sounds: $e');
      return false;
    }
  }
  
  // Increment popularity when a sound is played
  static Future<void> incrementPopularity(String soundId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/$soundId/play'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Silently fail for analytics
      print('Failed to track play for sound $soundId: $e');
    }
  }
  
  // Fallback data in case API is unavailable
  static List<SleepSound> _getFallbackSounds() {
    return [
      SleepSound(
        id: "rain_heavy",
        title: "Heavy Rain",
        subtitle: "Intense rainfall sounds",
        category: SoundCategory.nature.displayName,
        audioPath: "audio/rain_heavy.mp3",
        imagePath: "lib/assets/images/rain.jpg",
        duration: const Duration(minutes: 30),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "rain_light",
        title: "Light Rain",
        subtitle: "Gentle rainfall sounds",
        category: SoundCategory.nature.displayName,
        audioPath: "audio/rain_light.mp3",
        imagePath: "lib/assets/images/rain.jpg",
        duration: const Duration(minutes: 30),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "ocean_waves",
        title: "Ocean Waves",
        subtitle: "Calming sea sounds",
        category: SoundCategory.nature.displayName,
        audioPath: "audio/ocean_waves.mp3",
        imagePath: "lib/assets/images/ocean.jpg",
        duration: const Duration(minutes: 45),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "forest_ambient",
        title: "Forest Ambient",
        subtitle: "Peaceful forest sounds",
        category: SoundCategory.nature.displayName,
        audioPath: "audio/forest_ambient.mp3",
        imagePath: "lib/assets/images/forest.jpg",
        duration: const Duration(minutes: 40),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "white_noise",
        title: "White Noise",
        subtitle: "Pure white noise",
        category: SoundCategory.whiteNoise.displayName,
        audioPath: "audio/white_noise.mp3",
        imagePath: "lib/assets/images/white_noise.jpg",
        duration: const Duration(minutes: 60),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "pink_noise",
        title: "Pink Noise",
        subtitle: "Balanced frequency noise",
        category: SoundCategory.whiteNoise.displayName,
        audioPath: "audio/pink_noise.mp3",
        imagePath: "lib/assets/images/pink_noise.jpg",
        duration: const Duration(minutes: 60),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "brown_noise",
        title: "Brown Noise",
        subtitle: "Deep, rumbling noise",
        category: SoundCategory.whiteNoise.displayName,
        audioPath: "audio/brown_noise.mp3",
        imagePath: "lib/assets/images/brown_noise.jpg",
        duration: const Duration(minutes: 60),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "meditation_deep",
        title: "Deep Sleep Meditation",
        subtitle: "Guided sleep meditation",
        category: SoundCategory.meditation.displayName,
        audioPath: "audio/meditation_deep.mp3",
        imagePath: "lib/assets/images/meditation.jpg",
        duration: const Duration(minutes: 25),
        isLooping: false,
        isPremium: true,
      ),
      SleepSound(
        id: "body_scan",
        title: "Body Scan Relaxation",
        subtitle: "Progressive muscle relaxation",
        category: SoundCategory.meditation.displayName,
        audioPath: "audio/body_scan.mp3",
        imagePath: "lib/assets/images/meditation.jpg",
        duration: const Duration(minutes: 20),
        isLooping: false,
        isPremium: true,
      ),
      SleepSound(
        id: "delta_waves",
        title: "Delta Wave Binaural",
        subtitle: "0.5-4Hz brainwave entrainment",
        category: SoundCategory.binaural.displayName,
        audioPath: "audio/delta_waves.mp3",
        imagePath: "lib/assets/images/binaural.jpg",
        duration: const Duration(minutes: 60),
        isLooping: true,
        isPremium: true,
      ),
      SleepSound(
        id: "theta_waves",
        title: "Theta Wave Binaural",
        subtitle: "4-8Hz brainwave entrainment",
        category: SoundCategory.binaural.displayName,
        audioPath: "audio/theta_waves.mp3",
        imagePath: "lib/assets/images/binaural.jpg",
        duration: const Duration(minutes: 45),
        isLooping: true,
        isPremium: true,
      ),
      SleepSound(
        id: "soft_piano",
        title: "Soft Piano",
        subtitle: "Gentle piano melodies",
        category: SoundCategory.instrumental.displayName,
        audioPath: "audio/soft_piano.mp3",
        imagePath: "lib/assets/images/piano.jpg",
        duration: const Duration(minutes: 35),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "acoustic_guitar",
        title: "Acoustic Guitar",
        subtitle: "Soothing guitar melodies",
        category: SoundCategory.instrumental.displayName,
        audioPath: "audio/acoustic_guitar.mp3",
        imagePath: "lib/assets/images/guitar.jpg",
        duration: const Duration(minutes: 30),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "space_ambient",
        title: "Space Ambient",
        subtitle: "Ethereal cosmic sounds",
        category: SoundCategory.ambient.displayName,
        audioPath: "audio/space_ambient.mp3",
        imagePath: "lib/assets/images/space.jpg",
        duration: const Duration(minutes: 50),
        isLooping: true,
        isPremium: false,
      ),
      SleepSound(
        id: "dream_pad",
        title: "Dream Pad",
        subtitle: "Dreamy synthesizer pad",
        category: SoundCategory.ambient.displayName,
        audioPath: "audio/dream_pad.mp3",
        imagePath: "lib/assets/images/dreams.jpg",
        duration: const Duration(minutes: 40),
        isLooping: true,
        isPremium: false,
      ),
    ];
  }
}