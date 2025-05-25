import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/song.dart';
import '../services/song_service.dart';

class NowPlayingSection extends ConsumerWidget {
  final Song song;
  final bool isPlaying;
  final double currentValue;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<double> onSliderChanged;

  const NowPlayingSection({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.currentValue,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onSliderChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the player state to access repeat and shuffle modes
    final playerState = ref.watch(songNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              song.albumArt,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.music_note,
                    size: 80,
                    color: Colors.white54,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Song title
          Text(
            song.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          // Artist profile section
          GestureDetector(
            onTap: () {
              context.push('/artists/${song.artist.id}');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Artist avatar
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(song.artist.imageUrl),
                    backgroundColor: Colors.grey[800],
                  ),
                  const SizedBox(width: 8),

                  // Artist name
                  Text(
                    song.artist.name,
                    style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                  ),

                  // Arrow icon
                  Icon(Icons.chevron_right, size: 16, color: Colors.grey[500]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Progress Bar
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Theme.of(context).colorScheme.secondary,
              inactiveTrackColor: Colors.grey[700],
              thumbColor: Theme.of(context).colorScheme.secondary,
              overlayColor: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.3),
            ),
            child: Slider(
              value: currentValue.clamp(
                0.0,
                1.0,
              ), // Ensure value is between 0 and 1
              min: 0.0,
              max: 1.0, // Changed from 100.0 to 1.0 to match the expected range
              onChanged: onSliderChanged,
            ),
          ),

          // Time Indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current position
                Text(
                  _formatPosition(song.duration, currentValue),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                // Total duration
                Text(
                  song.duration,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Shuffle button
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color:
                      playerState.isShuffleEnabled
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey[400],
                ),
                onPressed: () {
                  // Toggle shuffle mode
                  ref.read(songNotifierProvider.notifier).toggleShuffleMode();
                },
                iconSize: 24,
              ),
              // Previous button
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: onPrevious,
                iconSize: 40,
                color: Colors.white,
              ),
              // Play/Pause button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: onPlayPause,
                  iconSize: 40,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              // Next button
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: onNext,
                iconSize: 40,
                color: Colors.white,
              ),
              // Repeat button
              IconButton(
                icon: Icon(
                  _getRepeatIcon(playerState.repeatMode),
                  color:
                      playerState.repeatMode != RepeatMode.off
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey[400],
                ),
                onPressed: () {
                  // Cycle through repeat modes
                  ref.read(songNotifierProvider.notifier).cycleRepeatMode();
                },
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to format the current position based on the song duration and slider value
  String _formatPosition(String durationStr, double sliderValue) {
    // Parse the duration string (e.g., "3:45")
    final parts = durationStr.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      final totalSeconds = (minutes * 60) + seconds;

      // Calculate current position in seconds
      final currentSeconds = (totalSeconds * sliderValue).round();
      final currentMinutes = currentSeconds ~/ 60;
      final remainingSeconds = currentSeconds % 60;

      // Format as "m:ss"
      return '$currentMinutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    return "0:00";
  }

  // Helper method to get the appropriate repeat icon based on the repeat mode
  IconData _getRepeatIcon(RepeatMode repeatMode) {
    switch (repeatMode) {
      case RepeatMode.off:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat;
      case RepeatMode.all:
        return Icons.repeat_one;
    }
  }

}
