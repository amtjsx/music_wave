import 'package:flutter/material.dart';
import 'package:music/models/artist.dart';
import 'package:music/models/song.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  bool _isPlaying = false;
  bool _isFavorite = false;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  String playlistName = "Playlist Name";

  // Sample data - in a real app, you would fetch this from your data source
  late List<Song> _songs;

  @override
  void initState() {
    super.initState();

    // Initialize with sample data
    _songs = List.generate(
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

    // Listen to scroll to change app bar title visibility
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show app bar title when scrolled past the header
    final showTitle = _scrollController.offset > 200;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            title: AnimatedOpacity(
              opacity: _showAppBarTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(playlistName),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildPlaylistHeader()),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),

          // Playlist Controls
          SliverToBoxAdapter(child: _buildPlaylistControls()),

          // Songs List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSongItem(_songs[index], index),
              childCount: _songs.length,
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      // Add a floating play button that appears when scrolling
      floatingActionButton: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
        ),
      ),
    );
  }

  Widget _buildPlaylistHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Playlist Cover Image with Gradient Overlay
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.9),
              ],
            ).createShader(rect);
          },
          blendMode: BlendMode.darken,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              image: DecorationImage(
                image: NetworkImage(
                  'https://via.placeholder.com/500?text=Playlist+${widget.playlistId}',
                ),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle error - in a real app you might want to show a placeholder
                },
              ),
            ),
          ),
        ),

        // Playlist Info
        Positioned(
          left: 20,
          right: 20,
          bottom: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PLAYLIST',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                playlistName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Created by Music App • ${_songs.length} songs, ${_calculateTotalDuration()}',
                style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              ),
              const SizedBox(height: 4),
              Text(
                '10.5K likes • 3.2K followers',
                style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Play/Pause Button
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(_isPlaying ? 'PAUSE' : 'PLAY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),

          // Favorite Button
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),

          // Download Button
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              // Implement download functionality
            },
          ),

          // Share Button
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSongItem(Song song, int index) {
    final isPlaying = _isPlaying && index == 0; // Assume first song is playing

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 48,
          height: 48,
          color: Colors.grey[800],
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Album Art (or placeholder)
              Image.network(
                song.albumArt,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.music_note, color: Colors.grey[500]);
                },
              ),

              // Play indicator overlay
              if (isPlaying)
                Container(
                  width: 48,
                  height: 48,
                  color: Colors.black.withOpacity(0.5),
                  child: const Icon(Icons.equalizer, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          color:
              isPlaying
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.white,
        ),
      ),
      subtitle: Text(song.artist, style: TextStyle(color: Colors.grey[400])),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            song.duration, // Use the string duration directly
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {
              _showSongOptions(context, song);
            },
          ),
        ],
      ),
      onTap: () {
        // Play the selected song
        setState(() {
          _isPlaying = true;
        });
      },
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
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
              // Song info header
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    song.albumArt,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_note, size: 20),
                      );
                    },
                  ),
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
              ),

              const Divider(height: 1),

              // Options
              ListTile(
                leading: const Icon(Icons.add_to_queue),
                title: const Text('Add to queue'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to playlist'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.album),
                title: const Text('Go to album'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Go to artist'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _calculateTotalDuration() {
    // Estimate total duration based on string format (assuming format is "m:ss")
    int totalMinutes = 0;
    int totalSeconds = 0;

    for (var song in _songs) {
      try {
        final parts = song.duration.split(':');
        if (parts.length == 2) {
          totalMinutes += int.parse(parts[0]);
          totalSeconds += int.parse(parts[1]);
        }
      } catch (e) {
        // Handle parsing errors
        print('Error parsing duration: ${song.duration}');
      }
    }

    // Convert excess seconds to minutes
    totalMinutes += totalSeconds ~/ 60;
    totalSeconds = totalSeconds % 60;

    // Calculate hours if needed
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return '$hours hr ${minutes} min';
    } else {
      return '$minutes min';
    }
  }
}
