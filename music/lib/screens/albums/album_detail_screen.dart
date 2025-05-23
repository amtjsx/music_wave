import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music/models/artist.dart';
import 'package:music/models/song.dart';
import 'package:music/screens/download/download_item.dart';
import 'package:music/screens/download/download_manager.dart';
import 'package:music/screens/download/download_queue_screen.dart';
import 'package:music/screens/download/download_queue_state.dart';
import 'package:music/screens/playlists/add_to_playlist_sheet.dart';
import 'package:music/services/share_service.dart';
import 'package:music/widgets/audio_visualizer.dart';
import 'package:music/widgets/share_sheet.dart';

class AlbumDetailScreen extends ConsumerStatefulWidget {
  final String albumId;

  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  bool isPlaying = false;
  int? currentPlayingIndex;
  bool isShuffleMode = false;
  List<int> shuffledIndices = [];
  final Random _random = Random();

  // Track download states
  final Map<String, DownloadStatus> _downloadStatus = {};
  final Map<String, double> _downloadProgress = {};

  // Sample album data with the provided structure
  late final Map<String, dynamic> albumData = {
    'id': 'album_001',
    'title': 'Midnight Memories',
    'artist': 'The Echoes',
    'releaseDate': '2023',
    'genre': 'Alternative Rock',
    'coverArt': 'https://via.placeholder.com/500?text=Album+Cover',
    'description':
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    'tracks': [
      Song(
        artistDetails: Artist(
          name: 'The Echoes',
          id: 'artist_001',
          imageUrl: 'https://via.placeholder.com/500?text=Artist+Cover',
          bio:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
          followers: 1000,
          monthlyListeners: 500,
          genres: ['Alternative Rock'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        id: 'song_001',
        title: 'Midnight Hour',
        artist: 'The Echoes',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '3:45',
      ),
      Song(
        artistDetails: Artist(
          name: 'The Echoes',
          id: 'artist_001',
          imageUrl: 'https://via.placeholder.com/500?text=Artist+Cover',
          bio:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
          followers: 1000,
          monthlyListeners: 500,
          genres: ['Alternative Rock'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        id: 'song_002',
        title: 'Starlight Dreams',
        artist: 'The Echoes',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '4:12',
      ),
      Song(
        artistDetails: Artist(
          name: 'The Echoes',
          id: 'artist_001',
          imageUrl: 'https://via.placeholder.com/500?text=Artist+Cover',
          bio:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
          followers: 1000,
          monthlyListeners: 500,
          genres: ['Alternative Rock'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        id: 'song_003',
        title: 'Echoes of Yesterday',
        artist: 'The Echoes',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '3:58',
      ),
      Song(
        artistDetails: Artist(
          name: 'The Echoes',
          id: 'artist_001',
          imageUrl: 'https://via.placeholder.com/500?text=Artist+Cover',
          bio:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
          followers: 1000,
          monthlyListeners: 500,
          genres: ['Alternative Rock'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        id: 'song_004',
        title: 'Neon Lights',
        artist: 'The Echoes',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '5:02',
      ),
      Song(
        artistDetails: Artist(
          name: 'The Echoes',
          id: 'artist_001',
          imageUrl: 'https://via.placeholder.com/500?text=Artist+Cover',
          bio:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
          followers: 1000,
          monthlyListeners: 500,
          genres: ['Alternative Rock'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        id: 'song_005',
        title: 'Whispers in the Dark',
        artist: 'The Echoes',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '4:30',
      ),
      Song(
        artistDetails: Artist(
          name: 'The Echoes',
          id: 'artist_001',
          imageUrl: 'https://via.placeholder.com/500?text=Artist+Cover',
          bio:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
          followers: 1000,
          monthlyListeners: 500,
          genres: ['Alternative Rock'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        id: 'song_006',
        title: 'Lost in Time',
        artist: 'The Echoes',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '3:22',
      ),
      Song(
        artistDetails: Artist(
          name: 'The Echoes',
          id: 'artist_001',
          imageUrl: 'https://via.placeholder.com/500?text=Artist+Cover',
          bio:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
          followers: 1000,
          monthlyListeners: 500,
          genres: ['Alternative Rock'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        id: 'song_007',
        title: 'Memories Fade',
        artist: 'The Echoes',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '4:15',
      ),
      Song(
        artistDetails: Artist(
          name: 'The Echoes',
          id: 'artist_001',
          imageUrl: 'https://via.placeholder.com/500?text=Artist+Cover',
          bio:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
          followers: 1000,
          monthlyListeners: 500,
          genres: ['Alternative Rock'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        id: 'song_008',
        title: 'Eternal Flame',
        artist: 'The Echoes',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '3:48',
      ),
    ],
  };

  // Download manager instance
  late final DownloadManager _downloadManager;

  @override
  void initState() {
    super.initState();
    // Initialize shuffled indices
    _generateShuffledIndices();

    // Initialize download manager
    _downloadManager = DownloadManager();

    // Check for already downloaded tracks
    _checkDownloadedTracks();
  }

  @override
  void dispose() {
    // Cancel any ongoing downloads when leaving the screen
    _downloadManager.cancelAll();
    super.dispose();
  }

  void _addToPlaylist(Song track) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddToPlaylistSheet(song: track),
    );
  }

  // Replace the _downloadTrack method with:
  void _downloadTrack(Song track) async {
    // Check if we have storage permission
    final hasPermission = await _downloadManager.requestStoragePermission();
    if (!hasPermission) {
      _showPermissionDeniedDialog();
      return;
    }

    // Add to download queue
    final queueNotifier = ref.read(downloadQueueProvider.notifier);
    await queueNotifier.addToQueue(track, albumData['title']);

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${track.title} added to download queue'),
        action: SnackBarAction(
          label: 'View Queue',
          onPressed: () {
            context.push('/download-queue');
          },
        ),
      ),
    );
  }

  // Replace the _downloadAllTracks method with:
  void _downloadAllTracks() async {
    // Check if we have storage permission
    final hasPermission = await _downloadManager.requestStoragePermission();
    if (!hasPermission) {
      _showPermissionDeniedDialog();
      return;
    }

    final tracks = List<Song>.from(albumData['tracks']);

    // Show confirmation dialog
    final shouldDownload = await _showDownloadAllConfirmationDialog(
      tracks.length,
    );
    if (shouldDownload != true) return;

    // Add all tracks to download queue
    final queueNotifier = ref.read(downloadQueueProvider.notifier);
    for (final track in tracks) {
      await queueNotifier.addToQueue(track, albumData['title']);
    }

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tracks.length} tracks added to download queue'),
        action: SnackBarAction(
          label: 'View Queue',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DownloadQueueScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  // Replace the _buildDownloadStatusIcon method with:
  Widget _buildDownloadStatusIcon(Song track, Color accentColor) {
    // Get download status from queue state
    final queueState = ref.watch(downloadQueueProvider);
    final allDownloads = queueState.allDownloadsList;
    final downloadItem = allDownloads.firstWhere(
      (item) => item.id == track.id,
      orElse:
          () => DownloadItem(
            id: track.id,
            song: track,
            albumName: 'AlbumName1',
            status: DownloadStatus.queued,
            progress: 0.0,
            addedAt: DateTime.now(),
          ),
    );

    final queueNotifier = ref.read(downloadQueueProvider.notifier);

    switch (downloadItem.status) {
      case DownloadStatus.downloading:
        return SizedBox(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: downloadItem.progress,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 12),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => queueNotifier.cancelDownload(track.id),
              ),
            ],
          ),
        );

      case DownloadStatus.paused:
        return IconButton(
          icon: const Icon(Icons.pause, color: Colors.orange),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          onPressed: () => queueNotifier.resumeDownload(track.id),
        );

      case DownloadStatus.completed:
        return IconButton(
          icon: Icon(Icons.download_done, color: accentColor),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          onPressed: () => _showDownloadOptions(track),
        );

      case DownloadStatus.failed:
        return IconButton(
          icon: const Icon(Icons.error_outline, color: Colors.red),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          onPressed: () => queueNotifier.resumeDownload(track.id),
        );

      case DownloadStatus.queued:
        return IconButton(
          icon: const Icon(Icons.queue, color: Colors.grey),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          onPressed: () => queueNotifier.cancelDownload(track.id),
        );

      default:
        return IconButton(
          icon: const Icon(Icons.download_outlined),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          onPressed: () => _downloadTrack(track),
        );
    }
  }

  // Check which tracks are already downloaded
  Future<void> _checkDownloadedTracks() async {
    final tracks = List<Song>.from(albumData['tracks']);

    for (final track in tracks) {
      final isDownloaded = await _downloadManager.isDownloaded(track.id);
      if (isDownloaded) {
        setState(() {
          _downloadStatus[track.id] = DownloadStatus.completed;
          _downloadProgress[track.id] = 1.0;
        });
      }
    }
  }

  // Generate shuffled indices for shuffle play
  void _generateShuffledIndices() {
    final tracks = List<Song>.from(albumData['tracks']);
    shuffledIndices = List.generate(tracks.length, (index) => index);
    shuffledIndices.shuffle(_random);
  }

  // Get the artist details from the first track
  Artist _getArtistDetails() {
    final tracks = List<Song>.from(albumData['tracks']);
    if (tracks.isNotEmpty) {
      return tracks[0].artistDetails;
    }

    // Fallback if no artist details are available
    return Artist(
      name: albumData['artist'],
      id: 'unknown',
      imageUrl: 'https://via.placeholder.com/500?text=Artist',
      bio: 'No artist information available.',
      followers: 0,
      monthlyListeners: 0,
      genres: [],
      popularSongs: [],
      albums: [],
      similarArtists: [],
    );
  }

  // Navigate to artist profile
  void _navigateToArtistProfile(Artist artist) {
    // In a real app, you would navigate to the artist profile screen
    context.push('/artists/${artist.id}');
    print('Navigating to artist profile: ${artist.name} (${artist.id})');
  }

  // Start playing in shuffle mode
  void _startShufflePlay() {
    setState(() {
      isShuffleMode = true;
      isPlaying = true;
      currentPlayingIndex =
          shuffledIndices[0]; // Start with the first shuffled index
    });
  }

  // Start playing in normal mode
  void _startNormalPlay() {
    setState(() {
      isShuffleMode = false;
      isPlaying = true;
      currentPlayingIndex = 0; // Start with the first track
    });
  }

  // Cancel a download
  void _cancelDownload(String trackId) {
    _downloadManager.cancelDownload(trackId);
    setState(() {
      _downloadStatus.remove(trackId);
      _downloadProgress.remove(trackId);
    });
  }

  // Delete a downloaded track
  void _deleteDownloadedTrack(Song track) async {
    final confirmed = await _showDeleteConfirmationDialog(track.title);
    if (confirmed != true) return;

    final success = await _downloadManager.deleteTrack(track.id);
    if (success) {
      setState(() {
        _downloadStatus.remove(track.id);
        _downloadProgress.remove(track.id);
      });
      _showDeleteSuccessSnackBar(track.title);
    } else {
      _showDeleteErrorSnackBar(track.title);
    }
  }

  // Show download options for a track
  void _showDownloadOptions(Song track) {
    final status = _downloadStatus[track.id];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  track.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(track.artist),
              ),
              const Divider(height: 1),
              if (status == null || status == DownloadStatus.error)
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Download'),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadTrack(track);
                  },
                ),
              if (status == DownloadStatus.downloading)
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancel Download'),
                  onTap: () {
                    Navigator.pop(context);
                    _cancelDownload(track.id);
                  },
                ),
              if (status == DownloadStatus.completed)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete Download'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteDownloadedTrack(track);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement share functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to Playlist'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement add to playlist functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show permission denied dialog
  Future<void> _showPermissionDeniedDialog() async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Storage permission is required to download tracks. Please grant permission in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _downloadManager.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  // Show download all confirmation dialog
  Future<bool?> _showDownloadAllConfirmationDialog(int trackCount) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Download Album'),
            content: Text(
              'Do you want to download all $trackCount tracks from this album? This may use a significant amount of data and storage.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Download'),
              ),
            ],
          ),
    );
  }

  // Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmationDialog(String trackTitle) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Download'),
            content: Text(
              'Are you sure you want to delete "$trackTitle" from your downloads?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  // Show delete success snackbar
  void _showDeleteSuccessSnackBar(String trackTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$trackTitle has been deleted from downloads'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show delete error snackbar
  void _showDeleteErrorSnackBar(String trackTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to delete $trackTitle from downloads'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final tracks = List<Song>.from(albumData['tracks']);
    final artist = _getArtistDetails();

    return Scaffold(
      body: CustomScrollView(
        physics:
            const ClampingScrollPhysics(), // Remove bounce/overscroll animation
        slivers: [
          // App bar with album cover as background
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                albumData['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Album cover image
                  Image.network(
                    albumData['coverArt'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.album,
                          color: Colors.white,
                          size: 80,
                        ),
                      );
                    },
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),

          // Album info section
          SliverToBoxAdapter(child: _buildAlbumInfoSection(accentColor)),

          // Artist profile link section
          SliverToBoxAdapter(
            child: _buildArtistProfileLink(artist, accentColor),
          ),

          // Album actions
          SliverToBoxAdapter(child: _buildAlbumActions(accentColor)),

          // Track list header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tracks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${tracks.length} songs',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Play buttons (Play All and Shuffle Play)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Play All button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startNormalPlay,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Shuffle Play button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startShufflePlay,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Shuffle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Track list
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final track = tracks[index];
              final isCurrentlyPlaying = currentPlayingIndex == index;

              return _buildTrackItem(
                track,
                index,
                isCurrentlyPlaying,
                accentColor,
              );
            }, childCount: tracks.length),
          ),

          // Album description
          SliverToBoxAdapter(child: _buildAlbumDescription()),

          // Related albums section
          SliverToBoxAdapter(child: _buildRelatedAlbumsSection()),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildAlbumInfoSection(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  albumData['artist'],
                  style: TextStyle(
                    fontSize: 18,
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Released: ${albumData['releaseDate']}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.music_note, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Genre: ${albumData['genre']}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Duration: 32:52',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Album rating
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.white),
                        Icon(Icons.star, size: 12, color: Colors.white),
                        Icon(Icons.star, size: 12, color: Colors.white),
                        Icon(Icons.star, size: 12, color: Colors.white),
                        Icon(Icons.star_half, size: 12, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '1.2K ratings',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtistProfileLink(Artist artist, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToArtistProfile(artist),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Artist image
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  artist.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[700],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Artist info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${artist.followers} followers • ${artist.monthlyListeners} monthly listeners',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // View profile button
              InkWell(
                onTap: () => _navigateToArtistProfile(artist),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Profile',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumActions(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.favorite_border, 'Like'),
          _buildActionButton(Icons.playlist_add, 'Add'),
          _buildActionButton(Icons.share, 'Share', onPressed: _showShareSheet),
          _buildActionButton(
            Icons.download_outlined,
            'Download All',
            onPressed: _downloadAllTracks,
            color: _hasDownloadedAllTracks() ? accentColor : null,
          ),
        ],
      ),
    );
  }

  // Check if all tracks are downloaded
  bool _hasDownloadedAllTracks() {
    final tracks = List<Song>.from(albumData['tracks']);
    return tracks.every(
      (track) => _downloadStatus[track.id] == DownloadStatus.completed,
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onPressed,
    Color? color,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: onPressed ?? () {},
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color ?? Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildTrackItem(
    Song track,
    int index,
    bool isCurrentlyPlaying,
    Color accentColor,
  ) {
    final downloadStatus = _downloadStatus[track.id];
    final downloadProgress = _downloadProgress[track.id] ?? 0.0;

    return InkWell(
      onTap: () {
        setState(() {
          if (currentPlayingIndex == index) {
            // Toggle play/pause for current track
            isPlaying = !isPlaying;
          } else {
            // Start playing a new track
            currentPlayingIndex = index;
            isPlaying = true;
            isShuffleMode =
                false; // Reset shuffle mode when directly selecting a track
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentlyPlaying ? Colors.grey[900] : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Track number or play/pause icon
                Container(
                  width: 24,
                  alignment: Alignment.center,
                  child:
                      isCurrentlyPlaying
                          ? Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: accentColor,
                            size: 18,
                          )
                          : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
                const SizedBox(width: 16),

                // Track info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isCurrentlyPlaying ? accentColor : null,
                        ),
                      ),
                      if (track.artist != albumData['artist'])
                        Text(
                          track.artist,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ),

                // Track duration
                Text(
                  track.duration,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),

                // Download status icon or download button
                _buildDownloadStatusIcon(track, accentColor),

                // More options
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: () => _showDownloadOptions(track),
                ),
              ],
            ),

            // Show visualizer for currently playing track
            if (isCurrentlyPlaying && isPlaying)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 40),
                child: SizedBox(
                  height: 20,
                  child: AudioVisualizer(
                    isPlaying: true,
                    color: accentColor,
                    height: 20,
                    barCount: 30,
                  ),
                ),
              ),

            // Show download progress bar if downloading
            if (downloadStatus == DownloadStatus.downloading)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 40, right: 16),
                child: LinearProgressIndicator(
                  value: downloadProgress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Add this method to the _AlbumDetailScreenState class:
  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ShareSheet(
            contentType: ShareContentType.album,
            content: albumData,
          ),
    );
  }

  Widget _buildAlbumDescription() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this album',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            albumData['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[800]),
        ],
      ),
    );
  }

  Widget _buildRelatedAlbumsSection() {
    // Sample related albums
    final relatedAlbums = [
      {
        'title': 'Morning Light',
        'artist': 'The Echoes',
        'coverArt': 'https://via.placeholder.com/200?text=Album+1',
      },
      {
        'title': 'Eternal Sunset',
        'artist': 'The Echoes',
        'coverArt': 'https://via.placeholder.com/200?text=Album+2',
      },
      {
        'title': 'Daybreak',
        'artist': 'The Echoes',
        'coverArt': 'https://via.placeholder.com/200?text=Album+3',
      },
      {
        'title': 'Nightfall',
        'artist': 'The Echoes',
        'coverArt': 'https://via.placeholder.com/200?text=Album+4',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            'More by The Echoes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Horizontal list of related albums
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: relatedAlbums.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final album = relatedAlbums[index];

              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Album cover
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        album['coverArt']!,
                        height: 140,
                        width: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 140,
                            width: 140,
                            color: Colors.grey[800],
                            child: const Icon(Icons.album, color: Colors.white),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Album title
                    Text(
                      album['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Artist name
                    Text(
                      album['artist']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
