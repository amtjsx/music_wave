import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendsActivityScreen extends StatefulWidget {
  const FriendsActivityScreen({super.key});

  @override
  State<FriendsActivityScreen> createState() => _FriendsActivityScreenState();
}

class _FriendsActivityScreenState extends State<FriendsActivityScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;
  String _selectedFilter = 'All Activity';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Sample data for friends currently listening
  final List<Map<String, dynamic>> _nowPlayingFriends = [
    {
      'name': 'Emma Wilson',
      'avatar': 'https://randomuser.me/api/portraits/women/32.jpg',
      'song': 'Blinding Lights',
      'artist': 'The Weeknd',
      'album': 'After Hours',
      'albumCover': 'https://picsum.photos/200?random=1',
      'timeElapsed': '1:42',
      'duration': '3:20',
    },
    {
      'name': 'James Rodriguez',
      'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
      'song': 'As It Was',
      'artist': 'Harry Styles',
      'album': "Harry's House",
      'albumCover': 'https://picsum.photos/200?random=2',
      'timeElapsed': '0:58',
      'duration': '2:47',
    },
    {
      'name': 'Sophia Chen',
      'avatar': 'https://randomuser.me/api/portraits/women/64.jpg',
      'song': 'Bad Habit',
      'artist': 'Steve Lacy',
      'album': 'Gemini Rights',
      'albumCover': 'https://picsum.photos/200?random=3',
      'timeElapsed': '2:15',
      'duration': '3:52',
    },
  ];

  // Sample data for friend activity feed
  final List<Map<String, dynamic>> _activityFeed = [
    {
      'type': 'liked',
      'name': 'Michael Brown',
      'avatar': 'https://randomuser.me/api/portraits/men/22.jpg',
      'content': 'Liked the song "Shivers" by Ed Sheeran',
      'contentImage': 'https://picsum.photos/200?random=4',
      'timeAgo': DateTime.now().subtract(const Duration(minutes: 5)),
      'likes': 3,
      'comments': 0,
      'hasLiked': false,
    },
    {
      'type': 'playlist',
      'name': 'Olivia Parker',
      'avatar': 'https://randomuser.me/api/portraits/women/28.jpg',
      'content': 'Created a new playlist "Summer Vibes 2023"',
      'contentImage': 'https://picsum.photos/200?random=5',
      'timeAgo': DateTime.now().subtract(const Duration(hours: 1)),
      'likes': 12,
      'comments': 2,
      'hasLiked': true,
      'playlistSongs': 18,
    },
    {
      'type': 'listening',
      'name': 'Daniel Kim',
      'avatar': 'https://randomuser.me/api/portraits/men/36.jpg',
      'content': 'Listened to the album "Renaissance" by Beyoncé',
      'contentImage': 'https://picsum.photos/200?random=6',
      'timeAgo': DateTime.now().subtract(const Duration(hours: 3)),
      'likes': 8,
      'comments': 1,
      'hasLiked': false,
    },
    {
      'type': 'followed',
      'name': 'Sarah Johnson',
      'avatar': 'https://randomuser.me/api/portraits/women/42.jpg',
      'content': 'Started following Taylor Swift',
      'contentImage': 'https://picsum.photos/200?random=7',
      'timeAgo': DateTime.now().subtract(const Duration(hours: 5)),
      'likes': 15,
      'comments': 0,
      'hasLiked': true,
    },
    {
      'type': 'event',
      'name': 'Ryan Garcia',
      'avatar': 'https://randomuser.me/api/portraits/men/55.jpg',
      'content': 'Is attending "Summer Music Festival 2023"',
      'contentImage': 'https://picsum.photos/200?random=8',
      'timeAgo': DateTime.now().subtract(const Duration(hours: 8)),
      'likes': 24,
      'comments': 5,
      'hasLiked': false,
      'eventDate': 'July 15-17, 2023',
      'eventLocation': 'Central Park, New York',
    },
  ];

  // Sample data for friend suggestions
  final List<Map<String, dynamic>> _friendSuggestions = [
    {
      'name': 'Alex Turner',
      'avatar': 'https://randomuser.me/api/portraits/men/72.jpg',
      'mutualFriends': 5,
      'mutualArtists': ['Arctic Monkeys', 'The Strokes'],
    },
    {
      'name': 'Mia Williams',
      'avatar': 'https://randomuser.me/api/portraits/women/55.jpg',
      'mutualFriends': 3,
      'mutualArtists': ['Dua Lipa', 'Billie Eilish'],
    },
    {
      'name': 'Noah Martinez',
      'avatar': 'https://randomuser.me/api/portraits/men/62.jpg',
      'mutualFriends': 7,
      'mutualArtists': ['Kendrick Lamar', 'J. Cole'],
    },
  ];

  // Filter options
  final List<String> _filterOptions = [
    'All Activity',
    'Listening',
    'Playlists',
    'Likes',
    'Following',
    'Events',
  ];

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
    super.dispose();
  }

  void _toggleLike(int index) {
    setState(() {
      final activity = _activityFeed[index];
      if (activity['hasLiked']) {
        activity['likes'] = activity['likes'] - 1;
      } else {
        activity['likes'] = activity['likes'] + 1;
      }
      activity['hasLiked'] = !activity['hasLiked'];
    });
  }

  void _showComments(Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return _buildCommentsSheet(activity, scrollController);
            },
          ),
    );
  }

  Widget _buildCommentsSheet(
    Map<String, dynamic> activity,
    ScrollController scrollController,
  ) {
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
              Text(
                'Comments (${activity['comments']})',
                style: const TextStyle(
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
        // Comments list
        Expanded(
          child:
              activity['comments'] > 0
                  ? ListView.builder(
                    controller: scrollController,
                    itemCount: activity['comments'],
                    itemBuilder: (context, index) {
                      // This would normally come from a database
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://randomuser.me/api/portraits/men/${70 + index}.jpg',
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              'User ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeago.format(
                                DateTime.now().subtract(
                                  Duration(minutes: index * 15 + 5),
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'This is comment ${index + 1} on this activity. Great choice!',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Icon(
                          Icons.favorite_border,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      );
                    },
                  )
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
        // Comment input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            border: Border(
              top: BorderSide(color: Colors.grey[800]!, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/32.jpg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: () {
                    // Handle sending comment
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor:
                _showAppBarTitle ? const Color(0xFF1A1A1A) : Colors.transparent,
            elevation: 0,
            title:
                _showAppBarTitle
                    ? const Text(
                      'Friend Activity',
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
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.person_add_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Navigate to add friends screen
                },
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
                          painter: FriendsWavePainter(_waveAnimation.value),
                          child: Container(),
                        );
                      },
                    ),
                  ),

                  // Content overlay
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Friend Activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'See what your friends are listening to',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar (if searching)
          if (_isSearching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
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
                    // Filter friends based on search
                    setState(() {});
                  },
                ),
              ),
            ),

          // Filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = filter == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
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

          // Now Playing Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Now Playing',
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

          // Now Playing Cards
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _nowPlayingFriends.length,
                itemBuilder: (context, index) {
                  final friend = _nowPlayingFriends[index];
                  return _buildNowPlayingCard(friend);
                },
              ),
            ),
          ),

          // Friend Suggestions Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    color: Color(0xFF6366F1),
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

          // Friend Suggestions Cards
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _friendSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _friendSuggestions[index];
                  return _buildFriendSuggestionCard(suggestion);
                },
              ),
            ),
          ),

          // Activity Feed Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Activity',
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

          // Activity Feed
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final activity = _activityFeed[index];
              // Filter activities based on selected filter
              if (_selectedFilter != 'All Activity') {
                final filterType = _selectedFilter.toLowerCase();
                final activityType = activity['type'];
                if (filterType == 'listening' && activityType != 'listening') {
                  return const SizedBox.shrink();
                } else if (filterType == 'playlists' &&
                    activityType != 'playlist') {
                  return const SizedBox.shrink();
                } else if (filterType == 'likes' && activityType != 'liked') {
                  return const SizedBox.shrink();
                } else if (filterType == 'following' &&
                    activityType != 'followed') {
                  return const SizedBox.shrink();
                } else if (filterType == 'events' && activityType != 'event') {
                  return const SizedBox.shrink();
                }
              }
              return _buildActivityCard(activity, index);
            }, childCount: _activityFeed.length),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
       
 
    );
  }

  Widget _buildNowPlayingCard(Map<String, dynamic> friend) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Friend info and album art
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(friend['avatar']),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push('/friends/${friend['id']}');
                  },
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
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Listening now',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),

          // Album cover and song info
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(friend['albumCover']),
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        friend['song'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        friend['artist'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      Stack(
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: _getProgressFraction(
                              friend['timeElapsed'],
                              friend['duration'],
                            ),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            friend['timeElapsed'],
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            friend['duration'],
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.play_arrow, 'Play'),
                _buildActionButton(Icons.playlist_add, 'Save'),
                _buildActionButton(Icons.share, 'Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildFriendSuggestionCard(Map<String, dynamic> suggestion) {
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
                  backgroundImage: NetworkImage(suggestion['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${suggestion['mutualFriends']} mutual friends',
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
                  suggestion['mutualArtists'].join(', '),
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

  Widget _buildActivityCard(Map<String, dynamic> activity, int index) {
    // Different card layouts based on activity type
    Widget contentWidget;

    switch (activity['type']) {
      case 'playlist':
        contentWidget = _buildPlaylistContent(activity);
        break;
      case 'event':
        contentWidget = _buildEventContent(activity);
        break;
      case 'followed':
        contentWidget = _buildFollowedContent(activity);
        break;
      default:
        contentWidget = _buildDefaultContent(activity);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and timestamp
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(activity['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeago.format(activity['timeAgo']),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Activity content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              activity['content'],
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),

          // Activity-specific content
          contentWidget,

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: () => _toggleLike(index),
                  child: Row(
                    children: [
                      Icon(
                        activity['hasLiked']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            activity['hasLiked']
                                ? const Color(0xFFEC4899)
                                : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity['likes']}',
                        style: TextStyle(
                          color:
                              activity['hasLiked']
                                  ? const Color(0xFFEC4899)
                                  : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Comment button
                GestureDetector(
                  onTap: () => _showComments(activity),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity['comments']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Share button
                const Icon(Icons.share, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(activity['contentImage']),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistContent(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(activity['contentImage']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Playlist',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['content'].split('"')[1],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${activity['playlistSongs']} songs',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Play'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContent(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(activity['contentImage']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFF6366F1),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                activity['eventDate'],
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF6366F1), size: 16),
              const SizedBox(width: 8),
              Text(
                activity['eventLocation'],
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Interested'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Going'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowedContent(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(activity['contentImage']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Artist',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['content'].split('following ')[1],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Popular Artist • 10M+ followers',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Follow'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getProgressFraction(String elapsed, String total) {
    // Convert time strings to seconds
    final elapsedParts = elapsed.split(':');
    final totalParts = total.split(':');

    final elapsedSeconds =
        int.parse(elapsedParts[0]) * 60 + int.parse(elapsedParts[1]);
    final totalSeconds =
        int.parse(totalParts[0]) * 60 + int.parse(totalParts[1]);

    return elapsedSeconds / totalSeconds;
  }
}

class FriendsWavePainter extends CustomPainter {
  final double animationValue;

  FriendsWavePainter(this.animationValue);

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
