import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music/services/song_service.dart';

// Provider for managing mini player visibility
final miniPlayerVisibilityProvider = StateProvider<bool>((ref) => true);

class PersistentMiniPlayer extends ConsumerWidget {
  final Widget child;

  const PersistentMiniPlayer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(songNotifierProvider);
    final isVisible = ref.watch(miniPlayerVisibilityProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: (playerState.currentSong != null && isVisible) ? 60 : 0,
        child:
            playerState.currentSong != null
                ? _MiniPlayerContent()
                : const SizedBox.shrink(),
      ),
    );
  }
}

class _MiniPlayerContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(songNotifierProvider);

    if (playerState.currentSong == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  try {
                    GoRouter.of(context).push('/now-playing');
                  } catch (e) {
                    debugPrint('Navigation error: $e');
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(playerState.currentSong!.albumArt),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    try {
                      GoRouter.of(context).push('/now-playing');
                    } catch (e) {
                      debugPrint('Navigation error: $e');
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        playerState.currentSong!.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        playerState.currentSong!.artist.name,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color:
                      playerState.hasPrevious ? Colors.white : Colors.grey[700],
                ),
                onPressed:
                    playerState.hasPrevious
                        ? () =>
                            ref
                                .read(songNotifierProvider.notifier)
                                .skipToPrevious()
                        : null,
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    playerState.playbackState == PlaybackState.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    ref.read(songNotifierProvider.notifier).playPause();
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: playerState.hasNext ? Colors.white : Colors.grey[700],
                ),
                onPressed:
                    playerState.hasNext
                        ? () =>
                            ref.read(songNotifierProvider.notifier).skipToNext()
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
