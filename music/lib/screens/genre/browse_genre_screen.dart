import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BrowseGenreScreen extends StatefulWidget {
  const BrowseGenreScreen({super.key});

  @override
  State<BrowseGenreScreen> createState() => _BrowseGenreScreenState();
}

class _BrowseGenreScreenState extends State<BrowseGenreScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Popular',
    'Trending',
    'Moods',
    'Decades',
  ];

  // In a real app, this would come from a backend
  final List<Map<String, dynamic>> _genres = [
    {
      'name': 'Pop',
      'color': const Color(0xFFFF6B6B),
      'icon': Icons.music_note,
      'artists': '1.2K artists',
      'category': 'Popular',
      'imageUrl': 'https://picsum.photos/400/300?random=1',
    },
    {
      'name': 'Rock',
      'color': const Color(0xFF4ECDC4),
      'icon': Icons.music_note,
      'artists': '987 artists',
      'category': 'Popular',
      'imageUrl': 'https://picsum.photos/400/300?random=2',
    },
    {
      'name': 'Hip Hop',
      'color': const Color(0xFF45B7D1),
      'icon': Icons.mic,
      'artists': '1.5K artists',
      'category': 'Trending',
      'imageUrl': 'https://picsum.photos/400/300?random=3',
    },
    {
      'name': 'R&B',
      'color': const Color(0xFF96CEB4),
      'icon': Icons.headphones,
      'artists': '756 artists',
      'category': 'Popular',
      'imageUrl': 'https://picsum.photos/400/300?random=4',
    },
    {
      'name': 'Electronic',
      'color': const Color(0xFFFECA57),
      'icon': Icons.electric_bolt,
      'artists': '1.1K artists',
      'category': 'Trending',
      'imageUrl': 'https://picsum.photos/400/300?random=5',
    },
    {
      'name': 'Jazz',
      'color': const Color(0xFFFF9FF3),
      'icon': Icons.phone,
      'artists': '543 artists',
      'category': 'Moods',
      'imageUrl': 'https://picsum.photos/400/300?random=6',
    },
    {
      'name': 'Classical',
      'color': const Color(0xFF6366F1),
      'icon': Icons.piano,
      'artists': '432 artists',
      'category': 'Moods',
      'imageUrl': 'https://picsum.photos/400/300?random=7',
    },
    {
      'name': 'Country',
      'color': const Color(0xFFE91E63),
      'icon': Icons.agriculture,
      'artists': '678 artists',
      'category': 'Popular',
      'imageUrl': 'https://picsum.photos/400/300?random=8',
    },
    {
      'name': 'Reggae',
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.beach_access,
      'artists': '321 artists',
      'category': 'Moods',
      'imageUrl': 'https://picsum.photos/400/300?random=9',
    },
    {
      'name': 'Folk',
      'color': const Color(0xFF1DB954),
      'icon': Icons.nature_people,
      'artists': '456 artists',
      'category': 'Moods',
      'imageUrl': 'https://picsum.photos/400/300?random=10',
    },
    {
      'name': '80s',
      'color': const Color(0xFFFF5252),
      'icon': Icons.album,
      'artists': '789 artists',
      'category': 'Decades',
      'imageUrl': 'https://picsum.photos/400/300?random=11',
    },
    {
      'name': '90s',
      'color': const Color(0xFF9CA3AF),
      'icon': Icons.album,
      'artists': '876 artists',
      'category': 'Decades',
      'imageUrl': 'https://picsum.photos/400/300?random=12',
    },
    {
      'name': '2000s',
      'color': const Color(0xFFEC4899),
      'icon': Icons.album,
      'artists': '965 artists',
      'category': 'Decades',
      'imageUrl': 'https://picsum.photos/400/300?random=13',
    },
    {
      'name': 'Indie',
      'color': const Color(0xFF4ECDC4),
      'icon': Icons.record_voice_over,
      'artists': '543 artists',
      'category': 'Trending',
      'imageUrl': 'https://picsum.photos/400/300?random=14',
    },
    {
      'name': 'Metal',
      'color': const Color(0xFF1A1A1A),
      'icon': Icons.bolt,
      'artists': '432 artists',
      'category': 'Popular',
      'imageUrl': 'https://picsum.photos/400/300?random=15',
    },
    {
      'name': 'Blues',
      'color': const Color(0xFF45B7D1),
      'icon': Icons.music_note,
      'artists': '321 artists',
      'category': 'Moods',
      'imageUrl': 'https://picsum.photos/400/300?random=16',
    },
  ];

  List<Map<String, dynamic>> get _filteredGenres {
    if (_selectedCategory == 'All') {
      return _genres;
    } else {
      return _genres
          .where((genre) => genre['category'] == _selectedCategory)
          .toList();
    }
  }

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
    final showTitle = _scrollController.offset > 150;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with wave background
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor:
                _showAppBarTitle ? const Color(0xFF1A1A1A) : Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title:
                _showAppBarTitle
                    ? const Text(
                      'Browse Genres',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  context.push('/search');
                },
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
                        painter: GenreWavePainter(_waveAnimation.value),
                        child: Container(),
                      );
                    },
                  ),

                  // Content overlay
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Browse Genres',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Explore music by genre, mood, and era',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                        backgroundColor: const Color(0xFF1A1A1A),
                        selectedColor: const Color(0xFF6366F1),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Featured Genres
          if (_selectedCategory == 'All' || _selectedCategory == 'Popular')
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFECA57),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Featured Genres',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final featuredGenres =
                            _genres
                                .where(
                                  (genre) => genre['category'] == 'Popular',
                                )
                                .take(4)
                                .toList();
                        return _buildFeaturedGenreCard(featuredGenres[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),

          // All Genres Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildGenreCard(_filteredGenres[index]);
              }, childCount: _filteredGenres.length),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
       
 
    );
  }

  Widget _buildFeaturedGenreCard(Map<String, dynamic> genre) {
    return GestureDetector(
      onTap: () {
        context.push('/genre/${genre['name'].toLowerCase()}');
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(genre['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, genre['color'].withOpacity(0.8)],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(genre['icon'], color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    genre['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    genre['artists'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreCard(Map<String, dynamic> genre) {
    return GestureDetector(
      onTap: () {
        context.push('/genre/${genre['name'].toLowerCase()}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: genre['color'],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: genre['color'].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icon
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                genre['icon'],
                size: 100,
                color: Colors.white.withOpacity(0.2),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(genre['icon'], color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    genre['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    genre['artists'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenreWavePainter extends CustomPainter {
  final double animationValue;

  GenreWavePainter(this.animationValue);

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
          ..strokeWidth = 2;

    // First wave
    final path1 = Path();
    final waveHeight1 = size.height * 0.06;
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
    final waveHeight2 = size.height * 0.04;
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
    final waveHeight3 = size.height * 0.05;
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
