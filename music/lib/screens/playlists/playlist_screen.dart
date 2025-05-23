import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/screens/playlists/create_playlist_screen.dart';
import 'package:music/screens/playlists/playlist_detail_screen.dart';

import '../../models/playlist.dart';
import '../../services/playlist_service.dart';

class PlaylistListScreen extends ConsumerWidget {
  const PlaylistListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Playlist',
            onPressed: () => _createPlaylist(context),
          ),
        ],
      ),
      body: playlistsAsync.when(
        data: (playlists) => _buildPlaylistList(context, playlists),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading playlists: $error')),
      ),
    );
  }

  Widget _buildPlaylistList(BuildContext context, List<Playlist> playlists) {
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_music, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No playlists yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first playlist to get started',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Playlist'),
              onPressed: () => _createPlaylist(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return _buildPlaylistItem(context, playlist);
      },
    );
  }

  Widget _buildPlaylistItem(BuildContext context, Playlist playlist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openPlaylist(context, playlist),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Playlist cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    playlist.coverUrl != null
                        ? Image.network(
                          playlist.coverUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaylistCoverFallback(playlist);
                          },
                        )
                        : _buildPlaylistCoverFallback(playlist),
              ),
              const SizedBox(width: 16),

              // Playlist details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.description ?? 'No description',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${playlist.songs.length} songs',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          playlist.formattedTotalDuration,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        if (playlist.isOffline) ...[
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.offline_pin,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: TextStyle(
                              color: Colors.green[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // More options
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showPlaylistOptions(context, playlist),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistCoverFallback(Playlist playlist) {
    // Generate a color based on the playlist title
    final color =
        Colors.primaries[playlist.title.hashCode % Colors.primaries.length];

    return Container(
      width: 80,
      height: 80,
      color: color,
      child: Center(
        child: Icon(
          Icons.queue_music,
          size: 40,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  void _createPlaylist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePlaylistScreen()),
    );
  }

  void _openPlaylist(BuildContext context, Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlistId: playlist.id),
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PlaylistOptionsSheet(playlist: playlist),
    );
  }
}

class _PlaylistOptionsSheet extends ConsumerWidget {
  final Playlist playlist;

  const _PlaylistOptionsSheet({required this.playlist});

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
    );
  }

  void _sharePlaylist(BuildContext context) {
    // Implement share functionality
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
