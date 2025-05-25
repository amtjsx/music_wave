import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music/models/playlist.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late ScrollController _scrollController;

  bool _showAppBarTitle = false;
  String _currentFilter = 'All';

  final List<String> _filters = [
    'All',
    'Created',
    'Saved',
    'Downloaded',
    'Recent',
  ];

  // Sample data for user playlists
  final List<Playlist> _userPlaylists = [
    Playlist(
      id: 'playlist1',
      title: 'My Favorites',
      description: 'All my favorite tracks in one place',
      coverUrl: 'https://picsum.photos/400/400?random=601',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'You',
    ),
    Playlist(
      id: 'playlist2',
      title: 'Workout Mix',
      description: 'High energy tracks to keep me going',
      coverUrl: 'https://picsum.photos/400/400?random=602',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'You',
    ),
    Playlist(
      id: 'playlist3',
      title: 'Chill Vibes',
      description: 'Relaxing tunes for unwinding',
      coverUrl: 'https://picsum.photos/400/400?random=603',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'You',
    ),
    Playlist(
      id: 'playlist4',
      title: 'Road Trip',
      description: 'Songs for the open road',
      coverUrl: 'https://picsum.photos/400/400?random=604',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'You',
    ),
    Playlist(
      id: 'playlist5',
      title: 'Throwbacks',
      description: 'Nostalgic hits from the past',
      coverUrl: 'https://picsum.photos/400/400?random=605',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'You',
    ),
  ];

  // Sample data for featured playlists
  final List<Playlist> _featuredPlaylists = [
    Playlist(
      id: 'featured1',
      title: 'Today\'s Top Hits',
      description: 'The hottest tracks right now',
      coverUrl: 'https://picsum.photos/400/400?random=701',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'Music Wave',
    ),
    Playlist(
      id: 'featured2',
      title: 'RapCaviar',
      description: 'Hip-hop\'s heavy hitters and rising stars',
      coverUrl: 'https://picsum.photos/400/400?random=702',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'Music Wave',
    ),
    Playlist(
      id: 'featured3',
      title: 'Rock Classics',
      description: 'Rock legends & epic guitar solos',
      coverUrl: 'https://picsum.photos/400/400?random=703',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'Music Wave',
    ),
    Playlist(
      id: 'featured4',
      title: 'Chill Hits',
      description: 'Kick back to the best new chill hits',
      coverUrl: 'https://picsum.photos/400/400?random=704',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'Music Wave',
    ),
    Playlist(
      id: 'featured5',
      title: 'Mood Booster',
      description: 'Feel-good tracks to lift your spirits!',
      coverUrl: 'https://picsum.photos/400/400?random=705',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'Music Wave',
    ),
    Playlist(
      id: 'featured5',
      title: 'Mood Booster',
      description: 'Feel-good tracks to lift your spirits!',
      coverUrl: 'https://picsum.photos/400/400?random=705',
      songs: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOffline: true,
      creatorName: 'Music Wave',
    ),
  ];

  // Sample data for genre playlists
  final List<Map<String, dynamic>> _genrePlaylists = [
    {
      'id': 'genre1',
      'title': 'Pop',
      'image': 'https://picsum.photos/400/400?random=801',
      'color': const Color(0xFFEC4899),
    },
    {
      'id': 'genre2',
      'title': 'Hip-Hop',
      'image': 'https://picsum.photos/400/400?random=802',
      'color': const Color(0xFF6366F1),
    },
    {
      'id': 'genre3',
      'title': 'Rock',
      'image': 'https://picsum.photos/400/400?random=803',
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'genre4',
      'title': 'R&B',
      'image': 'https://picsum.photos/400/400?random=804',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 'genre5',
      'title': 'Electronic',
      'image': 'https://picsum.photos/400/400?random=805',
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'genre6',
      'title': 'Jazz',
      'image': 'https://picsum.photos/400/400?random=806',
      'color': const Color(0xFF3B82F6),
    },
  ];

  // Sample data for mood playlists
  final List<Map<String, dynamic>> _moodPlaylists = [
    {
      'id': 'mood1',
      'title': 'Happy',
      'image': 'https://picsum.photos/400/400?random=901',
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'mood2',
      'title': 'Chill',
      'image': 'https://picsum.photos/400/400?random=902',
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'mood3',
      'title': 'Focus',
      'image': 'https://picsum.photos/400/400?random=903',
      'color': const Color(0xFF3B82F6),
    },
    {
      'id': 'mood4',
      'title': 'Workout',
      'image': 'https://picsum.photos/400/400?random=904',
      'color': const Color(0xFFEC4899),
    },
    {
      'id': 'mood5',
      'title': 'Party',
      'image': 'https://picsum.photos/400/400?random=905',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 'mood6',
      'title': 'Sleep',
      'image': 'https://picsum.photos/400/400?random=906',
      'color': const Color(0xFF6366F1),
    },
  ];

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 120;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Create New Playlist',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Playlist Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.public, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Public', style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: const Color(0xFF6366F1),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Create playlist logic would go here
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showPlaylistOptions(Playlist playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Playlist info header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(playlist.coverUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'By ${playlist.creatorName}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${playlist.songs.length} songs • ${playlist.totalDuration.inMinutes} min',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    Icons.play_arrow,
                    'Play',
                    () => Navigator.pop(context),
                  ),
                  _buildActionButton(
                    Icons.shuffle,
                    'Shuffle',
                    () => Navigator.pop(context),
                  ),
                  if (playlist.creatorName == 'You')
                    _buildActionButton(
                      Icons.edit,
                      'Edit',
                      () => Navigator.pop(context),
                    )
                  else
                    _buildActionButton(
                      playlist.isOffline
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      playlist.isOffline ? 'Saved' : 'Save',
                      () => Navigator.pop(context),
                    ),
                  _buildActionButton(
                    Icons.share,
                    'Share',
                    () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Additional options
              Column(
                children: [
                  if (playlist.creatorName == 'You') ...[
                    _buildOptionTile(
                      Icons.add,
                      'Add Songs',
                      'Add more songs to this playlist',
                      () => Navigator.pop(context),
                    ),
                    _buildOptionTile(
                      Icons.sort,
                      'Reorder Songs',
                      'Change the order of songs',
                      () => Navigator.pop(context),
                    ),
                  ],
                  _buildOptionTile(
                    Icons.download,
                    playlist.isOffline ? 'Downloaded' : 'Download',
                    playlist.isOffline
                        ? 'Available offline'
                        : 'Make available offline',
                    () => Navigator.pop(context),
                  ),
                  if (playlist.creatorName == 'You')
                    _buildOptionTile(
                      Icons.delete_outline,
                      'Delete Playlist',
                      'Remove this playlist',
                      () => Navigator.pop(context),
                      isDestructive: true,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlaylistDialog,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with wave background
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            title:
                _showAppBarTitle
                    ? const Text(
                      'Playlists',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Animated wave background
                  AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: PlaylistWavePainter(_waveAnimation.value),
                        child: Container(),
                      );
                    },
                  ),
                ],
              ),
              title:
                  !_showAppBarTitle
                      ? const Text(
                        'Playlists',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
          ),

          // Filter tabs
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _filters[index] == _currentFilter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentFilter = _filters[index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            isSelected
                                ? null
                                : Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                      ),
                      child: Center(
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Your Playlists Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  const Text(
                    'Your Playlists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/your-playlists'),
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Your Playlists Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.67,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    // Create Playlist Card
                    return GestureDetector(
                      onTap: _showCreatePlaylistDialog,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFF6366F1),
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Create Playlist',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add your favorite songs',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final playlist = _userPlaylists[index - 1];
                  return GestureDetector(
                    onTap: () {
                      context.push('/playlists/${playlist.id}');
                    },
                    onLongPress: () => _showPlaylistOptions(playlist),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Playlist Cover
                          Stack(
                            children: [
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(playlist.coverUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (playlist.isOffline)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.download_done,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6366F1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Playlist Details
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${playlist.songs.length} songs • ${playlist.totalDuration.inMinutes} min',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Updated ${playlist.updatedAt}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount:
                    _userPlaylists.length + 1, // +1 for create playlist card
              ),
            ),
          ),

          // Featured Playlists Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Row(
                children: [
                  const Text(
                    'Featured Playlists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Featured Playlists Horizontal List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _featuredPlaylists.length,
                itemBuilder: (context, index) {
                  final playlist = _featuredPlaylists[index];
                  return GestureDetector(
                    onTap: () {},
                    onLongPress: () => _showPlaylistOptions(playlist),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Playlist Cover
                          Stack(
                            children: [
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(playlist.coverUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (playlist.isOffline)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.bookmark,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Playlist Details
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'By ${playlist.creatorName}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Browse by Genre Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Row(
                children: [
                  const Text(
                    'Browse by Genre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Genre Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final genre = _genrePlaylists[index];
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(genre['image']),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          genre['color'].withOpacity(0.7),
                          BlendMode.overlay,
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),

                        // Genre name
                        Center(
                          child: Text(
                            genre['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _genrePlaylists.length),
            ),
          ),

          // Mood Playlists Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Row(
                children: [
                  const Text(
                    'Browse by Mood',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mood Horizontal List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _moodPlaylists.length,
                itemBuilder: (context, index) {
                  final mood = _moodPlaylists[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            image: DecorationImage(
                              image: NetworkImage(mood['image']),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                mood['color'].withOpacity(0.3),
                                BlendMode.overlay,
                              ),
                            ),
                            border: Border.all(color: mood['color'], width: 3),
                          ),
                          child: Center(
                            child: Text(
                              mood['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
       
 
    );
  }
}

class PlaylistWavePainter extends CustomPainter {
  final double animationValue;

  PlaylistWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw animated waves
    final wavePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // First wave
    final path1 = Path();
    final waveHeight1 = size.height * 0.05;
    final waveLength1 = size.width * 0.7;
    final waveOffset1 = size.height * 0.4;

    path1.moveTo(0, waveOffset1);
    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveOffset1 +
          waveHeight1 *
              math.sin((x / waveLength1 * 2 * math.pi) + animationValue);
      path1.lineTo(x, y);
    }

    canvas.drawPath(path1, wavePaint);

    // Second wave
    final path2 = Path();
    final waveHeight2 = size.height * 0.03;
    final waveLength2 = size.width * 0.5;
    final waveOffset2 = size.height * 0.5;

    path2.moveTo(0, waveOffset2);
    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveOffset2 +
          waveHeight2 *
              math.sin((x / waveLength2 * 2 * math.pi) + animationValue * 1.3);
      path2.lineTo(x, y);
    }

    canvas.drawPath(path2, wavePaint);

    // Third wave
    final path3 = Path();
    final waveHeight3 = size.height * 0.04;
    final waveLength3 = size.width * 0.9;
    final waveOffset3 = size.height * 0.6;

    path3.moveTo(0, waveOffset3);
    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveOffset3 +
          waveHeight3 *
              math.sin((x / waveLength3 * 2 * math.pi) + animationValue * 0.7);
      path3.lineTo(x, y);
    }

    canvas.drawPath(path3, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
