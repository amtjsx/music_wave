import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music/models/song.dart';
import 'package:music/services/song_service.dart';

class LikedSongsScreen extends ConsumerStatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  ConsumerState<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends ConsumerState<LikedSongsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heartAnimation;

  List<Song> _likedSongs = [];
  List<Song> _filteredSongs = [];
  String _searchQuery = '';
  String _sortOption = 'Recently Added';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _heartAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadLikedSongs();
  }

  void _loadLikedSongs() {
    // Load mock liked songs - in a real app, this would come from local storage or API
    final songNotifier = ref.read(songNotifierProvider.notifier);
    final allSongs = songNotifier.getMockSongs();

    // Simulate liked songs (all songs for demo)
    setState(() {
      _likedSongs = allSongs;
      _filteredSongs = allSongs;
    });
  }

  void _filterSongs() {
    setState(() {
      _filteredSongs =
          _likedSongs.where((song) {
            final matchesSearch =
                _searchQuery.isEmpty ||
                song.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                song.artist.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                song.albumName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
            return matchesSearch;
          }).toList();

      _sortSongs();
    });
  }

  void _sortSongs() {
    switch (_sortOption) {
      case 'Recently Added':
        // Already in default order
        break;
      case 'Title':
        _filteredSongs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Artist':
        _filteredSongs.sort((a, b) => a.artist.name.compareTo(b.artist.name));
        break;
      case 'Album':
        _filteredSongs.sort((a, b) => a.albumName.compareTo(b.albumName));
        break;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSortOption('Recently Added', setState),
                  _buildSortOption('Title', setState),
                  _buildSortOption('Artist', setState),
                  _buildSortOption('Album', setState),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(String option, StateSetter setState) {
    final isSelected = _sortOption == option;
    return ListTile(
      title: Text(
        option,
        style: TextStyle(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: Color(0xFF6366F1)) : null,
      onTap: () {
        setState(() {
          _sortOption = option;
        });
        this.setState(() {
          _sortOption = option;
          _filterSongs();
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body:
          _filteredSongs.isEmpty
              ? _buildEmptyState()
              : _buildScrollableContent(),
 
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Collapsible App Bar with Header
        SliverAppBar(
          expandedHeight: 340,
          floating: false,
          pinned: true,
          stretch: true,
          backgroundColor: const Color(0xFF6366F1),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60), // Space for the app bar
                    // Animated heart icon
                    AnimatedBuilder(
                      animation: _heartAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heartAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Liked Songs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_likedSongs.length} songs',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Play and shuffle buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.play_arrow,
                          label: 'Play',
                          onPressed: () {
                            if (_filteredSongs.isNotEmpty) {
                              ref
                                  .read(songNotifierProvider.notifier)
                                  .playPlaylist(_filteredSongs, startIndex: 0);
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildActionButton(
                          icon: Icons.shuffle,
                          label: 'Shuffle',
                          onPressed: () {
                            if (_filteredSongs.isNotEmpty) {
                              final shuffled = List<Song>.from(_filteredSongs)
                                ..shuffle();
                              ref
                                  .read(songNotifierProvider.notifier)
                                  .playPlaylist(shuffled, startIndex: 0);
                            }
                          },
                        ),
                      ],
                    ),

                    // Search bar
                    if (_isSearching)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _filterSongs();
                            });
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search in liked songs',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            collapseMode: CollapseMode.parallax,
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _searchQuery = '';
                    _filterSongs();
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.sort, color: Colors.white),
              onPressed: _showSortOptions,
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),

        // List header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Your Liked Songs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _sortOption,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ),

        // Songs list
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return _buildSongItem(_filteredSongs[index], index);
          }, childCount: _filteredSongs.length),
        ),

        // Bottom padding for mini player
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: const Color(0xFF6366F1)),
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6366F1),
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildSongItem(Song song, int index) {
    final playerState = ref.watch(songNotifierProvider);
    final isPlaying =
        playerState.currentSong?.id == song.id &&
        playerState.playbackState == PlaybackState.playing;

    return Dismissible(
      key: Key(song.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _likedSongs.removeWhere((s) => s.id == song.id);
          _filterSongs();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${song.title} removed from liked songs'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _likedSongs.insert(index, song);
                  _filterSongs();
                });
              },
            ),
          ),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: NetworkImage(song.albumArt),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (isPlaying)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.volume_up,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          song.title,
          style: TextStyle(
            color: isPlaying ? const Color(0xFF6366F1) : Colors.white,
            fontSize: 16,
            fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            if (song.isExplicit)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'E',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                '${song.artist.name} • ${song.albumName}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              song.duration,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () => _showSongOptions(song),
            ),
          ],
        ),
        onTap: () {
          ref
              .read(songNotifierProvider.notifier)
              .playPlaylist(
                _filteredSongs,
                startIndex: _filteredSongs.indexOf(song),
              );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No songs match "$_searchQuery"'
                : 'No liked songs yet',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Songs you like will appear here',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/explore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Explore Music'),
            ),
          ],
        ],
      ),
    );
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: NetworkImage(song.albumArt),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  song.artist.name,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.queue_music, color: Colors.white),
                title: const Text(
                  'Add to Queue',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Add to queue logic
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text(
                  'Add to Playlist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Add to playlist logic
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.album, color: Colors.white),
                title: const Text(
                  'Go to Album',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/albums/${song.albumId}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  'Go to Artist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/artists/${song.artistId}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text(
                  'Share',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Share logic
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text(
                  'Remove from Liked Songs',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _likedSongs.removeWhere((s) => s.id == song.id);
                    _filterSongs();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
