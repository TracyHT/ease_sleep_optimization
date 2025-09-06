import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../ui/components/gradient_background.dart';
import '../providers/sleep_sounds_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/modern_audio_player.dart';

class SoundListScreen extends ConsumerWidget {
  final String categoryTitle;
  final String categoryName;

  const SoundListScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sleepSoundsAsync = ref.watch(sleepSoundsProvider);
    final audioState = ref.watch(audioPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        primaryOpacity: 0.05,
        child: SafeArea(
          child: sleepSoundsAsync.when(
            data: (sleepSounds) {
              final filteredSounds =
                  categoryName == 'Recently Play'
                      ? sleepSounds
                          .take(20)
                          .toList() // Show more recent sounds
                      : sleepSounds
                          .where((sound) => sound.category == categoryName)
                          .toList();

              if (filteredSounds.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.music_circle,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sounds available',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for new $categoryTitle sounds',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      '${filteredSounds.length} ${filteredSounds.length == 1 ? 'sound' : 'sounds'} available',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredSounds.length,
                        itemBuilder: (context, index) {
                          final sound = filteredSounds[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                child:
                                    sound.imagePath != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.asset(
                                            sound.imagePath!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Icon(
                                                Iconsax.music_circle,
                                                color:
                                                    theme.colorScheme.primary,
                                                size: 28,
                                              );
                                            },
                                          ),
                                        )
                                        : Icon(
                                          Iconsax.music_circle,
                                          color: theme.colorScheme.primary,
                                          size: 28,
                                        ),
                              ),
                              title: Text(
                                sound.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    sound.subtitle,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.clock,
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${sound.duration.inMinutes} min',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      if (sound.isPremium)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'PRO',
                                            style: TextStyle(
                                              color: Colors.amber,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                child: Icon(
                                  Iconsax.play,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              onTap: () {
                                ref
                                    .read(audioPlayerProvider.notifier)
                                    .playSound(sound);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // Add bottom spacing for audio player when it's visible
                    if (audioState.currentSound != null)
                      const SizedBox(height: 80),
                  ],
                ),
              );
            },
            loading:
                () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading sounds...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
            error:
                (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.warning_2,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load sounds',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(sleepSoundsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
      bottomSheet:
          audioState.currentSound != null ? const ModernAudioPlayer() : null,
    );
  }
}
