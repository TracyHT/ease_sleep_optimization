import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui';
import '../providers/audio_player_provider.dart';

class ModernAudioPlayer extends ConsumerStatefulWidget {
  const ModernAudioPlayer({super.key});

  @override
  ConsumerState<ModernAudioPlayer> createState() => _ModernAudioPlayerState();
}

class _ModernAudioPlayerState extends ConsumerState<ModernAudioPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioNotifier = ref.read(audioPlayerProvider.notifier);

    if (audioState.currentSound == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildPlayer(audioState, audioNotifier),
          ),
        );
      },
    );
  }

  Widget _buildPlayer(
    AudioPlayerState audioState,
    AudioPlayerNotifier audioNotifier,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy > 300) {
          setState(() => _isExpanded = false);
        } else if (details.velocity.pixelsPerSecond.dy < -300) {
          setState(() => _isExpanded = true);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        height: _isExpanded ? 380 : 160,
        child: Stack(
          children: [
            // Blurred background
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        colorScheme.surface.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Column(
              children: [
                // Drag indicator
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sound info row
                          Row(
                            children: [
                              // Album art with animation
                              Hero(
                                tag: 'album-art-${audioState.currentSound!.id}',
                                child: Container(
                                  width: _isExpanded ? 80 : 56,
                                  height: _isExpanded ? 80 : 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      _isExpanded ? 16 : 12,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      _isExpanded ? 16 : 12,
                                    ),
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          audioState.currentSound!.imagePath ??
                                              'lib/assets/images/placeholder.jpg',
                                          width: _isExpanded ? 80 : 56,
                                          height: _isExpanded ? 80 : 56,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors
                                                              .purple
                                                              .shade400,
                                                          Colors.blue.shade400,
                                                        ],
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Iconsax.music5,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                        ),
                                        if (audioState.isPlaying)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                            child: Center(
                                              child: _buildPlayingIndicator(),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Sound title and subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      audioState.currentSound!.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      audioState.currentSound!.subtitle,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Quick controls
                              if (!_isExpanded) ...[
                                IconButton(
                                  onPressed:
                                      () => audioNotifier.togglePlayPause(),
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      audioState.isPlaying
                                          ? Iconsax.pause5
                                          : Iconsax.play5,
                                      key: ValueKey(audioState.isPlaying),
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Expanded controls
                          if (_isExpanded) ...[
                            const SizedBox(height: 24),

                            // Progress bar
                            _buildProgressBar(audioState, audioNotifier),

                            const SizedBox(height: 24),

                            // Playback controls
                            _buildPlaybackControls(audioState, audioNotifier),

                            const SizedBox(height: 20),

                            // Volume control
                            _buildVolumeControl(audioState, audioNotifier),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 3,
          height: 12 + (index * 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildProgressBar(
    AudioPlayerState audioState,
    AudioPlayerNotifier audioNotifier,
  ) {
    final progress =
        audioState.totalDuration.inMilliseconds > 0
            ? audioState.currentPosition.inMilliseconds /
                audioState.totalDuration.inMilliseconds
            : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final newPosition = Duration(
                milliseconds:
                    (value * audioState.totalDuration.inMilliseconds).round(),
              );
              audioNotifier.seek(newPosition);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(audioState.currentPosition),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(audioState.totalDuration),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(
    AudioPlayerState audioState,
    AudioPlayerNotifier audioNotifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Loop button
        IconButton(
          onPressed: () {
            // Toggle loop functionality
          },
          icon: Icon(
            Iconsax.repeat5,
            color:
                audioState.currentSound?.isLooping == true
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
            size: 24,
          ),
        ),

        const SizedBox(width: 24),

        // Play/Pause button
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => audioNotifier.togglePlayPause(),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  audioState.isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Icon(
                        audioState.isPlaying ? Iconsax.pause5 : Iconsax.play5,
                        key: ValueKey(audioState.isPlaying),
                        color: Colors.white,
                        size: 32,
                      ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Stop button
        IconButton(
          onPressed: () => audioNotifier.stop(),
          icon: Icon(
            Iconsax.stop5,
            color: Colors.white.withValues(alpha: 0.7),
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeControl(
    AudioPlayerState audioState,
    AudioPlayerNotifier audioNotifier,
  ) {
    return Row(
      children: [
        Icon(
          Iconsax.volume_low5,
          color: Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: Colors.white.withValues(alpha: 0.8),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: audioState.volume,
              onChanged: (value) => audioNotifier.setVolume(value),
              min: 0.0,
              max: 1.0,
            ),
          ),
        ),
        Icon(
          Iconsax.volume_high5,
          color: Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
