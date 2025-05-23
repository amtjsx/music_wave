// providers/music_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/artist.dart';
import 'package:music/models/song.dart';

class MusicNotifier extends StateNotifier<PlayerState> {
  MusicNotifier() : super(const PlayerState()) {
    _initializeSamplePlaylist();
    _startPositionTimer();
  }

  Timer? _positionTimer;

  void _initializeSamplePlaylist() {
    final List<Song> samplePlaylist = List.generate(
      20,
      (index) => Song(
        artistDetails: Artist(
          name: 'Artist ${(index % 5) + 1}',
          imageUrl:
              'https://via.placeholder.com/300?text=Artist+${(index % 5) + 1}',
          id: 'artist_${(index % 5) + 1}',
          bio: 'Bio for Artist ${(index % 5) + 1}',
          followers: 1000 + (index % 5) * 100,
          monthlyListeners: 500 + (index % 5) * 50,
          genres: ['Genre ${(index % 5) + 1}'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        id: 'song_$index',
        title: 'Song ${index + 1}',
        artist: 'Artist ${(index % 5) + 1}',
        albumArt:
            'https://via.placeholder.com/300?text=Album+${(index % 8) + 1}',
        duration:
            '3:${(index * 17) % 60 < 10 ? '0' : ''}${(index * 17) % 60}', // Format as "3:05" or "3:17"
      ),
    );
    state = state.copyWith(
      playlist: samplePlaylist,
      currentSong: samplePlaylist.first,
      currentIndex: 0,
    );
  }

  void _startPositionTimer() {
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPlaying && state.currentSong != null) {
        final newPosition = state.currentPosition + const Duration(seconds: 1);
        if (newPosition >= Duration(seconds: 40, milliseconds: 500)) {
          // Song finished, go to next
          next();
        } else {
          state = state.copyWith(currentPosition: newPosition);
        }
      }
    });
  }

  void play() {
    state = state.copyWith(playbackState: PlaybackState.playing);
  }

  void pause() {
    state = state.copyWith(playbackState: PlaybackState.paused);
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void stop() {
    state = state.copyWith(
      playbackState: PlaybackState.stopped,
      currentPosition: Duration.zero,
    );
  }

  void seek(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  void seekToProgress(double progress) {
    if (state.currentSong != null) {
      final position = Duration(
        milliseconds:
            (int.parse(state.currentSong!.duration) * progress).round(),
      );
      seek(position);
    }
  }

  void next() {
    if (state.playlist.isEmpty) return;

    int nextIndex;
    if (state.isShuffleEnabled) {
      nextIndex = (state.currentIndex + 1) % state.playlist.length;
    } else {
      nextIndex = (state.currentIndex + 1) % state.playlist.length;
    }

    _playAtIndex(nextIndex);
  }

  void previous() {
    if (state.playlist.isEmpty) return;

    int prevIndex;
    if (state.currentIndex == 0) {
      prevIndex = state.playlist.length - 1;
    } else {
      prevIndex = state.currentIndex - 1;
    }

    _playAtIndex(prevIndex);
  }

  void _playAtIndex(int index) {
    if (index >= 0 && index < state.playlist.length) {
      state = state.copyWith(
        currentSong: state.playlist[index],
        currentIndex: index,
        currentPosition: Duration.zero,
        playbackState: PlaybackState.playing,
      );
    }
  }

  void playSong(Song song) {
    final index = state.playlist.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _playAtIndex(index);
    }
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffleEnabled: !state.isShuffleEnabled);
  }

  void toggleRepeat() {
    state = state.copyWith(isRepeatEnabled: !state.isRepeatEnabled);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    super.dispose();
  }
}

final musicProvider = StateNotifierProvider<MusicNotifier, PlayerState>((ref) {
  return MusicNotifier();
});

// UI state providers
final isPlayerExpandedProvider = StateProvider<bool>((ref) => false);

// models/player_state.dart
enum PlaybackState { stopped, playing, paused, loading }

class PlayerState {
  final Song? currentSong;
  final PlaybackState playbackState;
  final Duration currentPosition;
  final bool isShuffleEnabled;
  final bool isRepeatEnabled;
  final double volume;
  final List<Song> playlist;
  final int currentIndex;

  const PlayerState({
    this.currentSong,
    this.playbackState = PlaybackState.stopped,
    this.currentPosition = Duration.zero,
    this.isShuffleEnabled = false,
    this.isRepeatEnabled = false,
    this.volume = 1.0,
    this.playlist = const [],
    this.currentIndex = 0,
  });

  PlayerState copyWith({
    Song? currentSong,
    PlaybackState? playbackState,
    Duration? currentPosition,
    bool? isShuffleEnabled,
    bool? isRepeatEnabled,
    double? volume,
    List<Song>? playlist,
    int? currentIndex,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      playbackState: playbackState ?? this.playbackState,
      currentPosition: currentPosition ?? this.currentPosition,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isRepeatEnabled: isRepeatEnabled ?? this.isRepeatEnabled,
      volume: volume ?? this.volume,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  bool get isPlaying => playbackState == PlaybackState.playing;
  bool get isPaused => playbackState == PlaybackState.paused;
  bool get isLoading => playbackState == PlaybackState.loading;

  double get progress {
    if (currentSong == null || currentSong!.duration == 0) {
      return 0.0;
    }
    return currentPosition.inMilliseconds / int.parse(currentSong!.duration);
  }
}
