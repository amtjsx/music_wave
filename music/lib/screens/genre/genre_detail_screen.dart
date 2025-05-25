import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GenreDetailScreen extends StatefulWidget {
  final String genreName;

  const GenreDetailScreen({super.key, required this.genreName});

  @override
  State<GenreDetailScreen> createState() => _GenreDetailScreenState();
}

class _GenreDetailScreenState extends State<GenreDetailScreen>
    with TickerProviderStateMixin {
  Color genreColor = Colors.red;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;
  bool _isFollowing = false;

  // In a real app, this would come from a backend based on the genre
  late List<Map<String, dynamic>> _artists;
  late List<Map<String, dynamic>> _playlists;
  late List<Map<String, dynamic>> _tracks;
  late List<Map<String, dynamic>> _relatedGenres;

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

    // Initialize mock data
    _initializeData();
  }

  void _initializeData() {
    // Generate artists for this genre
    _artists = List.generate(
      8,
      (index) => {
        'name': _getArtistName(widget.genreName, index),
        'imageUrl': 'https://picsum.photos/200?random=${100 + index}',
        'followers': '${(math.Random().nextInt(900) + 100)}K',
      },
    );

    // Generate playlists for this genre
    _playlists = List.generate(
      6,
      (index) => {
        'name': _getPlaylistName(widget.genreName, index),
        'imageUrl': 'https://picsum.photos/200?random=${200 + index}',
        'tracks': '${math.Random().nextInt(100) + 20} tracks',
        'curator': index < 3 ? 'Music Wave' : 'User Curated',
      },
    );

    // Generate tracks for this genre
    _tracks = List.generate(
      10,
      (index) => {
        'title': _getTrackName(widget.genreName, index),
        'artist': _getArtistName(widget.genreName, index % 8),
        'imageUrl': 'https://picsum.photos/200?random=${300 + index}',
        'duration':
            '${2 + math.Random().nextInt(3)}:${10 + math.Random().nextInt(50)}',
        'plays': '${math.Random().nextInt(900) + 100}K',
      },
    );

    // Generate related genres
    _relatedGenres = List.generate(
      4,
      (index) => {
        'name': _getRelatedGenre(widget.genreName, index),
        'color': _getRelatedGenreColor(index),
        'imageUrl': 'https://picsum.photos/200?random=${400 + index}',
      },
    );
  }

  String _getArtistName(String genre, int index) {
    final popArtists = [
      'Taylor Swift',
      'Ed Sheeran',
      'Ariana Grande',
      'Justin Bieber',
      'Dua Lipa',
      'The Weeknd',
      'Billie Eilish',
      'Post Malone',
    ];

    final rockArtists = [
      'Foo Fighters',
      'Arctic Monkeys',
      'Imagine Dragons',
      'Twenty One Pilots',
      'The Killers',
      'Coldplay',
      'Muse',
      'Green Day',
    ];

    final hipHopArtists = [
      'Drake',
      'Kendrick Lamar',
      'Travis Scott',
      'J. Cole',
      'Cardi B',
      'Megan Thee Stallion',
      'Lil Nas X',
      'DaBaby',
    ];

    final electronicArtists = [
      'Calvin Harris',
      'Marshmello',
      'Martin Garrix',
      'Zedd',
      'David Guetta',
      'Kygo',
      'Skrillex',
      'Daft Punk',
    ];

    final jazzArtists = [
      'Kamasi Washington',
      'Robert Glasper',
      'Norah Jones',
      'Gregory Porter',
      'Esperanza Spalding',
      'Trombone Shorty',
      'Snarky Puppy',
      'GoGo Penguin',
    ];

    final defaultArtists = [
      'Artist One',
      'Artist Two',
      'Artist Three',
      'Artist Four',
      'Artist Five',
      'Artist Six',
      'Artist Seven',
      'Artist Eight',
    ];

    switch (genre.toLowerCase()) {
      case 'pop':
        return popArtists[index];
      case 'rock':
        return rockArtists[index];
      case 'hip hop':
        return hipHopArtists[index];
      case 'electronic':
        return electronicArtists[index];
      case 'jazz':
        return jazzArtists[index];
      default:
        return defaultArtists[index];
    }
  }

  String _getPlaylistName(String genre, int index) {
    final prefixes = [
      'Best of',
      'Top',
      'Essential',
      'Ultimate',
      'Classic',
      'Modern',
    ];

    final suffixes = [
      'Hits',
      'Classics',
      'Anthems',
      'Vibes',
      'Mix',
      'Collection',
    ];

    if (index < 3) {
      return '${prefixes[index % prefixes.length]} $genre ${suffixes[index % suffixes.length]}';
    } else {
      return '$genre ${suffixes[index % suffixes.length]} Vol. ${index - 2}';
    }
  }

  String _getTrackName(String genre, int index) {
    final popTracks = [
      'Summer Feeling',
      'Heartbreak Anthem',
      'Dancing in the Dark',
      'Midnight Love',
      'Electric Dreams',
      'Sweet Escape',
      'Golden Hour',
      'Neon Lights',
      'Crystal Skies',
      'Euphoria',
    ];

    final rockTracks = [
      'Rebel Heart',
      'Thunder Road',
      'Electric Soul',
      'Breaking Free',
      'Midnight Run',
      'Wildfire',
      'Stone Cold',
      'Revolution',
      'Echoes of Yesterday',
      'Rising Phoenix',
    ];

    final hipHopTracks = [
      'City Lights',
      'Hustle Hard',
      'Street Dreams',
      'Flow State',
      'Money Moves',
      'Rhythm & Flow',
      'Beat Drop',
      'Mic Check',
      'Concrete Jungle',
      'Bars of Steel',
    ];

    final electronicTracks = [
      'Digital Love',
      'Neon Dreams',
      'Pulse',
      'Synthwave',
      'Electric Feel',
      'Bass Drop',
      'Midnight Drive',
      'Cyber Punk',
      'Future Nostalgia',
      'Techno Heart',
    ];

    final jazzTracks = [
      'Blue Note',
      'Midnight Session',
      'Smooth Sax',
      'Piano Dreams',
      'Trumpet Soul',
      'Bass Walk',
      'Rhythm Section',
      'Jazz Club',
      'Improvisation',
      'Night in Paris',
    ];

    final defaultTracks = [
      'Track One',
      'Track Two',
      'Track Three',
      'Track Four',
      'Track Five',
      'Track Six',
      'Track Seven',
      'Track Eight',
      'Track Nine',
      'Track Ten',
    ];

    switch (genre.toLowerCase()) {
      case 'pop':
        return popTracks[index];
      case 'rock':
        return rockTracks[index];
      case 'hip hop':
        return hipHopTracks[index];
      case 'electronic':
        return electronicTracks[index];
      case 'jazz':
        return jazzTracks[index];
      default:
        return defaultTracks[index];
    }
  }

  String _getRelatedGenre(String genre, int index) {
    final popRelated = ['Dance Pop', 'Synth Pop', 'Indie Pop', 'K-Pop'];
    final rockRelated = [
      'Alternative',
      'Indie Rock',
      'Hard Rock',
      'Classic Rock',
    ];
    final hipHopRelated = ['Trap', 'R&B', 'Rap', 'Drill'];
    final electronicRelated = ['House', 'Techno', 'EDM', 'Dubstep'];
    final jazzRelated = ['Blues', 'Soul', 'Funk', 'Bossa Nova'];
    final defaultRelated = ['Genre A', 'Genre B', 'Genre C', 'Genre D'];

    switch (genre.toLowerCase()) {
      case 'pop':
        return popRelated[index];
      case 'rock':
        return rockRelated[index];
      case 'hip hop':
        return hipHopRelated[index];
      case 'electronic':
        return electronicRelated[index];
      case 'jazz':
        return jazzRelated[index];
      default:
        return defaultRelated[index];
    }
  }

  Color _getRelatedGenreColor(int index) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFECA57),
      const Color(0xFFFF9FF3),
      const Color(0xFF6366F1),
      const Color(0xFFE91E63),
    ];

    return colors[index % colors.length];
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
          // App Bar with genre header
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
                    ? Text(
                      widget.genreName,
                      style: const TextStyle(
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
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Gradient background with genre color
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          genreColor,
                          genreColor.withValues(alpha: 0.7),
                          const Color(0xFF1A1A1A),
                        ],
                      ),
                    ),
                  ),

                  // Animated wave overlay
                  AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: GenreDetailWavePainter(
                          _waveAnimation.value,
                          genreColor,
                        ),
                        child: Container(),
                      );
                    },
                  ),

                  // Content overlay
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.genreName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${_artists.length} Artists • ${_playlists.length} Playlists',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isFollowing = !_isFollowing;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isFollowing ? Colors.white : genreColor,
                                foregroundColor:
                                    _isFollowing ? genreColor : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                _isFollowing ? 'Following' : 'Follow',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
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
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      'Play All',
                      Icons.play_arrow,
                      genreColor,
                      () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      'Shuffle',
                      Icons.shuffle,
                      const Color(0xFF1A1A1A),
                      () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Popular Artists Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Artists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(color: genreColor, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Artists Horizontal List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _artists.length,
                itemBuilder: (context, index) {
                  return _buildArtistCard(_artists[index]);
                },
              ),
            ),
          ),

          // Top Playlists Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Playlists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(color: genreColor, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Playlists Horizontal List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  return _buildPlaylistCard(_playlists[index]);
                },
              ),
            ),
          ),

          // Popular Tracks Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Tracks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(color: genreColor, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tracks List
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildTrackItem(_tracks[index], index + 1);
            }, childCount: math.min(5, _tracks.length)),
          ),

          // Related Genres Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Related Genres',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Related Genres Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildRelatedGenreCard(_relatedGenres[index]);
              }, childCount: _relatedGenres.length),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
       
 
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistCard(Map<String, dynamic> artist) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/artists/${artist['name'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Artist image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(artist['imageUrl']),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Artist name
            Text(
              artist['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Followers
            Text(
              artist['followers'],
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(Map<String, dynamic> playlist) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/playlist/${playlist['name'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist cover
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(playlist['imageUrl']),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Playlist name
            Text(
              playlist['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Playlist info
            Text(
              '${playlist['tracks']} • ${playlist['curator']}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackItem(Map<String, dynamic> track, int position) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Track position
          SizedBox(
            width: 24,
            child: Text(
              position.toString(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          // Track image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: NetworkImage(track['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        track['title'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            track['artist'],
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            track['plays'],
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track['duration'],
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.more_vert, color: Colors.grey, size: 20),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildRelatedGenreCard(Map<String, dynamic> genre) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/genre/${genre['name'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: genre['color'],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            genre['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class GenreDetailWavePainter extends CustomPainter {
  final double animationValue;
  final Color genreColor;

  GenreDetailWavePainter(this.animationValue, this.genreColor);

  @override
  void paint(Canvas canvas, Size size) {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
