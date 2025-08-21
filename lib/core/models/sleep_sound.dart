/// Model representing a sleep sound/audio track
class SleepSound {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String audioPath;
  final String? imagePath;
  final Duration duration;
  final bool isLooping;
  final bool isPremium;

  const SleepSound({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.audioPath,
    this.imagePath,
    required this.duration,
    this.isLooping = true,
    this.isPremium = false,
  });

  SleepSound copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    String? audioPath,
    String? imagePath,
    Duration? duration,
    bool? isLooping,
    bool? isPremium,
  }) {
    return SleepSound(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      audioPath: audioPath ?? this.audioPath,
      imagePath: imagePath ?? this.imagePath,
      duration: duration ?? this.duration,
      isLooping: isLooping ?? this.isLooping,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

/// Categories of sleep sounds
enum SoundCategory {
  nature('Nature'),
  whiteNoise('White Noise'),
  meditation('Meditation'),
  binaural('Binaural Beats'),
  instrumental('Instrumental'),
  ambient('Ambient');

  const SoundCategory(this.displayName);
  final String displayName;
}