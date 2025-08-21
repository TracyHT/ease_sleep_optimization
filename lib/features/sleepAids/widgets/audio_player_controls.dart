import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/sleep_sound.dart';
import '../providers/audio_player_provider.dart';

/// Widget for audio player controls (play/pause, stop, volume)
class AudioPlayerControls extends ConsumerWidget {
  final SleepSound? sound;
  final bool showVolumeSlider;
  final bool showProgressBar;

  const AudioPlayerControls({
    super.key,
    this.sound,
    this.showVolumeSlider = true,
    this.showProgressBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioNotifier = ref.read(audioPlayerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Currently playing info
          if (audioState.currentSound != null) ...[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    audioState.currentSound!.imagePath ?? 'lib/assets/images/placeholder.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audioState.currentSound!.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        audioState.currentSound!.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Progress bar
          if (showProgressBar && audioState.currentSound != null) ...[
            Row(
              children: [
                Text(
                  _formatDuration(audioState.currentPosition),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: audioState.totalDuration.inMilliseconds > 0
                        ? audioState.currentPosition.inMilliseconds / audioState.totalDuration.inMilliseconds
                        : 0.0,
                    onChanged: (value) {
                      final newPosition = Duration(
                        milliseconds: (value * audioState.totalDuration.inMilliseconds).round(),
                      );
                      audioNotifier.seek(newPosition);
                    },
                    activeColor: colorScheme.primary,
                  ),
                ),
                Text(
                  _formatDuration(audioState.totalDuration),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Play controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stop button
              IconButton(
                onPressed: audioState.currentSound != null
                    ? () => audioNotifier.stop()
                    : null,
                icon: const Icon(Icons.stop),
                iconSize: 32,
                color: colorScheme.onSurfaceVariant,
              ),
              
              const SizedBox(width: 24),
              
              // Play/Pause button
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: audioState.isLoading
                      ? null
                      : audioState.currentSound != null
                          ? () => audioNotifier.togglePlayPause()
                          : sound != null
                              ? () => audioNotifier.playSound(sound!)
                              : null,
                  icon: audioState.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Icon(
                          audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: colorScheme.onPrimary,
                        ),
                  iconSize: 32,
                ),
              ),
              
              const SizedBox(width: 24),
              
              // Loop indicator
              Icon(
                Icons.repeat,
                color: audioState.currentSound?.isLooping == true
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                size: 24,
              ),
            ],
          ),

          // Volume slider
          if (showVolumeSlider) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.volume_down,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                Expanded(
                  child: Slider(
                    value: audioState.volume,
                    onChanged: (value) => audioNotifier.setVolume(value),
                    activeColor: colorScheme.primary,
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
                Icon(
                  Icons.volume_up,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ],

          // Error message
          if (audioState.error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                audioState.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}