import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Music file model
class MusicFile {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime dateAdded;
  int duration;

  MusicFile({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.dateAdded,
    required this.duration,
  });
}

// Audio service class
class AudioService {
  AudioService() {
    _initAudioPlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  MusicFile? _currentSong;
  List<MusicFile> _playlist = [];
  int _currentIndex = -1;
  bool _isPlaying = false;

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  MusicFile? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  List<MusicFile> get playlist => _playlist;
  int get currentIndex => _currentIndex;

  void _initAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
    });

    // Listen to playback completion
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNext();
      }
    });
  }

  // Set the current playlist
  void setPlaylist(List<MusicFile> songs, {int initialIndex = 0}) {
    _playlist = List.from(songs);
    if (initialIndex >= 0 && initialIndex < _playlist.length) {
      _currentIndex = initialIndex;
      _playSongAtIndex(_currentIndex);
    }
  }

  // Play a specific song
  Future<void> playSong(MusicFile song) async {
    try {
      // Find song in playlist or add it
      int index = _playlist.indexWhere((s) => s.id == song.id);
      if (index == -1) {
        _playlist.add(song);
        index = _playlist.length - 1;
      }

      _currentIndex = index;
      await _playSongAtIndex(_currentIndex);
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  // Play song at specific index
  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    try {
      _currentSong = _playlist[index];
      await _audioPlayer.setFilePath(_currentSong!.filePath);

      // Get duration if not already set
      if (_currentSong!.duration == 0) {
        final duration = await _audioPlayer.duration;
        if (duration != null) {
          _currentSong!.duration = duration.inMilliseconds;
        }
      }

      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing song at index $index: $e');
    }
  }

  // Play next song
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _playlist.length) {
      nextIndex = 0; // Loop back to start
    }

    await _playSongAtIndex(nextIndex);
  }

  // Play previous song
  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;

    int prevIndex = _currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = _playlist.length - 1; // Loop to end
    }

    await _playSongAtIndex(prevIndex);
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_currentSong == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}

// Audio state class to hold the current state
class AudioState {
  final MusicFile? currentSong;
  final List<MusicFile> playlist;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  AudioState({
    this.currentSong,
    this.playlist = const [],
    this.currentIndex = -1,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioState copyWith({
    MusicFile? currentSong,
    List<MusicFile>? playlist,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return AudioState(
      currentSong: currentSong ?? this.currentSong,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

// Audio notifier to manage state changes
class AudioNotifier extends StateNotifier<AudioState> {
  final AudioService _audioService;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  AudioNotifier(this._audioService) : super(AudioState()) {
    _init();
  }

  void _init() {
    // Listen to player state changes
    _playerStateSubscription = _audioService.audioPlayer.playerStateStream
        .listen((playerState) {
          state = state.copyWith(isPlaying: playerState.playing);
        });

    // Listen to position changes
    _positionSubscription = _audioService.audioPlayer.positionStream.listen((
      position,
    ) {
      state = state.copyWith(position: position);
    });

    // Listen to duration changes
    _durationSubscription = _audioService.audioPlayer.durationStream.listen((
      duration,
    ) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  // Set the current playlist
  void setPlaylist(List<MusicFile> songs, {int initialIndex = 0}) {
    _audioService.setPlaylist(songs, initialIndex: initialIndex);
    state = state.copyWith(
      playlist: songs,
      currentIndex: initialIndex,
      currentSong:
          initialIndex >= 0 && initialIndex < songs.length
              ? songs[initialIndex]
              : null,
    );
  }

  // Play a specific song
  Future<void> playSong(MusicFile song) async {
    await _audioService.playSong(song);
    state = state.copyWith(
      currentSong: song,
      currentIndex: _audioService.currentIndex,
      playlist: _audioService.playlist,
    );
  }

  // Play next song
  Future<void> playNext() async {
    await _audioService.playNext();
    state = state.copyWith(
      currentSong: _audioService.currentSong,
      currentIndex: _audioService.currentIndex,
    );
  }

  // Play previous song
  Future<void> playPrevious() async {
    await _audioService.playPrevious();
    state = state.copyWith(
      currentSong: _audioService.currentSong,
      currentIndex: _audioService.currentIndex,
    );
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
    state = state.copyWith(isPlaying: _audioService.isPlaying);
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    await _audioService.seekTo(position);
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}

// Providers
final audioServiceProvider = Provider<AudioService>((ref) {
  final audioService = AudioService();
  ref.onDispose(() {
    audioService.dispose();
  });
  return audioService;
});

final audioStateProvider = StateNotifierProvider<AudioNotifier, AudioState>((
  ref,
) {
  final audioService = ref.watch(audioServiceProvider);
  return AudioNotifier(audioService);
});

// Recently played songs provider
final recentlyPlayedProvider = StateProvider<List<MusicFile>>((ref) => []);

// Add a song to recently played
void addToRecentlyPlayed(WidgetRef ref, MusicFile song) {
  final recentlyPlayed = ref.read(recentlyPlayedProvider);
  final updatedList = List<MusicFile>.from(recentlyPlayed);

  // Remove if already exists
  updatedList.removeWhere((s) => s.id == song.id);

  // Add to the beginning
  updatedList.insert(0, song);

  // Limit to 20 songs
  if (updatedList.length > 20) {
    updatedList.removeLast();
  }

  ref.read(recentlyPlayedProvider.notifier).state = updatedList;
}
