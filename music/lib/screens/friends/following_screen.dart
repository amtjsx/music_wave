import 'dart:math' as math;

import 'package:flutter/material.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Infinite scroll state variables
  bool _isLoadingMore = false;
  bool _hasMoreItems = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Following data
  final List<Map<String, dynamic>> _followedArtists = [];
  final List<Map<String, dynamic>> _followedFriends = [];
  final List<Map<String, dynamic>> _followedUsers = [];

  // Filter options
  String _selectedArtistFilter = 'All Genres';
  String _selectedFriendFilter = 'All Friends';
  String _selectedUserFilter = 'All Users';

  final List<String> _artistGenres = [
    'All Genres',
    'Pop',
    'Rock',
    'Hip Hop',
    'R&B',
    'Electronic',
    'Jazz',
    'Classical',
    'Country',
    'Folk',
    'Indie',
  ];

  final List<String> _friendFilters = [
    'All Friends',
    'Recently Active',
    'Mutual Friends',
    'Shared Playlists',
    'Live Events',
  ];

  final List<String> _userFilters = [
    'All Users',
    'Recently Followed',
    'Most Active',
    'Similar Taste',
    'Content Creators',
  ];

  // Suggested entities to follow
  final List<Map<String, dynamic>> _suggestedArtists = [
    {
      'name': 'Taylor Swift',
      'image': 'https://picsum.photos/200?random=101',
      'genre': 'Pop',
      'followers': '92.5M',
    },
    {
      'name': 'Kendrick Lamar',
      'image': 'https://picsum.photos/200?random=102',
      'genre': 'Hip Hop',
      'followers': '45.8M',
    },
    {
      'name': 'Dua Lipa',
      'image': 'https://picsum.photos/200?random=103',
      'genre': 'Pop',
      'followers': '38.2M',
    },
  ];

  final List<Map<String, dynamic>> _suggestedFriends = [
    {
      'name': 'Emma Wilson',
      'avatar': 'https://randomuser.me/api/portraits/women/32.jpg',
      'mutualFriends': 5,
      'mutualArtists': ['The Weeknd', 'Billie Eilish'],
    },
    {
      'name': 'James Rodriguez',
      'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
      'mutualFriends': 3,
      'mutualArtists': ['Drake', 'Post Malone'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _waveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    // Load initial data for each tab
    _loadMoreArtists();
    _loadMoreFriends();
    _loadMoreUsers();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _searchQuery = '';
        _searchController.clear();
      });
    }
  }

  void _onScroll() {
    // Check if we need to show the app bar title
    final showTitle = _scrollController.offset > 150;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }

    // Check if we need to load more items
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    switch (_tabController.index) {
      case 0:
        _loadMoreArtists();
        break;
      case 1:
        _loadMoreFriends();
        break;
      case 2:
        _loadMoreUsers();
        break;
    }
  }

  Future<void> _loadMoreArtists() async {
    // Don't load more if already loading or no more items
    if (_isLoadingMore || !_hasMoreItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate artists for this page
    final newArtists = List.generate(
      _itemsPerPage,
      (index) => _generateArtist(_currentPage, index),
    );

    // Check if we've reached the end (for demo purposes, limit to 5 pages)
    final hasMore = _currentPage < 5;

    setState(() {
      _followedArtists.addAll(newArtists);
      _currentPage++;
      _isLoadingMore = false;
      _hasMoreItems = hasMore;
    });
  }

  Future<void> _loadMoreFriends() async {
    // Don't load more if already loading or no more items
    if (_isLoadingMore || !_hasMoreItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate friends for this page
    final newFriends = List.generate(
      _itemsPerPage,
      (index) => _generateFriend(_currentPage, index),
    );

    // Check if we've reached the end (for demo purposes, limit to 5 pages)
    final hasMore = _currentPage < 5;

    setState(() {
      _followedFriends.addAll(newFriends);
      _currentPage++;
      _isLoadingMore = false;
      _hasMoreItems = hasMore;
    });
  }

  Future<void> _loadMoreUsers() async {
    // Don't load more if already loading or no more items
    if (_isLoadingMore || !_hasMoreItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate users for this page
    final newUsers = List.generate(
      _itemsPerPage,
      (index) => _generateUser(_currentPage, index),
    );

    // Check if we've reached the end (for demo purposes, limit to 5 pages)
    final hasMore = _currentPage < 5;

    setState(() {
      _followedUsers.addAll(newUsers);
      _currentPage++;
      _isLoadingMore = false;
      _hasMoreItems = hasMore;
    });
  }

  Map<String, dynamic> _generateArtist(int page, int index) {
    final random = math.Random();
    final globalIndex = (page - 1) * _itemsPerPage + index;

    // Artist names
    final artistNames = [
      'The Weeknd',
      'Billie Eilish',
      'Drake',
      'Ariana Grande',
      'Post Malone',
      'Doja Cat',
      'Justin Bieber',
      'Bad Bunny',
      'Harry Styles',
      'BTS',
      'Olivia Rodrigo',
      'Lil Nas X',
      'Dua Lipa',
      'Ed Sheeran',
      'SZA',
      'Jack Harlow',
      'Lizzo',
      'Adele',
      'Kendrick Lamar',
      'Travis Scott',
    ];

    // Genres
    final genres = [
      'Pop',
      'Rock',
      'Hip Hop',
      'R&B',
      'Electronic',
      'Jazz',
      'Classical',
      'Country',
      'Folk',
      'Indie',
    ];

    final name = artistNames[globalIndex % artistNames.length];
    final genre = genres[globalIndex % genres.length];
    final image = 'https://picsum.photos/200?random=${200 + globalIndex}';
    final followers = '${(random.nextInt(90) + 10)}.${random.nextInt(9)}M';
    final monthlyListeners =
        '${(random.nextInt(90) + 10)}.${random.nextInt(9)}M';
    final isVerified = random.nextBool();
    final isNewlyFollowed = globalIndex < 3; // First 3 are newly followed

    return {
      'name': name,
      'genre': genre,
      'image': image,
      'followers': followers,
      'monthlyListeners': monthlyListeners,
      'isVerified': isVerified,
      'isNewlyFollowed': isNewlyFollowed,
    };
  }

  Map<String, dynamic> _generateFriend(int page, int index) {
    final random = math.Random();
    final globalIndex = (page - 1) * _itemsPerPage + index;

    // Friend names
    final friendNames = [
      'Emma Wilson',
      'James Rodriguez',
      'Sophia Chen',
      'Michael Brown',
      'Olivia Parker',
      'Daniel Kim',
      'Sarah Johnson',
      'Ryan Garcia',
      'Emily Davis',
      'David Martinez',
      'Jessica Taylor',
      'Christopher Lee',
      'Ashley White',
      'Matthew Harris',
      'Amanda Jackson',
      'Andrew Thompson',
      'Jennifer Clark',
      'Joshua Lewis',
      'Elizabeth Walker',
      'Brian Young',
    ];

    // Recent activities
    final recentActivities = [
      'Listening to "Blinding Lights" by The Weeknd',
      'Created a new playlist "Summer Vibes"',
      'Attended "Electronic Music Festival"',
      'Followed Taylor Swift',
      'Shared a song with you',
      'Liked your playlist',
      'Commented on your post',
    ];

    final name = friendNames[globalIndex % friendNames.length];
    final avatar =
        'https://randomuser.me/api/portraits/men/${20 + globalIndex % 60}.jpg';
    final mutualFriends = random.nextInt(15) + 1;
    final recentActivity =
        recentActivities[globalIndex % recentActivities.length];
    final lastActive = '${random.nextInt(24)} hours ago';
    final isOnline = random.nextBool();
    final isNewlyFollowed = globalIndex < 2; // First 2 are newly followed

    return {
      'name': name,
      'avatar': avatar,
      'mutualFriends': mutualFriends,
      'recentActivity': recentActivity,
      'lastActive': lastActive,
      'isOnline': isOnline,
      'isNewlyFollowed': isNewlyFollowed,
    };
  }

  Map<String, dynamic> _generateUser(int page, int index) {
    final random = math.Random();
    final globalIndex = (page - 1) * _itemsPerPage + index;

    // User names
    final userNames = [
      'musiclover92',
      'beatmaker',
      'rockstar2023',
      'popfanatic',
      'jazzmaster',
      'classicalvibes',
      'hiphophead',
      'indieartist',
      'electronicDJ',
      'folkmusician',
      'countryroots',
      'bluesplayer',
      'reggaefan',
      'metalhead',
      'punkrocker',
      'soulmusic',
      'funkmaster',
      'discoking',
      'rapfan',
      'alternativesound',
    ];

    // Bios
    final bios = [
      'Music enthusiast and playlist creator',
      'Aspiring musician and songwriter',
      'Concert photographer and reviewer',
      'Music blogger and critic',
      'DJ and producer',
      'Music teacher and mentor',
      'Vinyl collector and audiophile',
      'Festival goer and live music lover',
      'Music industry professional',
      'Podcast host about music trends',
    ];

    final username = userNames[globalIndex % userNames.length];
    final name = 'User ${globalIndex + 1}';
    final avatar =
        'https://randomuser.me/api/portraits/women/${20 + globalIndex % 60}.jpg';
    final bio = bios[globalIndex % bios.length];
    final followers = random.nextInt(5000) + 100;
    final following = random.nextInt(1000) + 50;
    final playlists = random.nextInt(30) + 1;
    final isVerified = random.nextBool() && random.nextBool(); // Less likely
    final isNewlyFollowed = globalIndex < 2; // First 2 are newly followed

    return {
      'username': username,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'followers': followers,
      'following': following,
      'playlists': playlists,
      'isVerified': isVerified,
      'isNewlyFollowed': isNewlyFollowed,
    };
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.8,
            expand: false,
            builder: (context, scrollController) {
              return _buildFilterSheet(scrollController);
            },
          ),
    );
  }

  Widget _buildFilterSheet(ScrollController scrollController) {
    // Determine which filter options to show based on current tab
    List<String> filterOptions;
    String selectedFilter;

    switch (_tabController.index) {
      case 0: // Artists
        filterOptions = _artistGenres;
        selectedFilter = _selectedArtistFilter;
        break;
      case 1: // Friends
        filterOptions = _friendFilters;
        selectedFilter = _selectedFriendFilter;
        break;
      case 2: // Users
        filterOptions = _userFilters;
        selectedFilter = _selectedUserFilter;
        break;
      default:
        filterOptions = _artistGenres;
        selectedFilter = _selectedArtistFilter;
    }

    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                'Filter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.grey),
        // Filter options
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: filterOptions.length,
            itemBuilder: (context, index) {
              final filter = filterOptions[index];
              final isSelected = filter == selectedFilter;
              return ListTile(
                title: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing:
                    isSelected
                        ? const Icon(Icons.check, color: Color(0xFF6366F1))
                        : null,
                onTap: () {
                  // Update the selected filter based on current tab
                  switch (_tabController.index) {
                    case 0: // Artists
                      setState(() {
                        _selectedArtistFilter = filter;
                      });
                      break;
                    case 1: // Friends
                      setState(() {
                        _selectedFriendFilter = filter;
                      });
                      break;
                    case 2: // Users
                      setState(() {
                        _selectedUserFilter = filter;
                      });
                      break;
                  }
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        // Apply button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Apply Filter'),
          ),
        ),
      ],
    );
  }

  void _showUnfollowConfirmation(String name, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            'Unfollow $name?',
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            'You will no longer see updates from $name in your feed.',
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text(
                'Unfollow',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _waveController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification) {
            if (_scrollController.position.extentAfter < 200) {
              _loadMoreItems();
            }
          }
          return false;
        },
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // App Bar with wave background
              SliverAppBar(
                expandedHeight: 80,
                floating: false,
                pinned: true,
                backgroundColor:
                    _showAppBarTitle
                        ? const Color(0xFF1A1A1A)
                        : Colors.transparent,
                elevation: 0,
                title:
                    _showAppBarTitle
                        ? const Text(
                          'Following',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          _searchQuery = '';
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: _showFilterOptions,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Animated wave background
                      Container(
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
                              painter: FollowingWavePainter(
                                _waveAnimation.value,
                              ),
                              child: Container(),
                            );
                          },
                        ),
                      ),

                      // Content overlay
                      Positioned(
                        left: 50,
                        right: 20,
                        bottom: 50,
                        child: const Text(
                          'Following',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFFEC4899),
                  dividerHeight: 2,
                  indicatorWeight: 2,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Artists'),
                    Tab(text: 'Friends'),
                    Tab(text: 'Users'),
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: [
              // Search bar (if searching)
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search following...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Artists Tab
                    _buildArtistsTab(),

                    // Friends Tab
                    _buildFriendsTab(),

                    // Users Tab
                    _buildUsersTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
       
 
    );
  }

  Widget _buildArtistsTab() {
    // Filter artists based on search query and genre filter
    final filteredArtists =
        _followedArtists.where((artist) {
          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            return artist['name'].toLowerCase().contains(_searchQuery);
          }

          // Apply genre filter
          if (_selectedArtistFilter != 'All Genres') {
            return artist['genre'] == _selectedArtistFilter;
          }

          return true;
        }).toList();

    return CustomScrollView(
      slivers: [
        // Filter indicator
        if (_selectedArtistFilter != 'All Genres')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtered by: $_selectedArtistFilter',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedArtistFilter = 'All Genres';
                      });
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Suggested Artists Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.recommend, color: Color(0xFFEC4899), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Suggested Artists',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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

        // Suggested Artists Horizontal List
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestedArtists.length,
              itemBuilder: (context, index) {
                final artist = _suggestedArtists[index];
                return _buildSuggestedArtistCard(artist);
              },
            ),
          ),
        ),

        // Following Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Following Stats',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Artists',
                        '${_followedArtists.length}',
                        Colors.purple,
                      ),
                      _buildStatItem(
                        'Friends',
                        '${_followedFriends.length}',
                        Colors.blue,
                      ),
                      _buildStatItem(
                        'Users',
                        '${_followedUsers.length}',
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Followed Artists Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Artists You Follow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredArtists.length}',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Followed Artists List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // If we've reached the end of the current artists
              if (index >= filteredArtists.length) {
                // Show loading indicator if more items are available
                if (_hasMoreItems &&
                    _selectedArtistFilter == 'All Genres' &&
                    _searchQuery.isEmpty) {
                  return _buildLoadingIndicator();
                } else if (filteredArtists.isEmpty) {
                  return _buildEmptyState(
                    'No artists found',
                    'Try adjusting your filters or search query',
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }

              final artist = filteredArtists[index];
              return _buildArtistItem(artist, index);
            },
            // Add extra item for loading indicator
            childCount:
                filteredArtists.isEmpty ? 1 : filteredArtists.length + 1,
          ),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildFriendsTab() {
    // Filter friends based on search query and friend filter
    final filteredFriends =
        _followedFriends.where((friend) {
          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            return friend['name'].toLowerCase().contains(_searchQuery);
          }

          // Apply friend filter
          if (_selectedFriendFilter == 'Recently Active') {
            return friend['lastActive'].contains('hours');
          } else if (_selectedFriendFilter == 'Mutual Friends') {
            return friend['mutualFriends'] > 3;
          } else if (_selectedFriendFilter != 'All Friends') {
            // Other filters would have specific logic here
            return true;
          }

          return true;
        }).toList();

    return CustomScrollView(
      slivers: [
        // Filter indicator
        if (_selectedFriendFilter != 'All Friends')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtered by: $_selectedFriendFilter',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFriendFilter = 'All Friends';
                      });
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Suggested Friends Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.person_add,
                  color: Color(0xFFEC4899),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Suggested Friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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

        // Suggested Friends Horizontal List
        SliverToBoxAdapter(
          child: SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestedFriends.length,
              itemBuilder: (context, index) {
                final friend = _suggestedFriends[index];
                return _buildSuggestedFriendCard(friend);
              },
            ),
          ),
        ),

        // Followed Friends Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Friends You Follow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredFriends.length}',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Followed Friends List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // If we've reached the end of the current friends
              if (index >= filteredFriends.length) {
                // Show loading indicator if more items are available
                if (_hasMoreItems &&
                    _selectedFriendFilter == 'All Friends' &&
                    _searchQuery.isEmpty) {
                  return _buildLoadingIndicator();
                } else if (filteredFriends.isEmpty) {
                  return _buildEmptyState(
                    'No friends found',
                    'Try adjusting your filters or search query',
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }

              final friend = filteredFriends[index];
              return _buildFriendItem(friend, index);
            },
            // Add extra item for loading indicator
            childCount:
                filteredFriends.isEmpty ? 1 : filteredFriends.length + 1,
          ),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildUsersTab() {
    // Filter users based on search query and user filter
    final filteredUsers =
        _followedUsers.where((user) {
          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            return user['username'].toLowerCase().contains(_searchQuery) ||
                user['name'].toLowerCase().contains(_searchQuery);
          }

          // Apply user filter
          if (_selectedUserFilter == 'Recently Followed') {
            return user['isNewlyFollowed'];
          } else if (_selectedUserFilter == 'Most Active') {
            return user['playlists'] > 10;
          } else if (_selectedUserFilter != 'All Users') {
            // Other filters would have specific logic here
            return true;
          }

          return true;
        }).toList();

    return CustomScrollView(
      slivers: [
        // Filter indicator
        if (_selectedUserFilter != 'All Users')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filtered by: $_selectedUserFilter',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedUserFilter = 'All Users';
                      });
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Followed Users Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Users You Follow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredUsers.length}',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Followed Users List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // If we've reached the end of the current users
              if (index >= filteredUsers.length) {
                // Show loading indicator if more items are available
                if (_hasMoreItems &&
                    _selectedUserFilter == 'All Users' &&
                    _searchQuery.isEmpty) {
                  return _buildLoadingIndicator();
                } else if (filteredUsers.isEmpty) {
                  return _buildEmptyState(
                    'No users found',
                    'Try adjusting your filters or search query',
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }

              final user = filteredUsers[index];
              return _buildUserItem(user, index);
            },
            // Add extra item for loading indicator
            childCount: filteredUsers.isEmpty ? 1 : filteredUsers.length + 1,
          ),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildSuggestedArtistCard(Map<String, dynamic> artist) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artist image
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage(artist['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Artist info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        artist['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  artist['genre'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size.fromHeight(30),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  child: const Text('Follow', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedFriendCard(Map<String, dynamic> friend) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(friend['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${friend['mutualFriends']} mutual friends',
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Similar music taste:',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  friend['mutualArtists'].join(', '),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Follow'),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {},
                    iconSize: 16,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistItem(Map<String, dynamic> artist, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: NetworkImage(artist['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (artist['isNewlyFollowed'])
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEC4899),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                artist['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (artist['isVerified'])
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.verified, color: Colors.blue, size: 16),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              artist['genre'],
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${artist['followers']} followers',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.headphones, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${artist['monthlyListeners']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          color: const Color(0xFF2A2A2A),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'View Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Share', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'notifications',
                  child: Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'unfollow',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Unfollow', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            if (value == 'unfollow') {
              _showUnfollowConfirmation(artist['name'], () {
                setState(() {
                  _followedArtists.removeAt(index);
                });
              });
            }
          },
        ),
        onTap: () {
          // Navigate to artist profile
        },
      ),
    );
  }

  Widget _buildFriendItem(Map<String, dynamic> friend, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(friend['avatar']),
            ),
            if (friend['isOnline'])
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 2,
                    ),
                  ),
                ),
              ),
            if (friend['isNewlyFollowed'])
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEC4899),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          friend['name'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${friend['mutualFriends']} mutual friends',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Active ${friend['lastActive']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              friend['recentActivity'],
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          color: const Color(0xFF2A2A2A),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'View Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'message',
                  child: Row(
                    children: [
                      Icon(Icons.message, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Message', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Share', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'unfollow',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Unfollow', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            if (value == 'unfollow') {
              _showUnfollowConfirmation(friend['name'], () {
                setState(() {
                  _followedFriends.removeAt(index);
                });
              });
            }
          },
        ),
        onTap: () {
          // Navigate to friend profile
        },
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user['avatar']),
            ),
            if (user['isNewlyFollowed'])
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEC4899),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '@${user['username']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (user['isVerified'])
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.verified, color: Colors.blue, size: 16),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user['bio'],
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${user['followers']} followers',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.playlist_play, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${user['playlists']} playlists',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          color: const Color(0xFF2A2A2A),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'View Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Share', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'playlists',
                  child: Row(
                    children: [
                      Icon(Icons.playlist_play, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'View Playlists',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'unfollow',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Unfollow', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            if (value == 'unfollow') {
              _showUnfollowConfirmation(user['name'], () {
                setState(() {
                  _followedUsers.removeAt(index);
                });
              });
            }
          },
        ),
        onTap: () {
          // Navigate to user profile
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.search_off, color: Color(0xFF6366F1), size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FollowingWavePainter extends CustomPainter {
  final double animationValue;

  FollowingWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    final waveHeight = 15.0;
    final waveLength = size.width / 3;

    for (int i = 0; i < 4; i++) {
      path.reset();
      final yOffset = size.height * 0.2 + (i * 25);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            yOffset +
            waveHeight *
                math.sin(
                  (x / waveLength * 2 * math.pi) + animationValue + (i * 0.7),
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
