import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/artist.dart';
import 'package:music/models/playlist.dart';
import 'package:music/models/song.dart';
import 'package:music/screens/playlists/add_to_playlist_sheet.dart';
import 'package:music/services/playlist_service.dart';
import 'package:music/services/share_service.dart';
import 'package:music/widgets/share_sheet.dart';

import 'create_playlist_screen.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  late Playlist _playlist;

  @override
  void initState() {
    super.initState();
    _playlist = Playlist(
      id: widget.playlistId,
      title: '',
      songs: List.generate(
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
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: false,
      creatorId: '',
      creatorName: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [_buildAppBar(), _buildSongList()]),
      floatingActionButton: FloatingActionButton(
        onPressed: _playAll,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(_playlist.title),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Playlist cover
            _playlist.coverUrl != null
                ? Image.network(
                  _playlist.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaylistCoverFallback();
                  },
                )
                : _buildPlaylistCoverFallback(),

            // Gradient overlay for better text visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit Playlist',
          onPressed: _editPlaylist,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: 'More Options',
          onPressed: _showPlaylistOptions,
        ),
      ],
    );
  }

  Widget _buildPlaylistCoverFallback() {
    // Generate a color based on the playlist title
    final color =
        Colors.primaries[_playlist.title.hashCode % Colors.primaries.length];

    return Container(
      color: color,
      child: Center(
        child: Icon(
          Icons.queue_music,
          size: 80,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    final songs = _playlist.songs;

    if (songs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No songs in this playlist',
                style: TextStyle(fontSize: 18, color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Text(
                'Add songs to get started',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Songs'),
                onPressed: _addSongs,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          // Playlist info header
          return _buildPlaylistInfoHeader();
        } else {
          // Song item
          final songIndex = index - 1;
          final song = songs[songIndex];
          return _buildSongItem(song, songIndex);
        }
      }, childCount: songs.length + 1),
    );
  }

  Widget _buildPlaylistInfoHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playlist details
          if (_playlist.description != null &&
              _playlist.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _playlist.description!,
                style: TextStyle(color: Colors.grey[300], fontSize: 14),
              ),
            ),

          // Playlist stats
          Row(
            children: [
              Text(
                '${_playlist.songs.length} songs',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                _playlist.formattedTotalDuration,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              if (_playlist.isOffline) ...[
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.offline_pin, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Available Offline',
                  style: TextStyle(color: Colors.green[400], fontSize: 14),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.play_arrow,
                label: 'Play',
                onTap: _playAll,
              ),
              _buildActionButton(
                icon: Icons.shuffle,
                label: 'Shuffle',
                onTap: _shufflePlay,
              ),
              _buildActionButton(
                icon: Icons.add,
                label: 'Add Songs',
                onTap: _addSongs,
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: () => _showShareSheet(_playlist),
              ),
            ],
          ),

          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSongItem(Song song, int index) {
    return Dismissible(
      key: Key('song_${song.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => _removeSong(song.id),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            song.albumArt,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 48,
                height: 48,
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white),
              );
            },
          ),
        ),
        title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          song.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              song.duration,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showSongOptions(song),
            ),
          ],
        ),
        onTap: () => _playSong(song, index),
      ),
    );
  }

  void _playAll() {
    // Implement play all functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Playing all songs')));
  }

  void _shufflePlay() {
    // Implement shuffle play functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Shuffling playlist')));
  }

  void _addSongs() {
    // Navigate to a screen to add songs to the playlist
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Add songs functionality')));
  }

  void _showShareSheet(Playlist playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              ShareSheet(contentType: ShareContentType.playlist, content: playlist),
    );
  }

  void _playSong(Song song, int index) {
    // Implement play song functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Playing ${song.title}')));
  }

  Future<void> _removeSong(String songId) async {
    try {
      final playlistService = ref.read(playlistServiceProvider);
      final updatedPlaylist = await playlistService.removeSongFromPlaylist(
        _playlist.id,
        songId,
      );

      setState(() {
        _playlist = updatedPlaylist;
      });

      ref.refresh(playlistsProvider);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing song: $e')));
    }
  }

  void _editPlaylist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePlaylistScreen(playlist: _playlist),
      ),
    ).then((updatedPlaylist) {
      if (updatedPlaylist != null) {
        setState(() {
          _playlist = updatedPlaylist as Playlist;
        });
      }
    });
  }

  void _showPlaylistOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => _PlaylistOptionsSheet(
            playlist: _playlist,
            onPlaylistUpdated: (updatedPlaylist) {
              setState(() {
                _playlist = updatedPlaylist;
              });
              ref.refresh(playlistsProvider);
            },
          ),
    );
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => _SongOptionsSheet(
            song: song,
            playlist: _playlist,
            onSongRemoved: () async {
              await _removeSong(song.id);
            },
          ),
    );
  }
}

class _PlaylistOptionsSheet extends ConsumerWidget {
  final Playlist playlist;
  final Function(Playlist) onPlaylistUpdated;

  const _PlaylistOptionsSheet({
    required this.playlist,
    required this.onPlaylistUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistService = ref.watch(playlistServiceProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Playlist'),
            onTap: () {
              Navigator.pop(context);
              _editPlaylist(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download for Offline'),
            onTap: () {
              Navigator.pop(context);
              _downloadPlaylist(context, playlistService);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Playlist'),
            onTap: () {
              Navigator.pop(context);
              _sharePlaylist(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Playlist',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await _confirmDelete(context);
              if (confirmed == true) {
                await playlistService.deletePlaylist(playlist.id);
                ref.refresh(playlistsProvider);
                Navigator.pop(context); // Pop the playlist detail screen
              }
            },
          ),
        ],
      ),
    );
  }

  void _editPlaylist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePlaylistScreen(playlist: playlist),
      ),
    ).then((updatedPlaylist) {
      if (updatedPlaylist != null) {
        onPlaylistUpdated(updatedPlaylist as Playlist);
      }
    });
  }

  Future<void> _downloadPlaylist(
    BuildContext context,
    PlaylistService playlistService,
  ) async {
    try {
      // Toggle offline status
      final updatedPlaylist = await playlistService.updatePlaylist(
        playlist.copyWith(isOffline: !playlist.isOffline),
      );

      onPlaylistUpdated(updatedPlaylist);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            playlist.isOffline
                ? 'Playlist removed from offline library'
                : 'Playlist added to offline library',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _sharePlaylist(BuildContext context) {
    // Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share functionality')));
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Playlist'),
            content: Text(
              'Are you sure you want to delete "${playlist.title}"? '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
  }
}

class _SongOptionsSheet extends ConsumerWidget {
  final Song song;
  final Playlist playlist;
  final VoidCallback onSongRemoved;

  const _SongOptionsSheet({
    required this.song,
    required this.playlist,
    required this.onSongRemoved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Play'),
            onTap: () {
              Navigator.pop(context);
              // Implement play functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to Another Playlist'),
            onTap: () {
              Navigator.pop(context);
              _addToAnotherPlaylist(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.album),
            title: const Text('Go to Album'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to album
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Go to Artist'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to artist
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
            leading: const Icon(Icons.remove_circle_outline, color: Colors.red),
            title: const Text(
              'Remove from Playlist',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              onSongRemoved();
            },
          ),
        ],
      ),
    );
  }

  void _addToAnotherPlaylist(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddToPlaylistSheet(song: song),
    );
  }
}
