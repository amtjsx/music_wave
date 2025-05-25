import 'dart:math' as math;

import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);
  }

  void _onScroll() {
    final showSearchBar = _scrollController.offset > 180;
    if (showSearchBar != _showSearchBar) {
      setState(() {
        _showSearchBar = showSearchBar;
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
          // App Bar with animated wave background
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor:
                _showSearchBar ? const Color(0xFF1A1A1A) : Colors.transparent,
            elevation: 0,
            title:
                _showSearchBar
                    ? const Text(
                      'Explore',
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
                  // Navigate to search screen
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Show notifications
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
                        painter: ExploreBgPainter(_waveAnimation.value),
                        child: Container(),
                      );
                    },
                  ),

                  // Content overlay
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explore',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Discover new music, artists, and playlists',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        // Search bar
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search artists, songs, or podcasts',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onTap: () {
                              // Navigate to search screen
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildQuickCategory(
                      'New Releases',
                      Icons.new_releases,
                      const Color(0xFF6366F1),
                    ),
                    _buildQuickCategory(
                      'Charts',
                      Icons.bar_chart,
                      const Color(0xFFEC4899),
                    ),
                    _buildQuickCategory(
                      'Podcasts',
                      Icons.mic,
                      const Color(0xFF8B5CF6),
                    ),
                    _buildQuickCategory(
                      'Live Events',
                      Icons.event,
                      const Color(0xFF1DB954),
                    ),
                    _buildQuickCategory(
                      'Made For You',
                      Icons.favorite,
                      const Color(0xFFFF5252),
                    ),
                    _buildQuickCategory(
                      'Genres',
                      Icons.category,
                      const Color(0xFFFFA500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Featured Playlists
          SliverToBoxAdapter(child: _buildSectionHeader('Featured Playlists')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFeaturedItem(
                    'Today\'s Top Hits',
                    'The hottest tracks right now',
                    'https://picsum.photos/400?random=20',
                    isPlaylist: true,
                  ),
                  _buildFeaturedItem(
                    'Chill Vibes',
                    'Relax and unwind with these smooth tracks',
                    'https://picsum.photos/400?random=21',
                    isPlaylist: true,
                  ),
                  _buildFeaturedItem(
                    'Workout Motivation',
                    'Energy-boosting tracks for your workout',
                    'https://picsum.photos/400?random=22',
                    isPlaylist: true,
                  ),
                  _buildFeaturedItem(
                    'Indie Discoveries',
                    'Fresh indie tracks you need to hear',
                    'https://picsum.photos/400?random=23',
                    isPlaylist: true,
                  ),
                ],
              ),
            ),
          ),

          // New Releases
          SliverToBoxAdapter(child: _buildSectionHeader('New Releases')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 210,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildNewReleaseItem(
                    'Future Nostalgia',
                    'Dua Lipa',
                    'https://picsum.photos/300?random=30',
                  ),
                  _buildNewReleaseItem(
                    'Planet Her',
                    'Doja Cat',
                    'https://picsum.photos/300?random=31',
                  ),
                  _buildNewReleaseItem(
                    'Harry\'s House',
                    'Harry Styles',
                    'https://picsum.photos/300?random=32',
                  ),
                  _buildNewReleaseItem(
                    'Happier Than Ever',
                    'Billie Eilish',
                    'https://picsum.photos/300?random=33',
                  ),
                  _buildNewReleaseItem(
                    'Dawn FM',
                    'The Weeknd',
                    'https://picsum.photos/300?random=34',
                  ),
                ],
              ),
            ),
          ),

          // Mood Playlists
          SliverToBoxAdapter(child: _buildSectionHeader('Browse by Mood')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMoodItem(
                    'Happy',
                    'https://picsum.photos/300?random=40',
                    const Color(0xFFFFC107),
                  ),
                  _buildMoodItem(
                    'Chill',
                    'https://picsum.photos/300?random=41',
                    const Color(0xFF4ECDC4),
                  ),
                  _buildMoodItem(
                    'Energetic',
                    'https://picsum.photos/300?random=42',
                    const Color(0xFFFF5252),
                  ),
                  _buildMoodItem(
                    'Focus',
                    'https://picsum.photos/300?random=43',
                    const Color(0xFF6366F1),
                  ),
                  _buildMoodItem(
                    'Romantic',
                    'https://picsum.photos/300?random=44',
                    const Color(0xFFEC4899),
                  ),
                  _buildMoodItem(
                    'Melancholy',
                    'https://picsum.photos/300?random=45',
                    const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
          ),

          // Charts
          SliverToBoxAdapter(child: _buildSectionHeader('Charts')),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildChartItem(
                    1,
                    'Blinding Lights',
                    'The Weeknd',
                    'https://picsum.photos/100?random=50',
                    isUp: true,
                    changeAmount: 2,
                  ),
                  _buildChartItem(
                    2,
                    'As It Was',
                    'Harry Styles',
                    'https://picsum.photos/100?random=51',
                    isUp: true,
                    changeAmount: 1,
                  ),
                  _buildChartItem(
                    3,
                    'Stay',
                    'The Kid LAROI, Justin Bieber',
                    'https://picsum.photos/100?random=52',
                    isUp: false,
                    changeAmount: 1,
                  ),
                  _buildChartItem(
                    4,
                    'Heat Waves',
                    'Glass Animals',
                    'https://picsum.photos/100?random=53',
                    isUp: true,
                    changeAmount: 3,
                  ),
                  _buildChartItem(
                    5,
                    'Woman',
                    'Doja Cat',
                    'https://picsum.photos/100?random=54',
                    isNew: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('View Full Charts'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Genres
          SliverToBoxAdapter(child: _buildSectionHeader('Genres')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGenreItem(
                    'Pop',
                    'https://picsum.photos/300?random=60',
                    const Color(0xFFFF5252),
                  ),
                  _buildGenreItem(
                    'Hip Hop',
                    'https://picsum.photos/300?random=61',
                    const Color(0xFF6366F1),
                  ),
                  _buildGenreItem(
                    'Rock',
                    'https://picsum.photos/300?random=62',
                    const Color(0xFFFFA500),
                  ),
                  _buildGenreItem(
                    'R&B',
                    'https://picsum.photos/300?random=63',
                    const Color(0xFF8B5CF6),
                  ),
                  _buildGenreItem(
                    'Electronic',
                    'https://picsum.photos/300?random=64',
                    const Color(0xFF4ECDC4),
                  ),
                  _buildGenreItem(
                    'Jazz',
                    'https://picsum.photos/300?random=65',
                    const Color(0xFFEC4899),
                  ),
                ],
              ),
            ),
          ),

          // Artist Spotlight
          SliverToBoxAdapter(child: _buildSectionHeader('Artist Spotlight')),
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://picsum.photos/800?random=70'),
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
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ARTIST SPOTLIGHT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Dua Lipa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'With her new album "Future Nostalgia", Dua Lipa has established herself as one of pop\'s biggest stars.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Listen Now'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Follow'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Podcasts
          SliverToBoxAdapter(child: _buildSectionHeader('Popular Podcasts')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 210,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildPodcastItem(
                    'The Joe Rogan Experience',
                    'Joe Rogan',
                    'https://picsum.photos/300?random=80',
                  ),
                  _buildPodcastItem(
                    'Crime Junkie',
                    'Ashley Flowers',
                    'https://picsum.photos/300?random=81',
                  ),
                  _buildPodcastItem(
                    'Call Her Daddy',
                    'Alex Cooper',
                    'https://picsum.photos/300?random=82',
                  ),
                  _buildPodcastItem(
                    'Armchair Expert',
                    'Dax Shepard',
                    'https://picsum.photos/300?random=83',
                  ),
                  _buildPodcastItem(
                    'My Favorite Murder',
                    'Karen Kilgariff & Georgia Hardstark',
                    'https://picsum.photos/300?random=84',
                  ),
                ],
              ),
            ),
          ),

          // Made For You
          SliverToBoxAdapter(child: _buildSectionHeader('Made For You')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildPersonalizedItem(
                    'Daily Mix 1',
                    'Based on your recent listening',
                    'https://picsum.photos/300?random=90',
                    const Color(0xFF6366F1),
                  ),
                  _buildPersonalizedItem(
                    'Discover Weekly',
                    'Your weekly mixtape of fresh music',
                    'https://picsum.photos/300?random=91',
                    const Color(0xFF1DB954),
                  ),
                  _buildPersonalizedItem(
                    'Release Radar',
                    'New releases from artists you follow',
                    'https://picsum.photos/300?random=92',
                    const Color(0xFFEC4899),
                  ),
                  _buildPersonalizedItem(
                    'Time Capsule',
                    'Songs from your past that you love',
                    'https://picsum.photos/300?random=93',
                    const Color(0xFFFFA500),
                  ),
                ],
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
       
 
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'See All',
              style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategory(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedItem(
    String title,
    String description,
    String image, {
    bool isPlaylist = false,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
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
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                if (isPlaylist)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PLAYLIST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
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
                    const SizedBox(width: 12),
                    const Text(
                      'Play Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

  Widget _buildNewReleaseItem(String title, String artist, String image) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
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
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            artist,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodItem(String mood, String image, Color color) {
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
                image: NetworkImage(image),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  color.withOpacity(0.3),
                  BlendMode.overlay,
                ),
              ),
              border: Border.all(color: color, width: 3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mood,
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
  }

  Widget _buildChartItem(
    int position,
    String title,
    String artist,
    String image, {
    bool isUp = false,
    bool isNew = false,
    int changeAmount = 0,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            position.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage(image),
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Row(
              children: [
                Icon(
                  isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isUp ? const Color(0xFF1DB954) : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  changeAmount.toString(),
                  style: TextStyle(
                    color: isUp ? const Color(0xFF1DB954) : Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGenreItem(String genre, String image, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            color.withOpacity(0.3),
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
                colors: [Colors.transparent, color.withOpacity(0.7)],
              ),
            ),
          ),

          // Content
          Center(
            child: Text(
              genre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastItem(String title, String host, String image) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PODCAST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
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
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            host,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedItem(
    String title,
    String description,
    String image,
    Color color,
  ) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
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
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreBgPainter extends CustomPainter {
  final double animationValue;

  ExploreBgPainter(this.animationValue);

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

    // Draw waves
    final wavePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // First wave
    final path1 = Path();
    final waveHeight1 = size.height * 0.05;
    final waveLength1 = size.width * 0.8;
    final waveOffset1 = size.height * 0.3;

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
    final waveLength2 = size.width * 0.6;
    final waveOffset2 = size.height * 0.4;

    path2.moveTo(0, waveOffset2);
    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveOffset2 +
          waveHeight2 *
              math.sin((x / waveLength2 * 2 * math.pi) + animationValue * 1.5);
      path2.lineTo(x, y);
    }

    canvas.drawPath(path2, wavePaint);

    // Third wave
    final path3 = Path();
    final waveHeight3 = size.height * 0.04;
    final waveLength3 = size.width * 0.7;
    final waveOffset3 = size.height * 0.5;

    path3.moveTo(0, waveOffset3);
    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveOffset3 +
          waveHeight3 *
              math.sin((x / waveLength3 * 2 * math.pi) + animationValue * 0.8);
      path3.lineTo(x, y);
    }

    canvas.drawPath(path3, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
