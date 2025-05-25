import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/song.dart';
import 'package:music/services/song_service.dart';

class RecentlyPlayedScreen extends ConsumerStatefulWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  ConsumerState<RecentlyPlayedScreen> createState() =>
      _RecentlyPlayedScreenState();
}

class _RecentlyPlayedScreenState extends ConsumerState<RecentlyPlayedScreen>
    with TickerProviderStateMixin {
  late TabController _filterController;
  String _currentFilter = 'All';
  String _currentSort = 'Recent';
  bool _showWaveAnimation = true;

  final List<String> _filters = [
    'All',
    'Songs',
    'Albums',
    'Playlists',
    'Artists',
    'Podcasts',
  ];
  final List<String> _sortOptions = ['Recent', 'Most Played', 'Alphabetical'];
  List<Song> _recentlyPlayed = [];

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _filterController = TabController(length: _filters.length, vsync: this);

    _waveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);
    _initializeData();
  }

  void _initializeData() {
    // This will be called in initState to load data from SongNotifier
    final songNotifier = ref.read(songNotifierProvider.notifier);
    final playerState = ref.read(songNotifierProvider);

    // Load mock data initially
    final mockSongs = songNotifier.getMockSongs();

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

    // Get recently played songs
    _recentlyPlayed =
        playerState.recentlyPlayed.isEmpty
            ? mockSongs.take(4).toList()
            : playerState.recentlyPlayed;
  }

  @override
  void dispose() {
    _filterController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Recently Played'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'sort') {
                _showSortOptions();
              } else if (value == 'toggle_wave') {
                setState(() {
                  _showWaveAnimation = !_showWaveAnimation;
                });
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'sort', child: Text('Sort by')),
                  PopupMenuItem(
                    value: 'toggle_wave',
                    child: Text(
                      _showWaveAnimation
                          ? 'Hide wave animation'
                          : 'Show wave animation',
                    ),
                  ),
                ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // Current filter and sort info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing $_currentFilter',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _showSortOptions,
                    child: Row(
                      children: [
                        const Icon(Icons.sort, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Sorted by: $_currentSort',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Today Section
          SliverToBoxAdapter(child: _buildSectionHeader('Today')),
          SliverList(
            delegate: SliverChildListDelegate(
              _recentlyPlayed
                  .map((song) => _buildRecentItem(song, 'song'))
                  .toList(),
            ),
          ),

          // Yesterday Section
          SliverToBoxAdapter(child: _buildSectionHeader('Yesterday')),
          SliverList(
            delegate: SliverChildListDelegate(
              _recentlyPlayed
                  .map((song) => _buildRecentItem(song, 'song'))
                  .toList(),
            ),
          ),

          // This Week Section
          SliverToBoxAdapter(child: _buildSectionHeader('This Week')),
          SliverList(
            delegate: SliverChildListDelegate(
              _recentlyPlayed
                  .map((song) => _buildRecentItem(song, 'song'))
                  .toList(),
            ),
          ),

          // Earlier This Month Section
          SliverToBoxAdapter(child: _buildSectionHeader('Earlier This Month')),
          SliverList(
            delegate: SliverChildListDelegate(
              _recentlyPlayed
                  .map((song) => _buildRecentItem(song, 'song'))
                  .toList(),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
       
 
    );
  }

  // Rest of the methods remain the same...
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecentItem(Song song, String type) {
    IconData typeIcon;
    Color typeColor;

    switch (type) {
      case 'song':
        typeIcon = Icons.music_note;
        typeColor = const Color(0xFF6366F1);
        break;
      case 'album':
        typeIcon = Icons.album;
        typeColor = const Color(0xFFEC4899);
        break;
      case 'playlist':
        typeIcon = Icons.queue_music;
        typeColor = const Color(0xFF1DB954);
        break;
      case 'artist':
        typeIcon = Icons.person;
        typeColor = const Color(0xFFFFA500);
        break;
      case 'podcast':
        typeIcon = Icons.mic;
        typeColor = const Color(0xFF8B5CF6);
        break;
      default:
        typeIcon = Icons.music_note;
        typeColor = const Color(0xFF6366F1);
    }

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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    type == 'artist' ? 28 : 8,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(song.albumArt),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          title: Text(
            song.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.artist.name,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[600], size: 12),
                  const SizedBox(width: 4),
                  Text(
                    song.duration,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.timer, color: Colors.grey[600], size: 12),
                    const SizedBox(width: 4),
                    Text(
                      song.duration,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              // Handle menu item selection
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'play', child: Text('Play')),
                  const PopupMenuItem(
                    value: 'queue',
                    child: Text('Add to queue'),
                  ),
                  const PopupMenuItem(
                    value: 'playlist',
                    child: Text('Add to playlist'),
                  ),
                  const PopupMenuItem(value: 'share', child: Text('Share')),
                  if (type == 'song' || type == 'album' || type == 'playlist')
                    const PopupMenuItem(
                      value: 'download',
                      child: Text('Download'),
                    ),
                  if (type == 'artist')
                    const PopupMenuItem(value: 'follow', child: Text('Follow')),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove from history'),
                  ),
                ],
          ),
          onTap: () {
            // Handle item tap
          },
          isThreeLine: true,
        ),
      ),
    );
  }

  void _showSortOptions() {
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
              const SizedBox(height: 16),
              ...List.generate(
                _sortOptions.length,
                (index) => RadioListTile<String>(
                  title: Text(
                    _sortOptions[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: _sortOptions[index],
                  groupValue: _currentSort,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (value) {
                    setState(() {
                      _currentSort = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color1;
  final Color color2;
  final double expansionPercent; // Add this parameter

  WavePainter(
    this.animationValue,
    this.color1,
    this.color2,
    this.expansionPercent,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Create a gradient background
    final backgroundPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Only draw waves if we're expanded enough
    if (expansionPercent > 0.1) {
      // Scale the wave effect based on expansion percentage
      final waveOpacity = 0.3 * expansionPercent;
      final waveHeight = size.height * 0.1 * expansionPercent;
      final waveLength = size.width * 0.5;
      // Adjust the wave position based on expansion
      final waveOffset = size.height * (0.7 + (0.1 * (1.0 - expansionPercent)));

      final paint =
          Paint()
            ..shader = LinearGradient(
              colors: [
                color1.withOpacity(waveOpacity),
                color2.withOpacity(waveOpacity),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
            ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            waveOffset +
            waveHeight *
                math.sin((x / waveLength * 2 * math.pi) + animationValue);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint);

      // Second wave (offset)
      final waveHeight2 = size.height * 0.05 * expansionPercent;
      final waveLength2 = size.width * 0.7;
      final waveOffset2 =
          size.height * (0.8 + (0.1 * (1.0 - expansionPercent)));

      final path2 = Path();
      path2.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            waveOffset2 +
            waveHeight2 *
                math.sin(
                  (x / waveLength2 * 2 * math.pi) + animationValue * 1.5,
                );
        path2.lineTo(x, y);
      }

      path2.lineTo(size.width, size.height);
      path2.close();

      final paint2 =
          Paint()
            ..shader = LinearGradient(
              colors: [
                color2.withOpacity(waveOpacity * 0.7),
                color1.withOpacity(waveOpacity * 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
            ..style = PaintingStyle.fill;

      canvas.drawPath(path2, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
