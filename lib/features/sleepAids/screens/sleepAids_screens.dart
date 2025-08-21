import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ui/components/section_heading.dart';
import '../widgets/small_audio_card.dart';
import '../widgets/suggestion_card.dart';

class SleepaidsScreens extends ConsumerWidget {
  const SleepaidsScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                    const Text(
                      "Enhance your rest with Ease.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Explore various sleep aids to enhance your sleep quality.",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    SectionHeading(
                      title: "Recently Play",
                      nav: "More",
                      onTap: () {
                        // navigate to Recently Played screen
                      },
                    ),
                    _buildHorizontalList(),
                    SectionHeading(
                      title: "Suggested for you",
                      nav: "More",
                      onTap: () {},
                    ),
                    const LargeSuggestionCard(),

                    SectionHeading(
                      title: "Healing Sounds",
                      nav: "More",
                      onTap: () {},
                    ),
                    _buildHorizontalList(),

                    SectionHeading(
                      title: "Sleep Articles",
                      nav: "More",
                      onTap: () {},
                    ),
                    _buildHorizontalList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Row(
        children: List.generate(
          5,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < 4 ? 12 : 0),
            child: const SmallAudioCard(
              title: "Rain",
              imagePath: null,
              subtitle: "White Noise",
            ),
          ),
        ),
      ),
    );
  }
}
