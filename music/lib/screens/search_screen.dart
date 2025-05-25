import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _recentSearches = [
    'Dua Lipa',
    'The Weeknd',
    'Billie Eilish',
    'Kendrick Lamar',
  ];

  List<Map<String, dynamic>> _searchResults = [];

  // Add this new list for search suggestions
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _showSuggestions = false;
        _searchSuggestions = [];
      });
      return;
    }

    // Generate search suggestions as user types
    setState(() {
      _showSuggestions = true;

      // Generate suggestions based on query
      if (query.length > 1) {
        _searchSuggestions = _generateSuggestions(query);
      } else {
        _searchSuggestions = [];
      }

      // Only perform full search if query is complete
      if (query.length > 2) {
        _isSearching = true;

        // Add to recent searches if not already there
        if (!_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        }

        // Mock search results
        _searchResults = [
          // Songs
          {
            'type': 'song',
            'title': '$query Nights',
            'artist': 'The Weeknd',
            'imageUrl': 'https://picsum.photos/200?random=1',
          },
          {
            'type': 'song',
            'title': 'Dancing with $query',
            'artist': 'Dua Lipa',
            'imageUrl': 'https://picsum.photos/200?random=2',
          },

          // Artists
          {
            'type': 'artist',
            'name': '$query Brothers',
            'followers': '2.3M followers',
            'imageUrl': 'https://picsum.photos/200?random=3',
          },

          // Albums
          {
            'type': 'album',
            'title': 'The $query Experience',
            'artist': 'Kendrick Lamar',
            'imageUrl': 'https://picsum.photos/200?random=4',
          },

          // Playlists
          {
            'type': 'playlist',
            'title': '$query Vibes',
            'songs': '24 songs',
            'imageUrl': 'https://picsum.photos/200?random=5',
          },
        ];
      } else {
        _isSearching = false;
        _searchResults = [];
      }
    });
  }

  List<String> _generateSuggestions(String query) {
    // This would typically come from an API or local database
    // For this example, we'll generate mock suggestions
    final allPossibleSuggestions = [
      'Dua Lipa',
      'Drake',
      'Daft Punk',
      'David Guetta',
      'David Bowie',
      'Disclosure',
      'Diplo',
      'Dire Straits',
      'The Weeknd',
      'Taylor Swift',
      'Travis Scott',
      'Twenty One Pilots',
      'Tame Impala',
      'Billie Eilish',
      'Bruno Mars',
      'Bad Bunny',
      'Beyoncé',
      'Kendrick Lamar',
      'Kanye West',
      'Kygo',
      'Katy Perry',
      'Khalid',
    ];

    // Filter suggestions based on query
    return allPossibleSuggestions
        .where(
          (suggestion) =>
              suggestion.toLowerCase().contains(query.toLowerCase()),
        )
        .take(5) // Limit to 5 suggestions
        .toList();
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    _performSearch(suggestion);
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 4.0,
                  right: 16.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search songs, artists, albums...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _performSearch('');
                                      },
                                    )
                                    : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                          onChanged: _performSearch,
                          onSubmitted: (query) {
                            _performSearch(query);
                            setState(() {
                              _showSuggestions = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Suggestions
            if (_showSuggestions && _searchSuggestions.isNotEmpty)
              Container(
                color: const Color(0xFF0A0A0A),
                child: Column(
                  children: [
                    const Divider(color: Color(0xFF1A1A1A), height: 1),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          title: Text(
                            _searchSuggestions[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap:
                              () =>
                                  _selectSuggestion(_searchSuggestions[index]),
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -2),
                        );
                      },
                    ),
                    const Divider(color: Color(0xFF1A1A1A), height: 1),
                  ],
                ),
              ),

            // Main Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Content based on search state
                  if (!_isSearching && _searchResults.isEmpty) ...[
                    // Recent Searches
                    if (_recentSearches.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Searches',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _recentSearches = [];
                                  });
                                },
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return ListTile(
                            leading: const Icon(
                              Icons.history,
                              color: Colors.grey,
                            ),
                            title: Text(
                              _recentSearches[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 16,
                              ),
                              onPressed: () {
                                setState(() {
                                  _recentSearches.removeAt(index);
                                });
                              },
                            ),
                            onTap: () {
                              _searchController.text = _recentSearches[index];
                              _performSearch(_recentSearches[index]);
                            },
                          );
                        }, childCount: _recentSearches.length),
                      ),
                    ],

                    // Browse Categories
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Row(
                          children: [
                            const Text(
                              'Browse All',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.5,
                              ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            final categories = [
                              'Top Charts',
                              'New Releases',
                              'Podcasts',
                              'Made For You',
                              'Live Events',
                              'Mood & Genres',
                            ];
                            final colors = [
                              const Color(0xFFFF6B6B),
                              const Color(0xFF4ECDC4),
                              const Color(0xFF45B7D1),
                              const Color(0xFF96CEB4),
                              const Color(0xFFFECA57),
                              const Color(0xFFFF9FF3),
                            ];
                            final icons = [
                              Icons.trending_up,
                              Icons.new_releases,
                              Icons.mic,
                              Icons.favorite,
                              Icons.event,
                              Icons.music_note,
                            ];
                            return _buildCategoryCard(
                              categories[index],
                              colors[index],
                              icons[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ] else if (_searchResults.isNotEmpty) ...[
                    // Search Results
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Search Results',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final result = _searchResults[index];

                        // Different UI based on result type
                        switch (result['type']) {
                          case 'song':
                            return _buildSongResultTile(result);
                          case 'artist':
                            return _buildArtistResultTile(result);
                          case 'album':
                            return _buildAlbumResultTile(result);
                          case 'playlist':
                            return _buildPlaylistResultTile(result);
                          default:
                            return const SizedBox.shrink();
                        }
                      }, childCount: _searchResults.length),
                    ),
                  ] else ...[
                    // Searching but no results
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found for "${_searchController.text}"',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try searching for something else',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Navigate to category
        context.push('/category/${title.toLowerCase().replaceAll(' ', '-')}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongResultTile(Map<String, dynamic> song) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(song['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(song['title'], style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        song['artist'],
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {},
      ),
      onTap: () {
        context.push(
          '/songs/${song['title'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
    );
  }

  Widget _buildArtistResultTile(Map<String, dynamic> artist) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(artist['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(artist['name'], style: const TextStyle(color: Colors.white)),
      subtitle: Row(
        children: [
          const Icon(Icons.person, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(artist['followers'], style: const TextStyle(color: Colors.grey)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.person_add_outlined, color: Color(0xFF6366F1)),
        onPressed: () {},
      ),
      onTap: () {
        context.push(
          '/artists/${artist['name'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
    );
  }

  Widget _buildAlbumResultTile(Map<String, dynamic> album) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(album['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(album['title'], style: const TextStyle(color: Colors.white)),
      subtitle: Row(
        children: [
          const Icon(Icons.album, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(album['artist'], style: const TextStyle(color: Colors.grey)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {},
      ),
      onTap: () {
        context.push(
          '/albums/${album['title'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
    );
  }

  Widget _buildPlaylistResultTile(Map<String, dynamic> playlist) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(playlist['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        playlist['title'],
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Row(
        children: [
          const Icon(Icons.queue_music, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(playlist['songs'], style: const TextStyle(color: Colors.grey)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {},
      ),
      onTap: () {
        context.push(
          '/playlists/${playlist['title'].toLowerCase().replaceAll(' ', '-')}',
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final path = Path();
    final waveHeight = 15.0;
    final waveLength = size.width / 2;

    for (int i = 0; i < 3; i++) {
      path.reset();
      final yOffset = size.height * 0.3 + (i * 20);

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
