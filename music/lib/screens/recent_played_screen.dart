import 'dart:math' as math;

import 'package:flutter/material.dart';

class RecentlyPlayedScreen extends StatefulWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  State<RecentlyPlayedScreen> createState() => _RecentlyPlayedScreenState();
}

class _RecentlyPlayedScreenState extends State<RecentlyPlayedScreen>
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
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            pinned: true,
            expandedHeight: 120,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
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
                      const PopupMenuItem(
                        value: 'sort',
                        child: Text('Sort by'),
                      ),
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
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Recently Played',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background:
                  _showWaveAnimation
                      ? AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: WavePainter(
                              _waveAnimation.value,
                              const Color(0xFF6366F1),
                              const Color(0xFF8B5CF6),
                            ),
                          );
                        },
                      )
                      : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                        ),
                      ),
            ),
            bottom: TabBar(
              controller: _filterController,
              isScrollable: true,
              indicatorColor: const Color(0xFF6366F1),
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: _filters.map((filter) => Tab(text: filter)).toList(),
              onTap: (index) {
                setState(() {
                  _currentFilter = _filters[index];
                });
              },
            ),
          ),

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
            delegate: SliverChildListDelegate([
              _buildRecentItem(
                title: 'Blinding Lights',
                subtitle: 'The Weeknd • After Hours',
                image: 'https://picsum.photos/200?random=1',
                time: '2 hours ago',
                type: 'song',
                duration: '3:20',
              ),
              _buildRecentItem(
                title: 'Summer Vibes 2023',
                subtitle: 'Playlist • 45 songs',
                image: 'https://picsum.photos/200?random=2',
                time: '3 hours ago',
                type: 'playlist',
                duration: '2h 35m',
              ),
              _buildRecentItem(
                title: 'Taylor Swift',
                subtitle: 'Artist',
                image: 'https://picsum.photos/200?random=3',
                time: '5 hours ago',
                type: 'artist',
              ),
            ]),
          ),

          // Yesterday Section
          SliverToBoxAdapter(child: _buildSectionHeader('Yesterday')),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildRecentItem(
                title: 'Midnight Memories',
                subtitle: 'One Direction • Midnight Memories (Deluxe)',
                image: 'https://picsum.photos/200?random=4',
                time: '1 day ago',
                type: 'album',
                duration: '45m',
              ),
              _buildRecentItem(
                title: 'As It Was',
                subtitle: 'Harry Styles • Harry\'s House',
                image: 'https://picsum.photos/200?random=5',
                time: '1 day ago',
                type: 'song',
                duration: '2:47',
              ),
              _buildRecentItem(
                title: 'The Joe Rogan Experience',
                subtitle: 'Podcast • Episode #1984',
                image: 'https://picsum.photos/200?random=6',
                time: '1 day ago',
                type: 'podcast',
                duration: '2h 42m',
              ),
            ]),
          ),

          // This Week Section
          SliverToBoxAdapter(child: _buildSectionHeader('This Week')),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildRecentItem(
                title: 'Chill Lofi Beats',
                subtitle: 'Playlist • 78 songs',
                image: 'https://picsum.photos/200?random=7',
                time: '2 days ago',
                type: 'playlist',
                duration: '4h 12m',
              ),
              _buildRecentItem(
                title: 'Kendrick Lamar',
                subtitle: 'Artist',
                image: 'https://picsum.photos/200?random=8',
                time: '3 days ago',
                type: 'artist',
              ),
              _buildRecentItem(
                title: 'Positions',
                subtitle: 'Ariana Grande • Positions',
                image: 'https://picsum.photos/200?random=9',
                time: '4 days ago',
                type: 'album',
                duration: '41m',
              ),
              _buildRecentItem(
                title: 'Levitating',
                subtitle: 'Dua Lipa • Future Nostalgia',
                image: 'https://picsum.photos/200?random=10',
                time: '5 days ago',
                type: 'song',
                duration: '3:23',
              ),
              _buildRecentItem(
                title: 'Workout Mix',
                subtitle: 'Playlist • 32 songs',
                image: 'https://picsum.photos/200?random=11',
                time: '6 days ago',
                type: 'playlist',
                duration: '1h 45m',
              ),
            ]),
          ),

          // Earlier This Month Section
          SliverToBoxAdapter(child: _buildSectionHeader('Earlier This Month')),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildRecentItem(
                title: 'Doja Cat',
                subtitle: 'Artist',
                image: 'https://picsum.photos/200?random=12',
                time: '2 weeks ago',
                type: 'artist',
              ),
              _buildRecentItem(
                title: 'Planet Her',
                subtitle: 'Doja Cat • Planet Her',
                image: 'https://picsum.photos/200?random=13',
                time: '2 weeks ago',
                type: 'album',
                duration: '44m',
              ),
              _buildRecentItem(
                title: 'Kiss Me More (feat. SZA)',
                subtitle: 'Doja Cat • Planet Her',
                image: 'https://picsum.photos/200?random=14',
                time: '2 weeks ago',
                type: 'song',
                duration: '3:28',
              ),
              _buildRecentItem(
                title: 'Road Trip Jams',
                subtitle: 'Playlist • 45 songs',
                image: 'https://picsum.photos/200?random=15',
                time: '3 weeks ago',
                type: 'playlist',
                duration: '2h 50m',
              ),
            ]),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      // Mini player placeholder
      bottomNavigationBar: Container(
        height: 60,
        color: const Color(0xFF1A1A1A),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/200?random=1'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Blinding Lights',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'The Weeknd',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.pause, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildRecentItem({
    required String title,
    required String subtitle,
    required String image,
    required String time,
    required String type,
    String? duration,
  }) {
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(type == 'artist' ? 28 : 8),
                image: DecorationImage(
                  image: NetworkImage(image),
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
          title,
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
              subtitle,
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
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (duration != null) ...[
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
                    duration,
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

  WavePainter(this.animationValue, this.color1, this.color2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [color1.withOpacity(0.3), color2.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.1;
    final waveLength = size.width * 0.5;
    final waveOffset = size.height * 0.7;

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
    final path2 = Path();
    final waveHeight2 = size.height * 0.05;
    final waveLength2 = size.width * 0.7;
    final waveOffset2 = size.height * 0.8;

    path2.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveOffset2 +
          waveHeight2 *
              math.sin((x / waveLength2 * 2 * math.pi) + animationValue * 1.5);
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    final paint2 =
        Paint()
          ..shader = LinearGradient(
            colors: [color2.withOpacity(0.2), color1.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
