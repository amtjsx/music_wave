import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music/services/song_service.dart';

class HomeWrapper extends ConsumerWidget {
  const HomeWrapper({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the player state to check if we need to show the mini player
    final playerState = ref.watch(songNotifierProvider);
    final showMiniPlayer = playerState.currentSong != null;
    
    // Calculate the mini player height (0 if not showing)
    final miniPlayerHeight = showMiniPlayer ? 60.0 : 0.0;

    return Scaffold(
      // The body needs to be adjusted to account for the mini player
      body: Column(
        children: [
          // Main content area (navigation shell)
          Expanded(child: navigationShell),
          
          // Mini player (conditionally shown)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: miniPlayerHeight,
            child: showMiniPlayer ? const MiniPlayerForNavShell() : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Colors.black,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Shorts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) {
          navigationShell.goBranch(index);
        },
      ),
    );
  }
}

// Special mini player implementation for navigation shell
class MiniPlayerForNavShell extends ConsumerWidget {
  const MiniPlayerForNavShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(songNotifierProvider);
    
    if (playerState.currentSong == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Use GoRouter.of(context) for more reliable navigation
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
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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
              color: playerState.hasPrevious ? Colors.white : Colors.grey[700],
            ),
            onPressed: playerState.hasPrevious
                ? () => ref.read(songNotifierProvider.notifier).skipToPrevious()
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
            onPressed: playerState.hasNext
                ? () => ref.read(songNotifierProvider.notifier).skipToNext()
                : null,
          ),
        ],
      ),
    );
  }
}
