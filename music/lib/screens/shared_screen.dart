import 'dart:math' as math;

import 'package:flutter/material.dart';

class SharedScreen extends StatefulWidget {
  const SharedScreen({super.key});

  @override
  State<SharedScreen> createState() => _SharedScreenState();
}

class _SharedScreenState extends State<SharedScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late TabController _tabController;
  String _selectedFilter = 'All';

  // Sample data for shared content
  final List<Map<String, dynamic>> _sharedWithYou = [
    {
      'type': 'song',
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'sharedBy': 'Sarah Johnson',
      'sharedByAvatar': 'https://randomuser.me/api/portraits/women/1.jpg',
      'time': '2 hours ago',
      'cover': 'https://picsum.photos/200?random=1',
      'message': 'This song is amazing! 🎵',
      'likes': 12,
      'comments': 3,
      'isLiked': false,
    },
    {
      'type': 'playlist',
      'title': 'Summer Vibes 2024',
      'creator': 'Mike Chen',
      'sharedBy': 'Alex Thompson',
      'sharedByAvatar': 'https://randomuser.me/api/portraits/men/2.jpg',
      'time': '5 hours ago',
      'cover': 'https://picsum.photos/200?random=2',
      'trackCount': 25,
      'message': 'Perfect for the beach! 🏖️',
      'likes': 8,
      'comments': 2,
      'isLiked': true,
    },
    {
      'type': 'album',
      'title': 'Future Nostalgia',
      'artist': 'Dua Lipa',
      'sharedBy': 'Emma Wilson',
      'sharedByAvatar': 'https://randomuser.me/api/portraits/women/3.jpg',
      'time': '1 day ago',
      'cover': 'https://picsum.photos/200?random=3',
      'year': '2020',
      'message': 'Still can\'t get over this album!',
      'likes': 24,
      'comments': 5,
      'isLiked': false,
    },
    {
      'type': 'artist',
      'name': 'Billie Eilish',
      'sharedBy': 'David Lee',
      'sharedByAvatar': 'https://randomuser.me/api/portraits/men/4.jpg',
      'time': '2 days ago',
      'cover': 'https://picsum.photos/200?random=4',
      'followers': '89.2M',
      'message': 'Her new tour is incredible!',
      'likes': 15,
      'comments': 7,
      'isLiked': true,
    },
    {
      'type': 'song',
      'title': 'Flowers',
      'artist': 'Miley Cyrus',
      'sharedBy': 'Lisa Park',
      'sharedByAvatar': 'https://randomuser.me/api/portraits/women/5.jpg',
      'time': '3 days ago',
      'cover': 'https://picsum.photos/200?random=5',
      'message': 'Can\'t stop listening to this!',
      'likes': 32,
      'comments': 8,
      'isLiked': false,
    },
  ];

  final List<Map<String, dynamic>> _yourShares = [
    {
      'type': 'playlist',
      'title': 'Workout Mix',
      'creator': 'You',
      'sharedWith': '5 friends',
      'time': '1 hour ago',
      'cover': 'https://picsum.photos/200?random=6',
      'trackCount': 30,
      'message': 'My go-to gym playlist 💪',
      'likes': 6,
      'comments': 2,
      'reshares': 1,
    },
    {
      'type': 'song',
      'title': 'Anti-Hero',
      'artist': 'Taylor Swift',
      'sharedWith': 'Sarah Johnson',
      'time': '6 hours ago',
      'cover': 'https://picsum.photos/200?random=7',
      'message': 'This speaks to me',
      'likes': 3,
      'comments': 1,
      'reshares': 0,
    },
    {
      'type': 'album',
      'title': 'Midnights',
      'artist': 'Taylor Swift',
      'sharedWith': '12 friends',
      'time': '1 day ago',
      'cover': 'https://picsum.photos/200?random=8',
      'year': '2022',
      'message': 'Album of the year! 🌙',
      'likes': 18,
      'comments': 4,
      'reshares': 3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredContent(
    List<Map<String, dynamic>> content,
  ) {
    if (_selectedFilter == 'All') return content;
    return content.where((item) {
      switch (_selectedFilter) {
        case 'Songs':
          return item['type'] == 'song';
        case 'Playlists':
          return item['type'] == 'playlist';
        case 'Albums':
          return item['type'] == 'album';
        case 'Artists':
          return item['type'] == 'artist';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1A1A1A),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Shared',
                  style: TextStyle(
                    color: Colors.white.withOpacity(
                      innerBoxIsScrolled ? 1.0 : 0.0,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  children: [
                    // Animated Wave Background
                    Positioned.fill(
                      child: Container(
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
                        child: AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: SharedWavePainter(_waveAnimation.value),
                            );
                          },
                        ),
                      ),
                    ),
                    // Content
                    const Positioned(
                      left: 20,
                      right: 20,
                      bottom: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.share, color: Colors.white, size: 32),
                              SizedBox(width: 12),
                              Text(
                                'Shared',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Music shared with you and by you',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: const Color(0xFF1A1A1A),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF6366F1),
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Shared with You'),
                      Tab(text: 'Your Shares'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Filter chips
            Container(
              height: 50,
              color: const Color(0xFF0A0A0A),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Songs'),
                  _buildFilterChip('Playlists'),
                  _buildFilterChip('Albums'),
                  _buildFilterChip('Artists'),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Shared with You tab
                  _buildSharedWithYouTab(),
                  // Your Shares tab
                  _buildYourSharesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Mini player
 
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: const Color(0xFF1A1A1A),
        selectedColor: const Color(0xFF6366F1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color:
              isSelected
                  ? const Color(0xFF6366F1)
                  : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSharedWithYouTab() {
    final filteredContent = _getFilteredContent(_sharedWithYou);

    if (filteredContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.share_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_selectedFilter.toLowerCase()} shared with you',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredContent.length,
      itemBuilder: (context, index) {
        final item = filteredContent[index];
        return _buildSharedItem(item, true);
      },
    );
  }

  Widget _buildYourSharesTab() {
    final filteredContent = _getFilteredContent(_yourShares);

    if (filteredContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.share_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'You haven\'t shared any ${_selectedFilter.toLowerCase()} yet',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Share Something'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredContent.length,
      itemBuilder: (context, index) {
        final item = filteredContent[index];
        return _buildSharedItem(item, false);
      },
    );
  }

  Widget _buildSharedItem(Map<String, dynamic> item, bool isSharedWithYou) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with sharer info
          if (isSharedWithYou)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(item['sharedByAvatar']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['sharedBy'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item['time'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

          // Content based on type
          _buildContentByType(item),

          // Message if exists
          if (item['message'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                item['message'],
                style: const TextStyle(color: Colors.white),
              ),
            ),

          // Interaction buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildInteractionButton(
                  icon:
                      item['isLiked'] == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                  label: '${item['likes']}',
                  color: item['isLiked'] == true ? Colors.red : Colors.grey,
                  onTap: () {
                    setState(() {
                      item['isLiked'] = !(item['isLiked'] ?? false);
                      if (item['isLiked']) {
                        item['likes']++;
                      } else {
                        item['likes']--;
                      }
                    });
                  },
                ),
                const SizedBox(width: 24),
                _buildInteractionButton(
                  icon: Icons.comment_outlined,
                  label: '${item['comments']}',
                  color: Colors.grey,
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                _buildInteractionButton(
                  icon: Icons.share_outlined,
                  label: isSharedWithYou ? 'Share' : '${item['reshares'] ?? 0}',
                  color: Colors.grey,
                  onTap: () {},
                ),
                const Spacer(),
                if (!isSharedWithYou)
                  Text(
                    'Shared with ${item['sharedWith']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentByType(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'song':
        return ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item['cover']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            item['title'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            item['artist'],
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.play_circle_filled,
              color: Color(0xFF6366F1),
              size: 40,
            ),
            onPressed: () {},
          ),
        );

      case 'playlist':
        return ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item['cover']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            item['title'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${item['trackCount']} tracks • by ${item['creator']}',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.play_circle_filled,
              color: Color(0xFF6366F1),
              size: 40,
            ),
            onPressed: () {},
          ),
        );

      case 'album':
        return ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item['cover']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            item['title'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${item['artist']} • ${item['year']}',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.play_circle_filled,
              color: Color(0xFF6366F1),
              size: 40,
            ),
            onPressed: () {},
          ),
        );

      case 'artist':
        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(item['cover']),
          ),
          title: Text(
            item['name'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${item['followers']} followers',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
              side: const BorderSide(color: Color(0xFF6366F1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Follow'),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}

class SharedWavePainter extends CustomPainter {
  final double animationValue;

  SharedWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2.5;

    for (int i = 0; i < 3; i++) {
      path.reset();
      final yOffset = size.height * 0.3 + (i * 30);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            yOffset +
            waveHeight *
                math.sin(
                  (x / waveLength * 2 * math.pi) + animationValue + (i * 0.5),
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
