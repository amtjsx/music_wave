import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/playlist.dart';
import 'package:music/models/song.dart';
import 'package:music/screens/playlists/create_playlist_screen.dart';
import 'package:music/services/playlist_service.dart';

class AddToPlaylistSheet extends ConsumerStatefulWidget {
  final Song song;

  const AddToPlaylistSheet({super.key, required this.song});

  @override
  ConsumerState<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends ConsumerState<AddToPlaylistSheet> {
  bool _isLoading = false;
  List<String> _playlistsContainingSong = [];

  @override
  void initState() {
    super.initState();
    _checkPlaylistsContainingSong();
  }

  Future<void> _checkPlaylistsContainingSong() async {
    final playlistService = ref.read(playlistServiceProvider);
    final playlists = await playlistService.getPlaylistsContainingSong(
      widget.song.id,
    );

    setState(() {
      _playlistsContainingSong = playlists.map((p) => p.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add to Playlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.song.title} • ${widget.song.artist}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // Create new playlist button
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            title: const Text('Create New Playlist'),
            onTap: _createNewPlaylist,
          ),

          const Divider(height: 16),

          // Playlists list
          Flexible(
            child: playlistsAsync.when(
              data: (playlists) {
                if (playlists.isEmpty) {
                  return const Center(child: Text('No playlists yet'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final isInPlaylist = _playlistsContainingSong.contains(
                      playlist.id,
                    );

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child:
                            playlist.coverUrl != null
                                ? Image.network(
                                  playlist.coverUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaylistCoverFallback(
                                      playlist,
                                    );
                                  },
                                )
                                : _buildPlaylistCoverFallback(playlist),
                      ),
                      title: Text(
                        playlist.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${playlist.songs.length} songs',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      trailing:
                          isInPlaylist
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                      onTap:
                          () => _toggleSongInPlaylist(playlist, isInPlaylist),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading playlists: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCoverFallback(Playlist playlist) {
    // Generate a color based on the playlist title
    final color =
        Colors.primaries[playlist.title.hashCode % Colors.primaries.length];

    return Container(
      width: 40,
      height: 40,
      color: color,
      child: Center(
        child: Icon(
          Icons.queue_music,
          size: 20,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Future<void> _toggleSongInPlaylist(
    Playlist playlist,
    bool isInPlaylist,
  ) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final playlistService = ref.read(playlistServiceProvider);

      if (isInPlaylist) {
        // Remove song from playlist
        await playlistService.removeSongFromPlaylist(
          playlist.id,
          widget.song.id,
        );

        setState(() {
          _playlistsContainingSong.remove(playlist.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed from ${playlist.title}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add song to playlist
        await playlistService.addSongToPlaylist(playlist.id, widget.song);

        setState(() {
          _playlistsContainingSong.add(playlist.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to ${playlist.title}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // Refresh playlists provider
      ref.refresh(playlistsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _createNewPlaylist() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePlaylistScreen()),
    );

    if (result != null && result is Playlist) {
      // Add song to the newly created playlist
      if (mounted) {
        final playlistService = ref.read(playlistServiceProvider);
        await playlistService.addSongToPlaylist(result.id, widget.song);

        setState(() {
          _playlistsContainingSong.add(result.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to ${result.title}'),
            duration: const Duration(seconds: 2),
          ),
        );

        // Refresh playlists provider
        ref.refresh(playlistsProvider);
      }
    }
  }
}
