import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/sleep_sound.dart';
import '../providers/audio_player_provider.dart';

class SmallAudioCard extends ConsumerWidget {
  final SleepSound? sound;
  final String title;
  final String subtitle;
  final String? imagePath;
  final VoidCallback? onTap;

  const SmallAudioCard({
    super.key,
    this.sound,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioNotifier = ref.read(audioPlayerProvider.notifier);
    
    final isCurrentlyPlaying = audioState.currentSound?.id == sound?.id && audioState.isPlaying;
    final isCurrentSound = audioState.currentSound?.id == sound?.id;
    
    return GestureDetector(
      onTap: onTap ?? (sound != null ? () => audioNotifier.playSound(sound!) : null),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: isCurrentSound ? Colors.white.withValues(alpha: 0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: isCurrentSound ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // Image on the left with play indicator overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath ?? 'lib/assets/images/placeholder.jpg',
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (isCurrentlyPlaying)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                else if (isCurrentSound)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 8),

            // Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCurrentSound ? Colors.white : Colors.white,
                      fontWeight: isCurrentSound ? FontWeight.w600 : FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (isCurrentlyPlaying) ...[
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
