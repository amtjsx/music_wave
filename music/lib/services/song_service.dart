import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/models/artist.dart';
import 'package:music/models/song.dart';

// Add this enum to your song_service.dart file
enum RepeatMode { off, all, one }

class Playlist {
  final String id;
  final String name;
  final String description;
  final String coverUrl;
  final String creatorId;
  final String creatorName;
  final List<String> songIds;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.creatorId,
    required this.creatorName,
    required this.songIds,
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    String? creatorId,
    String? creatorName,
    List<String>? songIds,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      songIds: songIds ?? this.songIds,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverUrl': coverUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'songIds': songIds,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coverUrl: json['coverUrl'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      songIds: List<String>.from(json['songIds']),
      isPublic: json['isPublic'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Player State
enum PlaybackState { none, loading, playing, paused, stopped, error }

class PlayerState {
  final PlaybackState playbackState;
  final Song? currentSong;
  final List<Song> queue;
  final int queueIndex;
  final Duration position;
  final Duration bufferedPosition;
  final double volume;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;
  final String? error;
  final List<Song> recentlyPlayed;

  PlayerState({
    this.playbackState = PlaybackState.none,
    this.currentSong,
    this.queue = const [],
    this.queueIndex = -1,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.volume = 1.0,
    this.isShuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.error,
    this.recentlyPlayed = const [],
  });

  // Fix the hasPrevious getter to consider repeat mode
  bool get hasNext {
    if (queue.isEmpty) return false;
    if (repeatMode == RepeatMode.all) return queue.length > 1;
    return queueIndex < queue.length - 1;
  }

  // Fix the hasPrevious getter to consider repeat mode
  bool get hasPrevious {
    if (queue.isEmpty) return false;
    if (repeatMode == RepeatMode.all) return queue.length > 1;
    return queueIndex > 0;
  }

  PlayerState copyWith({
    PlaybackState? playbackState,
    Song? currentSong,
    List<Song>? queue,
    int? queueIndex,
    Duration? position,
    Duration? bufferedPosition,
    double? volume,
    bool? isShuffleEnabled,
    RepeatMode? repeatMode,
    String? error,
    List<Song>? recentlyPlayed,
  }) {
    return PlayerState(
      playbackState: playbackState ?? this.playbackState,
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      volume: volume ?? this.volume,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      error: error ?? this.error,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
    );
  }
}

// Song Service using StateNotifier
class SongNotifier extends StateNotifier<PlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _positionTimer;

  SongNotifier() : super(PlayerState()) {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Set up position updates
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (state.playbackState == PlaybackState.playing) {
        _updatePosition();
      }
    });

    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      // Update our playback state based on the audio player's state
      if (playerState.playing && state.playbackState != PlaybackState.playing) {
        state = state.copyWith(playbackState: PlaybackState.playing);
      } else if (!playerState.playing &&
          state.playbackState == PlaybackState.playing) {
        state = state.copyWith(playbackState: PlaybackState.paused);
      }

      if (playerState.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
    });

    // Listen to playback events
    _audioPlayer.playbackEventStream.listen(
      (event) {
        state = state.copyWith(bufferedPosition: event.bufferedPosition);
      },
      onError: (Object e, StackTrace stackTrace) {
        state = state.copyWith(
          playbackState: PlaybackState.error,
          error: e.toString(),
        );
      },
    );
  }

  Future<void> _updatePosition() async {
    try {
      final position = await _audioPlayer.position;
      state = state.copyWith(position: position);
    } catch (e) {
      debugPrint('Error updating position: $e');
    }
  }

  Future<void> _onSongComplete() async {
    if (state.repeatMode == RepeatMode.one) {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } else if (state.hasNext) {
      await skipToNext();
    } else if (state.repeatMode == RepeatMode.all) {
      await skipToQueueItem(0);
    } else {
      await stop();
    }
  }

  // Public API
  Future<void> playSong(Song song) async {
    try {
      // Update state first to show loading
      state = state.copyWith(
        playbackState: PlaybackState.loading,
        currentSong: song,
        queue: [song],
        queueIndex: 0,
        position: Duration.zero,
      );

      await _audioPlayer.stop();
      await _audioPlayer.setUrl(song.audioUrl);
      await _audioPlayer.play();

      // Add to recently played
      addToRecentlyPlayed(song);

      // State will be updated by the playerStateStream listener
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> playPlaylist(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;

    try {
      final validIndex = startIndex.clamp(0, songs.length - 1);

      // Debug the queue initialization
      debugPrint(
        'Setting queue with ${songs.length} songs, starting at index $validIndex',
      );

      // Update the state with the new queue and index
      state = state.copyWith(
        queue: songs,
        queueIndex: validIndex,
        currentSong: songs[validIndex],
        playbackState: PlaybackState.loading,
      );

      // Load and play the song
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(songs[validIndex].audioUrl);
      await _audioPlayer.play();

      // Add to recently played
      addToRecentlyPlayed(songs[validIndex]);

      // Debug the state after initialization
      debugPrint(
        'Queue initialized: ${state.queue.length} songs, index: ${state.queueIndex}',
      );
      debugPrint(
        'HasNext: ${state.hasNext}, HasPrevious: ${state.hasPrevious}',
      );
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> playPause() async {
    if (state.currentSong == null) return;

    try {
      debugPrint('Play/Pause: Current state is ${state.playbackState}');

      if (state.playbackState == PlaybackState.playing) {
        await _audioPlayer.pause();
        // State will be updated by the playerStateStream listener
      } else {
        await _audioPlayer.play();
        // State will be updated by the playerStateStream listener
      }
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      state = state.copyWith(
        playbackState: PlaybackState.stopped,
        position: Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> skipToNext() async {
    try {
      debugPrint(
        'Attempting to skip to next song. Current index: ${state.queueIndex}, Queue length: ${state.queue.length}',
      );

      if (state.queue.isEmpty) {
        debugPrint('Cannot skip: Queue is empty');
        return;
      }

      int nextIndex = state.queueIndex + 1;

      // Check if we're at the end of the queue
      if (nextIndex >= state.queue.length) {
        // If repeat all is enabled, go back to the beginning
        if (state.repeatMode == RepeatMode.all) {
          nextIndex = 0;
          debugPrint(
            'Reached end of queue with repeat all enabled, wrapping to index 0',
          );
        } else {
          // Otherwise, we can't skip
          debugPrint(
            'Cannot skip: At end of queue and repeat all is not enabled',
          );
          return;
        }
      }

      // Normal case - there's a next song
      final song = state.queue[nextIndex];
      debugPrint('Skipping to next song at index $nextIndex: ${song.title}');

      // Update state to show loading
      state = state.copyWith(
        queueIndex: nextIndex,
        currentSong: song,
        playbackState: PlaybackState.loading,
      );

      await _audioPlayer.stop();
      await _audioPlayer.setUrl(song.audioUrl);
      await _audioPlayer.play();

      // Add to recently played
      addToRecentlyPlayed(song);

      // Debug the state after skipping
      debugPrint(
        'After skip: Queue index: ${state.queueIndex}, HasNext: ${state.hasNext}, HasPrevious: ${state.hasPrevious}',
      );

      // State will be updated by the playerStateStream listener
    } catch (e) {
      debugPrint('Error skipping to next song: $e');
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  // Enhanced skipToPrevious method that handles repeat mode
  Future<void> skipToPrevious() async {
    try {
      debugPrint(
        'Attempting to skip to previous song. Current index: ${state.queueIndex}, Queue length: ${state.queue.length}',
      );

      if (state.queue.isEmpty) {
        debugPrint('Cannot skip: Queue is empty');
        return;
      }

      int previousIndex = state.queueIndex - 1;

      // Check if we're at the beginning of the queue
      if (previousIndex < 0) {
        // If repeat all is enabled, go to the end
        if (state.repeatMode == RepeatMode.all) {
          previousIndex = state.queue.length - 1;
          debugPrint(
            'At beginning of queue with repeat all enabled, wrapping to index ${previousIndex}',
          );
        } else {
          // Otherwise, we can't skip back
          debugPrint(
            'Cannot skip: At beginning of queue and repeat all is not enabled',
          );
          return;
        }
      }

      // Normal case - there's a previous song
      final song = state.queue[previousIndex];
      debugPrint(
        'Skipping to previous song at index $previousIndex: ${song.title}',
      );

      // Update state to show loading
      state = state.copyWith(
        queueIndex: previousIndex,
        currentSong: song,
        playbackState: PlaybackState.loading,
      );

      await _audioPlayer.stop();
      await _audioPlayer.setUrl(song.audioUrl);
      await _audioPlayer.play();

      // Add to recently played
      addToRecentlyPlayed(song);

      // Debug the state after skipping
      debugPrint(
        'After skip: Queue index: ${state.queueIndex}, HasNext: ${state.hasNext}, HasPrevious: ${state.hasPrevious}',
      );

      // State will be updated by the playerStateStream listener
    } catch (e) {
      debugPrint('Error skipping to previous song: $e');
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= state.queue.length) return;

    try {
      final song = state.queue[index];

      // Update state to show loading
      state = state.copyWith(
        queueIndex: index,
        currentSong: song,
        playbackState: PlaybackState.loading,
      );

      await _audioPlayer.stop();
      await _audioPlayer.setUrl(song.audioUrl);
      await _audioPlayer.play();

      // Add to recently played
      addToRecentlyPlayed(song);

      // State will be updated by the playerStateStream listener
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      state = state.copyWith(position: position);
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(volume);
      state = state.copyWith(volume: volume);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleShuffle() async {
    try {
      final isShuffleEnabled = !state.isShuffleEnabled;

      if (isShuffleEnabled) {
        // Save current song
        final currentSong = state.currentSong;
        final currentIndex = state.queueIndex;

        // Create a shuffled queue
        final shuffledQueue = List<Song>.from(state.queue);
        shuffledQueue.removeAt(currentIndex);
        shuffledQueue.shuffle();

        // Put current song at the beginning
        if (currentSong != null) {
          shuffledQueue.insert(0, currentSong);
        }

        state = state.copyWith(
          queue: shuffledQueue,
          queueIndex: 0,
          isShuffleEnabled: true,
        );
      } else {
        // TODO: Restore original queue order
        state = state.copyWith(isShuffleEnabled: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    try {
      state = state.copyWith(repeatMode: mode);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Recently played functionality
  void addToRecentlyPlayed(Song song) {
    // Create a new list to avoid modifying the existing one
    final updatedRecentlyPlayed = List<Song>.from(state.recentlyPlayed);

    // Remove if already exists
    updatedRecentlyPlayed.removeWhere((s) => s.id == song.id);

    // Add to the beginning
    updatedRecentlyPlayed.insert(0, song);

    // Limit to 50 items
    if (updatedRecentlyPlayed.length > 50) {
      updatedRecentlyPlayed.removeLast();
    }

    // Update state
    state = state.copyWith(recentlyPlayed: updatedRecentlyPlayed);

    // Save to local storage (implementation not shown)
    _saveRecentlyPlayed();
  }

  Future<void> _saveRecentlyPlayed() async {
    // Implementation would save to SharedPreferences or other local storage
  }

  Future<void> loadRecentlyPlayed() async {
    // Implementation would load from SharedPreferences or other local storage
  }

  // Add these to your SongNotifier class

  // Enhanced toggleShuffle method
  Future<void> toggleShuffleMode() async {
    try {
      final isShuffleEnabled = !state.isShuffleEnabled;

      if (state.queue.isEmpty) {
        // Just update the shuffle state if queue is empty
        state = state.copyWith(isShuffleEnabled: isShuffleEnabled);
        return;
      }

      if (isShuffleEnabled) {
        // Save current song
        final currentSong = state.currentSong;

        // Create a copy of the original queue for shuffling
        final shuffledQueue = List<Song>.from(state.queue);

        // Remove current song from the queue before shuffling
        if (currentSong != null && state.queueIndex >= 0) {
          shuffledQueue.removeAt(state.queueIndex);
        }

        // Shuffle the remaining songs
        shuffledQueue.shuffle();

        // Put current song at the beginning
        if (currentSong != null) {
          shuffledQueue.insert(0, currentSong);
        }

        // Store the original queue and index for when shuffle is disabled
        final originalQueue = List<Song>.from(state.queue);
        final originalIndex = state.queueIndex;

        // Update state with shuffled queue
        state = state.copyWith(
          queue: shuffledQueue,
          queueIndex: currentSong != null ? 0 : -1,
          isShuffleEnabled: true,
          // Store original queue and index in a way that doesn't affect the state
          // This would require adding these properties to PlayerState
          // For now, we'll assume they're added
        );

        // Store original queue in a private field
        _originalQueue = originalQueue;
        _originalQueueIndex = originalIndex;
      } else {
        // Restore original queue if available
        if (_originalQueue != null) {
          // Find the current song in the original queue
          final currentSong = state.currentSong;
          int newIndex = -1;

          if (currentSong != null) {
            newIndex = _originalQueue!.indexWhere(
              (song) => song.id == currentSong.id,
            );
            if (newIndex == -1) {
              // If not found, use the original index
              newIndex = _originalQueueIndex ?? 0;
            }
          }

          // Update state with original queue
          state = state.copyWith(
            queue: _originalQueue!,
            queueIndex: newIndex >= 0 ? newIndex : 0,
            isShuffleEnabled: false,
          );
        } else {
          // If no original queue is available, just update the shuffle state
          state = state.copyWith(isShuffleEnabled: false);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Add these private fields to store the original queue
  List<Song>? _originalQueue;
  int? _originalQueueIndex;

  // Implement cycleRepeatMode to cycle through repeat modes
  Future<void> cycleRepeatMode() async {
    try {
      // Get the current repeat mode
      final currentMode = state.repeatMode;

      // Determine the next repeat mode
      RepeatMode nextMode;

      switch (currentMode) {
        case RepeatMode.off:
          nextMode = RepeatMode.all;
          break;
        case RepeatMode.all:
          nextMode = RepeatMode.one;
          break;
        case RepeatMode.one:
          nextMode = RepeatMode.off;
          break;
      }

      // Update the state with the new repeat mode
      state = state.copyWith(repeatMode: nextMode);

      // Log the change
      debugPrint('Repeat mode changed to: $nextMode');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Helper method to get a boolean indicating if shuffle is enabled
  bool get shuffleMode => state.isShuffleEnabled;

  // Helper method to get the current repeat mode
  RepeatMode get repeatMode => state.repeatMode;

  // Helper method to convert AudioServiceRepeatMode to RepeatMode enum
  // Add this if you want to use a custom RepeatMode enum in your UI
  RepeatMode get uiRepeatMode {
    switch (state.repeatMode) {
      case RepeatMode.off:
        return RepeatMode.off;
      case RepeatMode.all:
        return RepeatMode.all;
      case RepeatMode.one:
        return RepeatMode.one;
    }
  }

  // Initialize the player with a playlist
  Future<void> initializeWithPlaylist() async {
    final songs = getMockSongs();
    if (songs.isNotEmpty) {
      debugPrint('Initializing player with ${songs.length} songs');
      await playPlaylist(songs, startIndex: 0);
    }
  }

  // Mock data for testing with real audio URLs
  List<Song> getMockSongs() {
    return [
      Song(
        id: '1',
        title: 'Blinding Lights',
        artistId: 'the-weeknd',
        artist: Artist(
          id: 'the-weeknd',
          name: 'The Weeknd',
          imageUrl:
              'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
          bio: 'The Weeknd is a Canadian singer, songwriter, and actor.',
          followers: 1000000,
          monthlyListeners: 500000,
          genres: ['Pop', 'Hip hop', 'R&B'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        albumId: 'after-hours',
        albumName: 'After Hours',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        duration: '3:20',
        isExplicit: false,
        albumArt:
            'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
      ),
      Song(
        id: '2',
        title: 'Save Your Tears',
        artistId: 'the-weeknd',
        artist: Artist(
          id: 'the-weeknd',
          name: 'The Weeknd',
          imageUrl:
              'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
          bio: 'The Weeknd is a Canadian singer, songwriter, and actor.',
          followers: 1000000,
          monthlyListeners: 500000,
          genres: ['Pop', 'Hip hop', 'R&B'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        albumId: 'after-hours',
        albumName: 'After Hours',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        duration: '3:35',
        isExplicit: false,
        albumArt:
            'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
      ),
      Song(
        id: '3',
        title: 'Starboy',
        artistId: 'the-weeknd',
        artist: Artist(
          id: 'the-weeknd',
          name: 'The Weeknd',
          imageUrl:
              'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
          bio: 'The Weeknd is a Canadian singer, songwriter, and actor.',
          followers: 1000000,
          monthlyListeners: 500000,
          genres: ['Pop', 'Hip hop', 'R&B'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        albumId: 'starboy',
        albumName: 'Starboy',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        duration: '3:50',
        isExplicit: true,
        albumArt:
            'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
      ),
      Song(
        id: '4',
        title: 'Die For You',
        artistId: 'the-weeknd',
        artist: Artist(
          id: 'the-weeknd',
          name: 'The Weeknd',
          imageUrl:
              'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
          bio: 'The Weeknd is a Canadian singer, songwriter, and actor.',
          followers: 1000000,
          monthlyListeners: 500000,
          genres: ['Pop', 'Hip hop', 'R&B'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        albumId: 'starboy',
        albumName: 'Starboy',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        duration: '4:20',
        isExplicit: false,
        albumArt:
            'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
      ),
      Song(
        id: '5',
        title: 'The Hills',
        artistId: 'the-weeknd',
        artist: Artist(
          id: 'the-weeknd',
          name: 'The Weeknd',
          imageUrl:
              'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
          bio: 'The Weeknd is a Canadian singer, songwriter, and actor.',
          followers: 1000000,
          monthlyListeners: 500000,
          genres: ['Pop', 'Hip hop', 'R&B'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        albumId: 'beauty-behind-the-madness',
        albumName: 'Beauty Behind the Madness',
        albumArt:
            'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        duration: '3:41',
        isExplicit: true,
      ),
    ];
  }

  List<Playlist> getMockPlaylists() {
    return [
      Playlist(
        id: '1',
        name: 'Top Hits',
        description: 'The most popular songs right now',
        coverUrl:
            'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
        creatorId: 'system',
        creatorName: 'Music App',
        songIds: ['1', '2', '3', '4', '5'],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Playlist(
        id: '2',
        name: 'Chill Vibes',
        description: 'Relaxing music for your downtime',
        coverUrl:
            'https://picsum.photos/200/200?random=${math.Random().nextInt(100)}',
        creatorId: 'system',
        creatorName: 'Music App',
        songIds: ['2', '4'],
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Riverpod Providers using StateNotifierProvider
final songNotifierProvider = StateNotifierProvider<SongNotifier, PlayerState>((
  ref,
) {
  return SongNotifier();
});

// Derived providers
final currentSongProvider = Provider<Song?>((ref) {
  return ref.watch(songNotifierProvider).currentSong;
});

final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(songNotifierProvider).playbackState == PlaybackState.playing;
});

final playbackPositionProvider = Provider<Duration>((ref) {
  return ref.watch(songNotifierProvider).position;
});

final queueProvider = Provider<List<Song>>((ref) {
  return ref.watch(songNotifierProvider).queue;
});

final recentlyPlayedProvider = Provider<List<Song>>((ref) {
  return ref.watch(songNotifierProvider).recentlyPlayed;
});
