import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music/services/song_service.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the player state directly from the StateNotifierProvider
    final playerState = ref.watch(songNotifierProvider);

    if (playerState.currentSong == null) {
      // No song playing, return empty container
      return const SizedBox.shrink();
    }

    // Calculate progress percentage for the progress bar
    final duration = _parseDuration(playerState.currentSong!.duration);
    final progress =
        duration.inMilliseconds > 0
            ? playerState.position.inMilliseconds / duration.inMilliseconds
            : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar or loading bar
          SizedBox(
            height: 3,
            child:
                playerState.playbackState == PlaybackState.loading
                    ? const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    )
                    : LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[900],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
          ),

          // Main mini player content
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Album art with loading overlay
                GestureDetector(
                  onTap: () {
                    context.push('/now-playing');
                  },
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'album-art-${playerState.currentSong!.id}',
                        child: Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            image: DecorationImage(
                              image: NetworkImage(
                                playerState.currentSong!.albumArt,
                              ),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Song info with loading indicator
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.push('/now-playing');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                playerState.currentSong!.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          playerState.currentSong!.artist.name,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Playback controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        color:
                            playerState.hasPrevious &&
                                    playerState.playbackState !=
                                        PlaybackState.loading
                                ? Colors.white
                                : Colors.grey[700],
                        size: 28,
                      ),
                      onPressed:
                          playerState.hasPrevious &&
                                  playerState.playbackState !=
                                      PlaybackState.loading
                              ? () {
                                ref
                                    .read(songNotifierProvider.notifier)
                                    .skipToPrevious();
                              }
                              : null,
                    ),

                    // Play/pause button or loading indicator
                    _buildPlayPauseButton(context, playerState, ref),

                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color:
                            playerState.hasNext &&
                                    playerState.playbackState !=
                                        PlaybackState.loading
                                ? Colors.white
                                : Colors.grey[700],
                        size: 28,
                      ),
                      onPressed:
                          playerState.hasNext &&
                                  playerState.playbackState !=
                                      PlaybackState.loading
                              ? () {
                                ref
                                    .read(songNotifierProvider.notifier)
                                    .skipToNext();
                              }
                              : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the play/pause button or loading indicator
  Widget _buildPlayPauseButton(
    BuildContext context,
    PlayerState playerState,
    WidgetRef ref,
  ) {
    // Show loading indicator when in loading state
    if (playerState.playbackState == PlaybackState.loading) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1).withOpacity(0.7),
              const Color(0xFF8B5CF6).withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: _buildPulsingLoadingIndicator(),
      );
    }

    // Show play/pause button for other states
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            playerState.playbackState == PlaybackState.playing
                ? Icons.pause
                : Icons.play_arrow,
            key: ValueKey(playerState.playbackState),
            color: Colors.white,
            size: 28,
          ),
        ),
        onPressed: () {
          ref.read(songNotifierProvider.notifier).playPause();
        },
      ),
    );
  }

  // Custom pulsing loading indicator
  Widget _buildPulsingLoadingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  // Helper method to parse duration string (e.g. "3:45") to Duration
  Duration _parseDuration(String durationStr) {
    final parts = durationStr.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    } else if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts[2]) ?? 0;
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    return Duration.zero;
  }
}
