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

  /// Create SleepSound from JSON data (from API)
  factory SleepSound.fromJson(Map<String, dynamic> json) {
    return SleepSound(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      category: json['category'] as String,
      audioPath: json['audioPath'] as String,
      imagePath: json['imagePath'] as String?,
      duration: Duration(minutes: (json['duration'] as num).toInt()),
      isLooping: json['isLooping'] as bool? ?? true,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  /// Convert SleepSound to JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'audioPath': audioPath,
      'imagePath': imagePath,
      'duration': duration.inMinutes,
      'isLooping': isLooping,
      'isPremium': isPremium,
    };
  }

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