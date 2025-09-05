import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../ui/components/section_heading.dart';
import '../widgets/small_audio_card.dart';
import '../widgets/suggestion_card.dart';
import '../widgets/modern_audio_player.dart';
import '../providers/sleep_sounds_provider.dart';
import '../providers/audio_player_provider.dart';
import '../../../core/models/sleep_sound.dart';
import '../../../ui/components/gradient_background.dart';

class SleepaidsScreens extends ConsumerWidget {
  const SleepaidsScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sleepSoundsAsync = ref.watch(sleepSoundsProvider);
    final audioState = ref.watch(audioPlayerProvider);
    return Scaffold(
      body: GradientBackground(
        primaryOpacity: 0.05,
        child: SafeArea(
          child: sleepSoundsAsync.when(
            data:
                (sleepSounds) => SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).padding.left,
                    MediaQuery.of(context).padding.top,
                    MediaQuery.of(context).padding.right,
                    MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enhance your restful moment.",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Explore various sleep aids to enhance your sleep quality.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SectionHeading(
                              title: "Recently Play",
                              nav: "More",
                              onTap: () {
                                // navigate to Recently Played screen
                              },
                            ),
                            _buildHorizontalList(
                              sleepSounds
                                  .where(
                                    (s) =>
                                        s.category ==
                                        SoundCategory.nature.displayName,
                                  )
                                  .toList(),
                            ),

                            SectionHeading(
                              title: "Suggested for you",
                              nav: "More",
                              onTap: () {},
                            ),
                            const LargeSuggestionCard(),

                            SectionHeading(
                              title: "White Noise",
                              nav: "More",
                              onTap: () {},
                            ),
                            _buildHorizontalList(
                              sleepSounds
                                  .where(
                                    (s) =>
                                        s.category ==
                                        SoundCategory.whiteNoise.displayName,
                                  )
                                  .toList(),
                            ),

                            SectionHeading(
                              title: "Meditation",
                              nav: "More",
                              onTap: () {},
                            ),
                            _buildHorizontalList(
                              sleepSounds
                                  .where(
                                    (s) =>
                                        s.category ==
                                        SoundCategory.meditation.displayName,
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            loading:
                () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading sleep sounds...',
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
                        'Failed to load sleep sounds',
                        style: TextStyle(
                          color: colorScheme.error,
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
      // Add modern floating audio player
      bottomSheet:
          audioState.currentSound != null ? const ModernAudioPlayer() : null,
    );
  }

  Widget _buildHorizontalList(List<SleepSound> sounds) {
    if (sounds.isEmpty) {
      return const SizedBox(height: 80);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            sounds.take(5).map((sound) {
              final index = sounds.indexOf(sound);
              return Padding(
                padding: EdgeInsets.only(
                  right: index < sounds.length - 1 && index < 4 ? 12 : 0,
                ),
                child: SmallAudioCard(
                  sound: sound,
                  title: sound.title,
                  imagePath: sound.imagePath,
                  subtitle: sound.subtitle,
                ),
              );
            }).toList(),
      ),
    );
  }
}
