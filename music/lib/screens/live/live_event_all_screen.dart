import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiveEventsAllScreen extends StatefulWidget {
  const LiveEventsAllScreen({super.key});

  @override
  State<LiveEventsAllScreen> createState() => _LiveEventsAllScreenState();
}

class _LiveEventsAllScreenState extends State<LiveEventsAllScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _currentFilter = 'All';
  String _currentSort = 'Trending';

  final List<String> _filters = [
    'All',
    'Music',
    'Concerts',
    'Festivals',
    'DJ Sets',
    'Acoustic',
  ];
  final List<String> _sortOptions = [
    'Trending',
    'Most Viewers',
    'Recently Started',
    'Alphabetical',
  ];

  // Sample data for live events
  final List<Map<String, dynamic>> _liveEvents = [
    {
      'artist': 'Taylor Swift',
      'title': 'Eras Tour Live',
      'venue': 'Madison Square Garden',
      'viewers': 24750,
      'image': 'https://picsum.photos/400/300?random=101',
      'category': 'Concerts',
      'duration': '01:45:20',
    },
    {
      'artist': 'Ed Sheeran',
      'title': 'Mathematics Tour',
      'venue': 'Wembley Stadium',
      'viewers': 18320,
      'image': 'https://picsum.photos/400/300?random=102',
      'category': 'Concerts',
      'duration': '01:12:05',
    },
    {
      'artist': 'Billie Eilish',
      'title': 'Happier Than Ever Tour',
      'venue': 'Hollywood Bowl',
      'viewers': 15680,
      'image': 'https://picsum.photos/400/300?random=103',
      'category': 'Concerts',
      'duration': '00:58:30',
    },
    {
      'artist': 'The Weeknd',
      'title': 'After Hours Tour',
      'venue': 'Red Rocks',
      'viewers': 12450,
      'image': 'https://picsum.photos/400/300?random=104',
      'category': 'Concerts',
      'duration': '01:30:15',
    },
    {
      'artist': 'Dua Lipa',
      'title': 'Future Nostalgia Tour',
      'venue': 'O2 Arena',
      'viewers': 19870,
      'image': 'https://picsum.photos/400/300?random=105',
      'category': 'Concerts',
      'duration': '00:45:10',
    },
    {
      'artist': 'Calvin Harris',
      'title': 'Summer Festival Mix',
      'venue': 'Tomorrowland',
      'viewers': 32150,
      'image': 'https://picsum.photos/400/300?random=106',
      'category': 'DJ Sets',
      'duration': '02:15:40',
    },
    {
      'artist': 'Adele',
      'title': 'Intimate Acoustic Session',
      'venue': 'Royal Albert Hall',
      'viewers': 14320,
      'image': 'https://picsum.photos/400/300?random=107',
      'category': 'Acoustic',
      'duration': '01:05:25',
    },
    {
      'artist': 'BTS',
      'title': 'World Tour Live',
      'venue': 'Seoul Olympic Stadium',
      'viewers': 45780,
      'image': 'https://picsum.photos/400/300?random=108',
      'category': 'Concerts',
      'duration': '01:50:30',
    },
    {
      'artist': 'Coldplay',
      'title': 'Music of the Spheres Tour',
      'venue': 'Stade de France',
      'viewers': 22340,
      'image': 'https://picsum.photos/400/300?random=109',
      'category': 'Concerts',
      'duration': '01:25:15',
    },
    {
      'artist': 'Tiësto',
      'title': 'Club Life Session',
      'venue': 'Ibiza',
      'viewers': 28650,
      'image': 'https://picsum.photos/400/300?random=110',
      'category': 'DJ Sets',
      'duration': '01:40:50',
    },
    {
      'artist': 'John Mayer',
      'title': 'Acoustic Evening',
      'venue': 'The Troubadour',
      'viewers': 9870,
      'image': 'https://picsum.photos/400/300?random=111',
      'category': 'Acoustic',
      'duration': '00:55:20',
    },
    {
      'artist': 'Beyoncé',
      'title': 'Renaissance Tour',
      'venue': 'Coachella',
      'viewers': 38450,
      'image': 'https://picsum.photos/400/300?random=112',
      'category': 'Festivals',
      'duration': '02:05:10',
    },
  ];

  List<Map<String, dynamic>> get filteredEvents {
    if (_currentFilter == 'All') {
      return _liveEvents;
    } else {
      return _liveEvents
          .where((event) => event['category'] == _currentFilter)
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // App Bar with wave background
          SliverAppBar(
            expandedHeight: 150,
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
                onPressed: () {
                  context.push('/live-event-search');
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: _showSortOptions,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Live Events',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                children: [
                  // Animated wave background
                  AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: LiveWavePainter(_waveAnimation.value),
                        child: Container(),
                      );
                    },
                  ),

                  // Live indicator
                  Positioned(
                    left: 16,
                    bottom: 48,
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter tabs
          SliverToBoxAdapter(
            child: Container(
              height: 30,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
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

          // Stats bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredEvents.length} Live Events',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

          // Grid of live events
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final event = filteredEvents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildLiveEventCard(event),
                );
              }, childCount: filteredEvents.length),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildLiveEventCard(Map<String, dynamic> event) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image with Live Badge
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(event['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Live badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Viewer count
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatViewerCount(event['viewers']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Duration
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        event['duration'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
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
                  event['artist'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event['venue'],
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.7),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/live-event-detail/${event['id']}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(double.infinity, 30),
                        ),
                        child: const Text(
                          'Join',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatViewerCount(int count) {
    if (count >= 1000) {
      final thousands = count / 1000;
      return '${thousands.toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class LiveWavePainter extends CustomPainter {
  final double animationValue;

  LiveWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF5252), Color(0xFFEC4899), Color(0xFF8B5CF6)],
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
