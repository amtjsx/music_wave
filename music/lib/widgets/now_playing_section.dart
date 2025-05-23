import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/song.dart';
import '../utils/format_utils.dart';

class NowPlayingSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              context.push('/artists/${song.artistDetails.id}');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Artist avatar
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(song.artistDetails.imageUrl),
                    backgroundColor: Colors.grey[800],
                  ),
                  const SizedBox(width: 8),

                  // Artist name
                  Text(
                    song.artist,
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
              ).colorScheme.secondary.withOpacity(0.3),
            ),
            child: Slider(
              value: currentValue,
              min: 0.0,
              max: 100.0,
              onChanged: onSliderChanged,
            ),
          ),

          // Time Indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormatUtils.formatDuration(currentValue),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
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
              IconButton(
                icon: const Icon(Icons.shuffle),
                onPressed: () {},
                iconSize: 24,
                color: Colors.grey[400],
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: onPrevious,
                iconSize: 40,
              ),
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
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: onNext,
                iconSize: 40,
              ),
              IconButton(
                icon: const Icon(Icons.repeat),
                onPressed: () {},
                iconSize: 24,
                color: Colors.grey[400],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
