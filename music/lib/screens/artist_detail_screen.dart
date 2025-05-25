import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistId;

  const ArtistDetailScreen({Key? key, required this.artistId})
    : super(key: key);

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late AnimationController _waveController;
  late AnimationController _headerAnimationController;
  late Animation<double> _waveAnimation;
  late Animation<double> _headerAnimation;

  bool _showAppBarTitle = false;
  bool _isFollowing = false;
  bool _isPlaying = false;
  Map<String, dynamic> _artistData = {};
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _waveController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1.0,
    );

    _headerAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fetchArtistData();
  }

  Future<void> _fetchArtistData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call with a delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would fetch data from an API using the artistId
      // For example:
      // final response = await http.get(Uri.parse('https://api.example.com/artists/${widget.artistId}'));
      // final data = jsonDecode(response.body);

      // Mock data for demonstration
      final mockData = {
        'id': widget.artistId,
        'name': 'The Weeknd',
        'verified': true,
        'monthly_listeners': 85400000,
        'followers': 42300000,
        'profile_image': 'https://picsum.photos/200/200',
        'cover': 'https://picsum.photos/500/300',
        'genres': ['R&B', 'Pop', 'Alternative R&B'],
        'bio':
            'Abel Makkonen Tesfaye, known professionally as the Weeknd, is a Canadian singer, songwriter, and record producer. He is known for his sonic versatility and dark lyricism.',
        'top_tracks': [
          {
            'id': '1',
            'title': 'Blinding Lights',
            'album': 'After Hours',
            'duration': '3:20',
            'plays': 3200000000,
            'image': 'https://picsum.photos/200/200',
          },
          {
            'id': '2',
            'title': 'Save Your Tears',
            'album': 'After Hours',
            'duration': '3:35',
            'plays': 2100000000,
            'image': 'https://picsum.photos/200/200',
          },
          {
            'id': '3',
            'title': 'Starboy',
            'album': 'Starboy',
            'duration': '3:50',
            'plays': 2800000000,
            'image': 'https://picsum.photos/200/200',
          },
          {
            'id': '4',
            'title': 'Die For You',
            'album': 'Starboy',
            'duration': '4:20',
            'plays': 1500000000,
            'image': 'https://picsum.photos/200/200',
          },
          {
            'id': '5',
            'title': 'The Hills',
            'album': 'Beauty Behind the Madness',
            'duration': '3:41',
            'plays': 2000000000,
            'image': 'https://picsum.photos/200/200',
          },
        ],
        'albums': [
          {
            'id': '1',
            'title': 'After Hours',
            'year': 2020,
            'tracks': 14,
            'image': 'https://picsum.photos/200/200',
          },
          {
            'id': '2',
            'title': 'Starboy',
            'year': 2016,
            'tracks': 18,
            'image': 'https://picsum.photos/200/200',
          },
          {
            'id': '3',
            'title': 'Beauty Behind the Madness',
            'year': 2015,
            'tracks': 14,
            'image': 'https://picsum.photos/200/200',
          },
          {
            'id': '4',
            'title': 'Dawn FM',
            'year': 2022,
            'tracks': 16,
            'image': 'https://picsum.photos/200/200',
          },
        ],
      };

      setState(() {
        _artistData = mockData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error fetching artist data: $e');
    }
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    final bool shouldShowTitle = offset > 180;

    if (shouldShowTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = shouldShowTitle;
      });
    }

    // Parallax effect for header
    if (offset < 100) {
      _headerAnimationController.value = 1 + (offset / 1000);
    }
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });

    // In a real app, you would call an API to follow/unfollow the artist
    // For example:
    // final action = _isFollowing ? 'follow' : 'unfollow';
    // http.post(Uri.parse('https://api.example.com/artists/${widget.artistId}/$action'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowing
              ? 'Following ${_artistData['name']}'
              : 'Unfollowed ${_artistData['name']}',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    // In a real app, you would start/stop playing the artist's music
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPlaying ? 'Playing ${_artistData['name']}' : 'Paused'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showArtistOptions() {
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
            children: [
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text(
                  'Share',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Share functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text(
                  'Add to playlist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Add to playlist functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.white),
                title: const Text(
                  'Download',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Download functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.white),
                title: const Text(
                  'Don\'t play this artist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Block artist functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _waveController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Failed to load artist data',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchArtistData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1A1A1A),
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title:
                  _showAppBarTitle
                      ? Row(
                        children: [
                          // Add small profile photo in the app bar when collapsed
                          Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  _artistData['profile_image'],
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            _artistData['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_artistData['verified'])
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              child: const Icon(
                                Icons.verified,
                                color: Color(0xFF6366F1),
                                size: 16,
                              ),
                            ),
                        ],
                      )
                      : null,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _showArtistOptions,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _headerAnimation.value,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Cover image with gradient overlay
                          ShaderMask(
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black, Colors.transparent],
                              ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height),
                              );
                            },
                            blendMode: BlendMode.dstIn,
                            child: Image.network(
                              _artistData['cover'],
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Gradient overlay to ensure text readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.6, 0.8, 1.0],
                              ),
                            ),
                          ),

                          // Animated wave overlay
                          AnimatedBuilder(
                            animation: _waveAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: ArtistWavePainter(
                                  _waveAnimation.value,
                                ),
                                child: Container(),
                              );
                            },
                          ),

                          // Artist info overlay - centered with proper spacing from bottom
                          Positioned(
                            bottom:
                                70, // Increased to avoid overlap with tab bar
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                // Artist name and verified badge
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _artistData['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_artistData['verified'])
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: const Icon(
                                          Icons.verified,
                                          color: Color(0xFF6366F1),
                                          size: 24,
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Monthly listeners
                                Text(
                                  _formatNumber(
                                    _artistData['monthly_listeners'],
                                  ),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Follow button and play button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _toggleFollow,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _isFollowing
                                                ? Colors.transparent
                                                : const Color(0xFF6366F1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          side: BorderSide(
                                            color:
                                                _isFollowing
                                                    ? Colors.grey
                                                    : Colors.transparent,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                      ),
                                      child: Text(
                                        _isFollowing ? 'Following' : 'Follow',
                                        style: TextStyle(
                                          color:
                                              _isFollowing
                                                  ? Colors.grey
                                                  : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6366F1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          _isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: _togglePlayPause,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Profile photo - positioned at bottom left, above tab bar
                          Positioned(
                            left: 20,
                            bottom: 55, // Positioned above the tab bar
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF6366F1),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  _artistData['profile_image'],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                      Tab(text: 'Overview'),
                      Tab(text: 'Songs'),
                      Tab(text: 'Albums'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Overview Tab
            _buildOverviewTab(),

            // Songs Tab
            _buildSongsTab(),

            // Albums Tab
            _buildAlbumsTab(),

            // About Tab
            _buildAboutTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: [
        // Popular section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  _tabController.animateTo(1); // Switch to Songs tab
                },
                child: const Text(
                  'See all',
                  style: TextStyle(color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
        ),

        // Top tracks
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: math.min(5, _artistData['top_tracks'].length),
          itemBuilder: (context, index) {
            final track = _artistData['top_tracks'][index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(track['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                track['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${_formatNumber(track['plays'])} plays',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track['duration'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.more_vert, color: Colors.grey),
                ],
              ),
              onTap: () {
                // Play the track
              },
            );
          },
        ),

        const SizedBox(height: 24),

        // Albums section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Albums',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  _tabController.animateTo(2); // Switch to Albums tab
                },
                child: const Text(
                  'See all',
                  style: TextStyle(color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
        ),

        // Albums horizontal list
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _artistData['albums'].length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final album = _artistData['albums'][index];
              return GestureDetector(
                onTap: () {
                  // Play the album
                  context.push('/albums/${album['id']}');
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(album['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        album['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        album['year'].toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // Similar artists section (placeholder)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fans also like',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
        ),

        // Similar artists horizontal list (placeholder)
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              // Placeholder similar artists
              final names = [
                'Drake',
                'Post Malone',
                'Doja Cat',
                'Ariana Grande',
                'Bruno Mars',
              ];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://picsum.photos/200?random=${index + 10}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      names[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongsTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      itemCount: _artistData['top_tracks'].length,
      itemBuilder: (context, index) {
        final track = _artistData['top_tracks'][index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(track['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            track['title'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            track['album'],
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                track['duration'],
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          onTap: () {
            // Play the track
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _artistData['albums'].length,
      itemBuilder: (context, index) {
        final album = _artistData['albums'][index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(album['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album['title'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${album['year']} • ${album['tracks']} songs',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biography',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _artistData['bio'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Genres',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (_artistData['genres'] as List).map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      genre,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Listeners',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNumber(_artistData['monthly_listeners']),
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Followers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNumber(_artistData['followers']),
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ArtistWavePainter extends CustomPainter {
  final double animationValue;

  ArtistWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF6366F1).withOpacity(0.3),
              const Color(0xFF8B5CF6).withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.05;
    final waveLength = size.width * 0.5;
    final waveOffset = size.height * 0.85;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveOffset +
          waveHeight *
              math.sin((x / waveLength * 2 * math.pi) + animationValue);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave (offset)
    final path2 = Path();
    final waveHeight2 = size.height * 0.03;
    final waveLength2 = size.width * 0.7;
    final waveOffset2 = size.height * 0.9;

    path2.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          waveOffset2 +
          waveHeight2 *
              math.sin((x / waveLength2 * 2 * math.pi) + animationValue * 1.5);
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    final paint2 =
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF8B5CF6).withOpacity(0.2),
              const Color(0xFF6366F1).withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
