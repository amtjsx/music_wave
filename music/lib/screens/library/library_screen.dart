import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music/models/song.dart';
import 'package:music/services/song_service.dart';

// Convert to ConsumerStatefulWidget for Riverpod
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late TextEditingController _searchController;
  bool _isSearching = false;
  String _searchQuery = '';
  String _sortOption = 'Recently Added';
  bool _showOnlyDownloaded = false;

  // Sample data for library content (will be replaced with data from SongNotifier)
  List<Map<String, dynamic>> _playlists = [];
  List<Map<String, dynamic>> _albums = [];
  List<Map<String, dynamic>> _artists = [];
  List<Song> _recentlyPlayed = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController = TextEditingController();

    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    // Initialize data from SongNotifier
    _initializeData();
  }

  void _initializeData() {
    // This will be called in initState to load data from SongNotifier
    final songNotifier = ref.read(songNotifierProvider.notifier);
    final playerState = ref.read(songNotifierProvider);

    // Load mock data initially
    final mockSongs = songNotifier.getMockSongs();
    final mockPlaylists = songNotifier.getMockPlaylists();

    // Convert to the format expected by the UI
    _playlists =
        mockPlaylists.map((playlist) {
          return {
            'name': playlist.name,
            'description': playlist.description,
            'imageUrl': playlist.coverUrl,
            'songCount': playlist.songIds.length,
            'isCreated':
                playlist.creatorId ==
                'user123', // Assuming 'user123' is the current user
            'isDownloaded': math.Random().nextBool(), // Random for demo
          };
        }).toList();

    // Group songs by album
    final albumMap = <String, Map<String, dynamic>>{};
    for (final song in mockSongs) {
      if (!albumMap.containsKey(song.albumId)) {
        albumMap[song.albumId] = {
          'name': song.albumName,
          'artist': song.artist.name,
          'imageUrl': song.albumArt,
          'year': '2023', // Mock year
          'isDownloaded': math.Random().nextBool(), // Random for demo
        };
      }
    }
    _albums = albumMap.values.toList();

    // Group songs by artist
    final artistMap = <String, Map<String, dynamic>>{};
    for (final song in mockSongs) {
      if (!artistMap.containsKey(song.artistId)) {
        artistMap[song.artistId] = {
          'name': song.artist.name,
          'imageUrl': song.albumArt,
          'followers':
              '${(math.Random().nextInt(90) + 10)}.${math.Random().nextInt(9)}M',
          'isDownloaded': math.Random().nextBool(), // Random for demo
        };
      }
    }
    _artists = artistMap.values.toList();

    // Get recently played songs
    _recentlyPlayed =
        playerState.recentlyPlayed.isEmpty
            ? mockSongs.take(4).toList()
            : playerState.recentlyPlayed;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _waveController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter content based on search query and filters
  List<Map<String, dynamic>> _getFilteredPlaylists() {
    return _playlists.where((playlist) {
      // Apply search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          playlist['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          playlist['description'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Apply download filter
      final matchesDownload =
          !_showOnlyDownloaded || playlist['isDownloaded'] == true;

      return matchesSearch && matchesDownload;
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredAlbums() {
    return _albums.where((album) {
      // Apply search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          album['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          album['artist'].toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply download filter
      final matchesDownload =
          !_showOnlyDownloaded || album['isDownloaded'] == true;

      return matchesSearch && matchesDownload;
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredArtists() {
    return _artists.where((artist) {
      // Apply search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          artist['name'].toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply download filter
      final matchesDownload =
          !_showOnlyDownloaded || artist['isDownloaded'] == true;

      return matchesSearch && matchesDownload;
    }).toList();
  }

  // Sort content based on selected option
  void _sortContent() {
    if (_sortOption == 'Recently Added') {
      // Already in the default order
    } else if (_sortOption == 'Alphabetical') {
      _playlists.sort((a, b) => a['name'].compareTo(b['name']));
      _albums.sort((a, b) => a['name'].compareTo(b['name']));
      _artists.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (_sortOption == 'Creator') {
      _playlists.sort((a, b) {
        if (a['isCreated'] == b['isCreated']) {
          return a['name'].compareTo(b['name']);
        }
        return a['isCreated'] ? -1 : 1;
      });
    }
  }

  void _showSortFilterBottomSheet() {
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
                    'Sort & Filter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildSortChip('Recently Added', setState),
                      _buildSortChip('Alphabetical', setState),
                      _buildSortChip('Creator', setState),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Switch(
                        value: _showOnlyDownloaded,
                        onChanged: (value) {
                          setState(() {
                            _showOnlyDownloaded = value;
                          });
                          this.setState(() {});
                        },
                        activeColor: const Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Show downloaded only',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _sortContent();
                        this.setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(String label, StateSetter setState) {
    final isSelected = _sortOption == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFF2A2A2A),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortOption = label;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch player state for updates using the StateNotifierProvider

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          // Header with wave animation
          _buildHeader(),

          // Tab bar
          Container(
            color: const Color(0xFF1A1A1A),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF6366F1),
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Playlists'),
                Tab(text: 'Albums'),
                Tab(text: 'Artists'),
                Tab(text: 'Downloads'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlaylistsTab(),
                _buildAlbumsTab(),
                _buildArtistsTab(),
                _buildDownloadsTab(),
              ],
            ),
          ),
        ],
      ),
      // Mini player with StateNotifierProvider integration
 
      floatingActionButton:
          _tabController.index == 0
              ? FloatingActionButton(
                onPressed: () {
                  // Navigate to create playlist screen
                  context.push('/create-playlist');
                },
                backgroundColor: const Color(0xFF6366F1),
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      height: _isSearching ? 160 : 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
      ),
      child: Stack(
        children: [
          // Wave animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: LibraryWavePainter(_waveAnimation.value),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with title and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
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
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.sort, color: Colors.white),
                            onPressed: _showSortFilterBottomSheet,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Search field (visible only when searching)
                  if (_isSearching) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search in your library',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    final filteredPlaylists = _getFilteredPlaylists();
    final createdPlaylists =
        filteredPlaylists
            .where((playlist) => playlist['isCreated'] == true)
            .toList();
    final followedPlaylists =
        filteredPlaylists
            .where((playlist) => playlist['isCreated'] == false)
            .toList();

    return CustomScrollView(
      slivers: [
        // Recently played section (only show if not searching)
        if (_searchQuery.isEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recently Played',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to recently played screen
                      context.push('/recently-played');
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF6366F1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _recentlyPlayed.length,
                itemBuilder: (context, index) {
                  final song = _recentlyPlayed[index];
                  return _buildRecentlyPlayedSongItem(song);
                },
              ),
            ),
          ),
        ],

        // Created playlists section
        if (createdPlaylists.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Your Playlists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (createdPlaylists.length > 3) ...[
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Color(0xFF6366F1)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < createdPlaylists.length) {
                return _buildPlaylistItem(createdPlaylists[index]);
              }
              return null;
            }, childCount: createdPlaylists.length),
          ),
        ],

        // Followed playlists section
        if (followedPlaylists.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Followed Playlists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (followedPlaylists.length > 3) ...[
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Color(0xFF6366F1)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < followedPlaylists.length) {
                return _buildPlaylistItem(followedPlaylists[index]);
              }
              return null;
            }, childCount: followedPlaylists.length),
          ),
        ],

        // Empty state
        if (filteredPlaylists.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_play,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No playlists match "$_searchQuery"'
                        : 'No playlists found',
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
                        : 'Create a playlist to get started',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildAlbumsTab() {
    final filteredAlbums = _getFilteredAlbums();

    return CustomScrollView(
      slivers: [
        // Albums grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < filteredAlbums.length) {
                return _buildAlbumItem(filteredAlbums[index]);
              }
              return null;
            }, childCount: filteredAlbums.length),
          ),
        ),

        // Empty state
        if (filteredAlbums.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.album,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No albums match "$_searchQuery"'
                        : 'No saved albums',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save albums to find them here',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildArtistsTab() {
    final filteredArtists = _getFilteredArtists();

    return CustomScrollView(
      slivers: [
        // Artists list
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < filteredArtists.length) {
                return _buildArtistItem(filteredArtists[index]);
              }
              return null;
            }, childCount: filteredArtists.length),
          ),
        ),

        // Empty state
        if (filteredArtists.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No artists match "$_searchQuery"'
                        : 'No followed artists',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Follow artists to find them here',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildDownloadsTab() {
    final downloadedPlaylists =
        _playlists.where((p) => p['isDownloaded'] == true).toList();
    final downloadedAlbums =
        _albums.where((a) => a['isDownloaded'] == true).toList();
    final downloadedArtists =
        _artists.where((a) => a['isDownloaded'] == true).toList();

    final hasDownloads =
        downloadedPlaylists.isNotEmpty ||
        downloadedAlbums.isNotEmpty ||
        downloadedArtists.isNotEmpty;

    return CustomScrollView(
      slivers: [
        // Storage info
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloaded Music',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '2.3 GB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.35,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '35% of 6.5 GB used',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        // Downloaded playlists
        if (downloadedPlaylists.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Playlists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${downloadedPlaylists.length} items',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < downloadedPlaylists.length) {
                return _buildPlaylistItem(downloadedPlaylists[index]);
              }
              return null;
            }, childCount: downloadedPlaylists.length),
          ),
        ],

        // Downloaded albums
        if (downloadedAlbums.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Albums',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${downloadedAlbums.length} items',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: downloadedAlbums.length,
                itemBuilder: (context, index) {
                  return _buildDownloadedAlbumItem(downloadedAlbums[index]);
                },
              ),
            ),
          ),
        ],

        // Downloaded artists
        if (downloadedArtists.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Artists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${downloadedArtists.length} items',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: downloadedArtists.length,
                itemBuilder: (context, index) {
                  return _buildDownloadedArtistItem(downloadedArtists[index]);
                },
              ),
            ),
          ),
        ],

        // Empty state
        if (!hasDownloads)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No downloads yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Download music to listen offline',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(0);
                    },
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
                    child: const Text('Browse Music'),
                  ),
                ],
              ),
            ),
          ),

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  // New method to build recently played items from Song objects
  Widget _buildRecentlyPlayedSongItem(Song song) {
    return GestureDetector(
      onTap: () {
        final songIndex = _recentlyPlayed.indexWhere((s) => s.id == song.id);

        ref
            .read(songNotifierProvider.notifier)
            .playPlaylist(
              _recentlyPlayed,
              startIndex: songIndex >= 0 ? songIndex : 0,
            );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(song.albumArt),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist.name,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistItem(Map<String, dynamic> playlist) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: NetworkImage(playlist['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        playlist['name'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${playlist['songCount']} songs${playlist['isCreated'] ? ' • Created by you' : ''}',
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playlist['isDownloaded'])
            const Icon(Icons.download_done, color: Color(0xFF6366F1), size: 20),
          const SizedBox(width: 16),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
      onTap: () {
        // Navigate to playlist detail
        context.push(
          '/playlists/${playlist['name'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
    );
  }

  Widget _buildAlbumItem(Map<String, dynamic> album) {
    return GestureDetector(
      onTap: () {
        // Navigate to album detail
        context.push(
          '/albums/${album['name'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(album['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (album['isDownloaded'])
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.download_done,
                      color: Color(0xFF6366F1),
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            album['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${album['artist']} • ${album['year']}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildArtistItem(Map<String, dynamic> artist) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(artist['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        artist['name'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${artist['followers']} followers',
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (artist['isDownloaded'])
            const Icon(Icons.download_done, color: Color(0xFF6366F1), size: 20),
          const SizedBox(width: 16),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
      onTap: () {
        // Navigate to artist detail
        context.push(
          '/artists/${artist['name'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
    );
  }

  Widget _buildDownloadedAlbumItem(Map<String, dynamic> album) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(album['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            album['artist'],
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadedArtistItem(Map<String, dynamic> artist) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(artist['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class LibraryWavePainter extends CustomPainter {
  final double animationValue;

  LibraryWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    final waveHeight = 15.0;
    final waveLength = size.width / 3;

    for (int i = 0; i < 3; i++) {
      path.reset();
      final yOffset = size.height * 0.3 + (i * 20);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            yOffset +
            waveHeight *
                math.sin(
                  (x / waveLength * 2 * math.pi) + animationValue + (i * 0.7),
                );
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
