import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendProfileScreen extends StatefulWidget {
  final String friendId;

  const FriendProfileScreen({super.key, required this.friendId});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late ScrollController _scrollController;
  late TabController _tabController; // Added TabController
  bool _showAppBarTitle = false;
  bool _isFollowing = true;

  // Sample friend data - in a real app, this would come from an API
  late Map<String, dynamic> _friendData;

  @override
  void initState() {
    super.initState();
    _loadFriendData();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    // Initialize TabController with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
  }

  void _loadFriendData() {
    // In a real app, this would be an API call using the friendId
    _friendData = {
      'id': widget.friendId,
      'name': 'Emma Wilson',
      'username': '@emmawilson',
      'avatar': 'https://randomuser.me/api/portraits/women/32.jpg',
      'bio': 'Music lover • Concert enthusiast • Always exploring new sounds',
      'isVerified': true,
      'isFollowing': true,
      'stats': {'followers': '1.2K', 'following': '345', 'playlists': '27'},
      'topArtists': [
        {'name': 'The Weeknd', 'image': 'https://picsum.photos/200?random=10'},
        {'name': 'Dua Lipa', 'image': 'https://picsum.photos/200?random=11'},
        {
          'name': 'Kendrick Lamar',
          'image': 'https://picsum.photos/200?random=12',
        },
        {
          'name': 'Taylor Swift',
          'image': 'https://picsum.photos/200?random=13',
        },
        {
          'name': 'Arctic Monkeys',
          'image': 'https://picsum.photos/200?random=14',
        },
      ],
      'topGenres': ['Pop', 'R&B', 'Hip Hop', 'Indie', 'Alternative'],
      'recentlyPlayed': [
        {
          'title': 'Blinding Lights',
          'artist': 'The Weeknd',
          'album': 'After Hours',
          'cover': 'https://picsum.photos/200?random=20',
          'playedAt': DateTime.now().subtract(const Duration(minutes: 30)),
        },
        {
          'title': 'Levitating',
          'artist': 'Dua Lipa ft. DaBaby',
          'album': 'Future Nostalgia',
          'cover': 'https://picsum.photos/200?random=21',
          'playedAt': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'title': 'As It Was',
          'artist': 'Harry Styles',
          'album': "Harry's House",
          'cover': 'https://picsum.photos/200?random=22',
          'playedAt': DateTime.now().subtract(const Duration(hours: 5)),
        },
        {
          'title': 'HUMBLE.',
          'artist': 'Kendrick Lamar',
          'album': 'DAMN.',
          'cover': 'https://picsum.photos/200?random=23',
          'playedAt': DateTime.now().subtract(const Duration(hours: 8)),
        },
      ],
      'playlists': [
        {
          'name': 'Workout Hits',
          'description': 'High energy tracks to keep you motivated',
          'cover': 'https://picsum.photos/200?random=30',
          'trackCount': 32,
          'followers': '245',
        },
        {
          'name': 'Chill Vibes',
          'description': 'Relaxing tunes for unwinding',
          'cover': 'https://picsum.photos/200?random=31',
          'trackCount': 45,
          'followers': '189',
        },
        {
          'name': 'Road Trip Mix',
          'description': 'Perfect for long drives',
          'cover': 'https://picsum.photos/200?random=32',
          'trackCount': 28,
          'followers': '312',
        },
        {
          'name': '2010s Throwbacks',
          'description': 'Nostalgic hits from the last decade',
          'cover': 'https://picsum.photos/200?random=33',
          'trackCount': 50,
          'followers': '427',
        },
      ],
      'mutualFriends': [
        {
          'name': 'Alex Turner',
          'avatar': 'https://randomuser.me/api/portraits/men/72.jpg',
        },
        {
          'name': 'Sophia Chen',
          'avatar': 'https://randomuser.me/api/portraits/women/64.jpg',
        },
        {
          'name': 'James Rodriguez',
          'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
        },
        {
          'name': 'Olivia Parker',
          'avatar': 'https://randomuser.me/api/portraits/women/28.jpg',
        },
      ],
      'similarTaste': {
        'percentage': 78,
        'artists': ['The Weeknd', 'Dua Lipa', 'Taylor Swift'],
        'genres': ['Pop', 'R&B', 'Indie'],
      },
      'recentActivity': [
        {
          'type': 'liked',
          'content': 'Liked the song "Shivers" by Ed Sheeran',
          'timeAgo': DateTime.now().subtract(const Duration(hours: 3)),
        },
        {
          'type': 'playlist',
          'content': 'Created a new playlist "Summer Vibes 2023"',
          'timeAgo': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'type': 'listening',
          'content': 'Listened to the album "Renaissance" by Beyoncé',
          'timeAgo': DateTime.now().subtract(const Duration(days: 2)),
        },
      ],
    };

    _isFollowing = _friendData['isFollowing'];
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 200;
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
    _tabController.dispose(); // Dispose TabController
    super.dispose();
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      _friendData['isFollowing'] = _isFollowing;
    });
  }

  void _showMessageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            'Message ${_friendData['name']}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your message...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF212121),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor:
                _showAppBarTitle ? const Color(0xFF1A1A1A) : Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
            title:
                _showAppBarTitle
                    ? Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(_friendData['avatar']),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _friendData['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                    : null,
            flexibleSpace: FlexibleSpaceBar(
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
                            painter: FriendProfileWavePainter(
                              _waveAnimation.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Profile Content
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            image: DecorationImage(
                              image: NetworkImage(_friendData['avatar']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // User Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _friendData['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_friendData['isVerified'])
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue[300],
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _friendData['username'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _friendData['bio'],
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Followers',
                    _friendData['stats']['followers'],
                  ),
                  _buildStatItem(
                    'Following',
                    _friendData['stats']['following'],
                  ),
                  _buildStatItem(
                    'Playlists',
                    _friendData['stats']['playlists'],
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isFollowing
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFF6366F1),
                        foregroundColor:
                            _isFollowing
                                ? const Color(0xFF6366F1)
                                : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                _isFollowing
                                    ? const Color(0xFF6366F1)
                                    : Colors.transparent,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(_isFollowing ? 'Following' : 'Follow'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showMessageDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Message'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: TabBar(
                controller: _tabController, // Use the TabController
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Playlists'),
                  Tab(text: 'Activity'),
                ],
                indicatorColor: const Color(0xFF6366F1),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
              ),
            ),
          ),

          // Tab Content
          SliverToBoxAdapter(
            child: SizedBox(
              height:
                  MediaQuery.of(
                    context,
                  ).size.height, // Give enough height for content
              child: TabBarView(
                controller: _tabController, // Use the TabController
                children: [
                  // Overview Tab
                  _buildOverviewTabContent(),
                  // Playlists Tab
                  _buildPlaylistsTabContent(),
                  // Activity Tab
                  _buildActivityTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
       
 
    );
  }

  // Build tab content widgets separately
  Widget _buildOverviewTabContent() {
    return SingleChildScrollView(
      physics:
          const NeverScrollableScrollPhysics(), // Prevent scrolling conflict
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Similar Music Taste
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFEC4899),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Music Compatibility',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_friendData['similarTaste']['percentage']}%',
                          style: const TextStyle(
                            color: Color(0xFFEC4899),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You both enjoy:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...(_friendData['similarTaste']['artists'] as List).map((
                        artist,
                      ) {
                        return Chip(
                          label: Text(artist.toString()),
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ).withOpacity(0.2),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                      ...(_friendData['similarTaste']['genres'] as List).map((
                        genre,
                      ) {
                        return Chip(
                          label: Text(genre.toString()),
                          backgroundColor: const Color(
                            0xFFEC4899,
                          ).withOpacity(0.2),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Top Artists
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFA500), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Top Artists',
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

          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _friendData['topArtists'].length,
              itemBuilder: (context, index) {
                final artist = _friendData['topArtists'][index];
                return _buildArtistItem(artist);
              },
            ),
          ),

          // Top Genres
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.category, color: Color(0xFF6366F1), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Top Genres',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (_friendData['topGenres'] as List).map<Widget>((genre) {
                    final index = _friendData['topGenres'].indexOf(genre);
                    final colors = [
                      const Color(0xFF6366F1),
                      const Color(0xFFEC4899),
                      const Color(0xFF10B981),
                      const Color(0xFFF59E0B),
                      const Color(0xFF8B5CF6),
                    ];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors[index % colors.length].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors[index % colors.length].withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        genre.toString(),
                        style: TextStyle(
                          color: colors[index % colors.length],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Recently Played
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Recently Played',
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

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _friendData['recentlyPlayed'].length,
            itemBuilder: (context, index) {
              final track = _friendData['recentlyPlayed'][index];
              return _buildTrackItem(track, index);
            },
          ),

          // Mutual Friends
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Mutual Friends',
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ...(_friendData['mutualFriends'] as List).map((friend) {
                  final index = _friendData['mutualFriends'].indexOf(friend);
                  return Container(
                    // margin: EdgeInsets.only(left: index == 0 ? 0 : -12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0A0A0A),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(friend['avatar']),
                    ),
                  );
                }).toList(),
                const SizedBox(width: 12),
                Text(
                  '${_friendData['mutualFriends'].length} mutual friends',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100), // Bottom spacing
        ],
      ),
    );
  }

  Widget _buildPlaylistsTabContent() {
    return GridView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Prevent scrolling conflict
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _friendData['playlists'].length,
      itemBuilder: (context, index) {
        final playlist = _friendData['playlists'][index];
        return _buildPlaylistItem(playlist);
      },
    );
  }

  Widget _buildActivityTabContent() {
    return ListView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Prevent scrolling conflict
      padding: EdgeInsets.zero,
      itemCount: _friendData['recentActivity'].length,
      itemBuilder: (context, index) {
        final activity = _friendData['recentActivity'][index];
        return _buildActivityItem(activity);
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildArtistItem(Map<String, dynamic> artist) {
    return GestureDetector(
      onTap: () {
        // Navigate to artist page
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(artist['image']),
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
            const SizedBox(height: 8),
            Text(
              artist['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackItem(Map<String, dynamic> track, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(track['cover']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.3),
              ),
              child: const Center(
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ],
        ),
        title: Text(
          track['title'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track['artist'],
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(track['playedAt']),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () {},
        ),
        onTap: () {
          // Play the track
        },
      ),
    );
  }

  Widget _buildPlaylistItem(Map<String, dynamic> playlist) {
    return GestureDetector(
      onTap: () {
        // Navigate to playlist
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist cover
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: NetworkImage(playlist['cover']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Playlist info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist['name'],
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
                    playlist['description'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${playlist['trackCount']} tracks',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFEC4899),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        playlist['followers'],
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    IconData iconData;
    Color iconColor;

    switch (activity['type']) {
      case 'liked':
        iconData = Icons.favorite;
        iconColor = const Color(0xFFEC4899);
        break;
      case 'playlist':
        iconData = Icons.playlist_add;
        iconColor = const Color(0xFF6366F1);
        break;
      case 'listening':
        iconData = Icons.headphones;
        iconColor = const Color(0xFF10B981);
        break;
      default:
        iconData = Icons.music_note;
        iconColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['content'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(activity['timeAgo']),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FriendProfileWavePainter extends CustomPainter {
  final double animationValue;

  FriendProfileWavePainter(this.animationValue);

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
