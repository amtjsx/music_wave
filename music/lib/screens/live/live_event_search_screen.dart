import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiveEventSearchScreen extends StatefulWidget {
  const LiveEventSearchScreen({super.key});

  @override
  State<LiveEventSearchScreen> createState() => _LiveEventSearchScreenState();
}

class _LiveEventSearchScreenState extends State<LiveEventSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedFilter = 'All';
  List<String> _filters = ['All', 'Live', 'Upcoming', 'Artists', 'Venues'];

  List<String> _recentSearches = [
    'Taylor Swift',
    'Live Jazz',
    'Coachella',
    'Madison Square Garden',
  ];

  List<Map<String, dynamic>> _searchResults = [];
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
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

        // Generate mock search results based on filter
        _searchResults = _generateSearchResults(query, _selectedFilter);
      } else {
        _isSearching = false;
        _searchResults = [];
      }
    });
  }

  List<String> _generateSuggestions(String query) {
    // This would typically come from an API or local database
    final allPossibleSuggestions = [
      'Taylor Swift',
      'Ed Sheeran',
      'Billie Eilish',
      'The Weeknd',
      'Dua Lipa',
      'Ariana Grande',
      'Drake',
      'Olivia Rodrigo',
      'Post Malone',
      'Doja Cat',
      'Harry Styles',
      'Kendrick Lamar',
      'SZA',
      'Madison Square Garden',
      'Wembley Stadium',
      'Hollywood Bowl',
      'Red Rocks',
      'O2 Arena',
      'Coachella',
      'Glastonbury',
      'Live Concert',
      'Music Festival',
      'Summer Tour',
      'Acoustic Session',
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

  List<Map<String, dynamic>> _generateSearchResults(
    String query,
    String filter,
  ) {
    List<Map<String, dynamic>> results = [];

    // Live Events
    if (filter == 'All' || filter == 'Live') {
      results.addAll([
        {
          'type': 'live',
          'title': '$query Live Concert',
          'artist': 'Taylor Swift',
          'venue': 'Madison Square Garden',
          'viewers': '15.4K',
          'imageUrl': 'https://picsum.photos/300?random=1',
        },
        {
          'type': 'live',
          'title': 'Live from $query',
          'artist': 'Ed Sheeran',
          'venue': 'Wembley Stadium',
          'viewers': '8.9K',
          'imageUrl': 'https://picsum.photos/300?random=2',
        },
      ]);
    }

    // Upcoming Events
    if (filter == 'All' || filter == 'Upcoming') {
      results.addAll([
        {
          'type': 'upcoming',
          'title': '$query World Tour',
          'artist': 'Billie Eilish',
          'venue': 'Hollywood Bowl',
          'date': 'Tomorrow',
          'time': '8:00 PM',
          'imageUrl': 'https://picsum.photos/300?random=3',
        },
        {
          'type': 'upcoming',
          'title': 'Summer $query Festival',
          'artist': 'Various Artists',
          'venue': 'Red Rocks',
          'date': 'In 3 days',
          'time': '7:30 PM',
          'imageUrl': 'https://picsum.photos/300?random=4',
        },
      ]);
    }

    // Artists
    if (filter == 'All' || filter == 'Artists') {
      results.addAll([
        {
          'type': 'artist',
          'name': '$query Brothers',
          'description': 'Pop sensation',
          'imageUrl': 'https://picsum.photos/300?random=5',
        },
        {
          'type': 'artist',
          'name': 'The $query',
          'description': 'R&B superstar',
          'imageUrl': 'https://picsum.photos/300?random=6',
        },
      ]);
    }

    // Venues
    if (filter == 'All' || filter == 'Venues') {
      results.addAll([
        {
          'type': 'venue',
          'name': '$query Arena',
          'location': 'New York, NY',
          'events': '12 upcoming events',
          'imageUrl': 'https://picsum.photos/300?random=7',
        },
        {
          'type': 'venue',
          'name': '$query Stadium',
          'location': 'Los Angeles, CA',
          'events': '8 upcoming events',
          'imageUrl': 'https://picsum.photos/300?random=8',
        },
      ]);
    }

    return results;
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

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (_isSearching) {
        _searchResults = _generateSearchResults(_searchController.text, filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          // Search Header with Wave Background
          Container(
            height: 180,
            child: Stack(
              children: [
                // Animated wave background
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: LiveWavePainter(_waveAnimation.value),
                        child: Container(),
                      );
                    },
                  ),
                ),

                // Content overlay
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => context.pop(),
                            ),
                            const Expanded(
                              child: Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search events, artists, venues...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.white,
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

                      // Discover label
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'DISCOVER',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            _applyFilter(filter);
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

          // Search Suggestions
          if (_showSuggestions && _searchSuggestions.isNotEmpty)
            Container(
              color: const Color(0xFF1A1A1A),
              child: Column(
                children: [
                  const Divider(color: Color(0xFF2A2A2A), height: 1),
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
                            () => _selectSuggestion(_searchSuggestions[index]),
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFF2A2A2A), height: 1),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child:
                _isSearching && _searchResults.isNotEmpty
                    ? _buildSearchResults()
                    : _buildDiscoverContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverContent() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // Recent Searches
        if (_recentSearches.isNotEmpty) ...[
          Padding(
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
                    style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(
                  _recentSearches[index],
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 16),
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
            },
          ),
        ],

        // Popular Searches
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              const Text(
                'Popular Searches',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPopularSearchChip('Live Concerts'),
              _buildPopularSearchChip('Music Festivals'),
              _buildPopularSearchChip('Taylor Swift'),
              _buildPopularSearchChip('Coachella'),
              _buildPopularSearchChip('EDM'),
              _buildPopularSearchChip('Jazz'),
              _buildPopularSearchChip('Hip Hop'),
              _buildPopularSearchChip('Rock'),
            ],
          ),
        ),

        // Browse Categories
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Row(
            children: [
              const Text(
                'Browse Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final categories = [
                'Concerts',
                'Festivals',
                'DJ Sets',
                'Acoustic',
                'Classical',
                'Jazz',
              ];
              final colors = [
                const Color(0xFFFF5252),
                const Color(0xFF6366F1),
                const Color(0xFF45B7D1),
                const Color(0xFF96CEB4),
                const Color(0xFFFECA57),
                const Color(0xFFEC4899),
              ];
              final icons = [
                Icons.music_note,
                Icons.festival,
                Icons.headphones,
                Icons.piano,
                Icons.music_video,
                Icons.phone,
              ];
              return _buildCategoryCard(
                categories[index],
                colors[index],
                icons[index],
              );
            },
          ),
        ),

        // Trending Events
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Trending Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildLiveEventCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    // Group results by type
    Map<String, List<Map<String, dynamic>>> groupedResults = {};

    for (var result in _searchResults) {
      String type = result['type'];
      if (!groupedResults.containsKey(type)) {
        groupedResults[type] = [];
      }
      groupedResults[type]!.add(result);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // Live Events
        if (groupedResults.containsKey('live')) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: groupedResults['live']!.length,
              itemBuilder: (context, index) {
                return _buildLiveEventCardFromData(
                  groupedResults['live']![index],
                );
              },
            ),
          ),
        ],

        // Upcoming Events
        if (groupedResults.containsKey('upcoming')) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF6366F1), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: groupedResults['upcoming']!.length,
            itemBuilder: (context, index) {
              return _buildUpcomingEventItemFromData(
                groupedResults['upcoming']![index],
              );
            },
          ),
        ],

        // Artists
        if (groupedResults.containsKey('artist')) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.person, color: Color(0xFFFECA57), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Artists',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: groupedResults['artist']!.length,
              itemBuilder: (context, index) {
                return _buildFeaturedArtistCardFromData(
                  groupedResults['artist']![index],
                );
              },
            ),
          ),
        ],

        // Venues
        if (groupedResults.containsKey('venue')) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF45B7D1),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Venues',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groupedResults['venue']!.length,
            itemBuilder: (context, index) {
              return _buildVenueCard(groupedResults['venue']![index]);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPopularSearchChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCategoryCard(String title, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        _searchController.text = title;
        _performSearch(title);
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

  Widget _buildLiveEventCard(int index) {
    final artists = [
      'Taylor Swift',
      'Ed Sheeran',
      'Billie Eilish',
      'The Weeknd',
      'Dua Lipa',
    ];
    final venues = [
      'Madison Square Garden',
      'Wembley Stadium',
      'Hollywood Bowl',
      'Red Rocks',
      'O2 Arena',
    ];
    final viewers = [15420, 8930, 12650, 6780, 9340];

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://picsum.photos/400/300?random=${index + 100}',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Live badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Viewer count
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${viewers[index]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Play button overlay
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${artists[index]} Live',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  venues[index],
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/live-event-detail/event1');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Join Stream',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 20,
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

  Widget _buildLiveEventCardFromData(Map<String, dynamic> event) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(event['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Live badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Viewer count
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['viewers'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Play button overlay
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  event['venue'],
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/live-event-detail/event1');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Join Stream',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 20,
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

  Widget _buildUpcomingEventItemFromData(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(event['imageUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event, color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
        title: Text(
          event['title'],
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
              event['venue'],
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
                  '${event['date']} • ${event['time']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            side: const BorderSide(color: Color(0xFF6366F1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Remind', style: TextStyle(fontSize: 12)),
        ),
        onTap: () {},
        isThreeLine: true,
      ),
    );
  }

  Widget _buildFeaturedArtistCardFromData(Map<String, dynamic> artist) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(artist['imageUrl']),
          fit: BoxFit.cover,
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
                Text(
                  artist['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  artist['description'],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(Map<String, dynamic> venue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venue Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage(venue['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Venue Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      venue['location'],
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.event, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      venue['events'],
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Center(
                    child: Text(
                      'View Events',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
