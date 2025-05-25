import 'dart:math' as math;

import 'package:flutter/material.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late TabController _tabController;
  late ScrollController _scrollController;

  bool _showAppBarTitle = false;
  String _currentSort = 'Most Popular';
  final List<String> _sortOptions = [
    'Most Popular',
    'Rising Fast',
    'New Entries',
    'This Week',
    'This Month',
  ];

  // Sample data for trending items
  final List<Map<String, dynamic>> _trendingSongs = [
    {
      'id': 'song1',
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'album': 'After Hours',
      'image': 'https://picsum.photos/400/400?random=201',
      'plays': 4250000,
      'change': '+15%',
      'duration': '3:20',
      'trending_position': 1,
      'previous_position': 2,
      'release_date': '2019-11-29',
      'genre': 'Synth-pop',
      'explicit': false,
      'liked': true,
    },
    {
      'id': 'song2',
      'title': 'As It Was',
      'artist': 'Harry Styles',
      'album': 'Harry\'s House',
      'image': 'https://picsum.photos/400/400?random=202',
      'plays': 3890000,
      'change': '+8%',
      'duration': '2:47',
      'trending_position': 2,
      'previous_position': 3,
      'release_date': '2022-04-01',
      'genre': 'Synth-pop',
      'explicit': false,
      'liked': false,
    },
    {
      'id': 'song3',
      'title': 'Heat Waves',
      'artist': 'Glass Animals',
      'album': 'Dreamland',
      'image': 'https://picsum.photos/400/400?random=203',
      'plays': 3650000,
      'change': '+23%',
      'duration': '3:59',
      'trending_position': 3,
      'previous_position': 7,
      'release_date': '2020-06-29',
      'genre': 'Indie pop',
      'explicit': false,
      'liked': true,
    },
    {
      'id': 'song4',
      'title': 'Stay',
      'artist': 'The Kid LAROI, Justin Bieber',
      'album': 'F*CK LOVE 3: OVER YOU',
      'image': 'https://picsum.photos/400/400?random=204',
      'plays': 3420000,
      'change': '-5%',
      'duration': '2:21',
      'trending_position': 4,
      'previous_position': 1,
      'release_date': '2021-07-09',
      'genre': 'Pop',
      'explicit': true,
      'liked': false,
    },
    {
      'id': 'song5',
      'title': 'Easy On Me',
      'artist': 'Adele',
      'album': '30',
      'image': 'https://picsum.photos/400/400?random=205',
      'plays': 3180000,
      'change': '+2%',
      'duration': '3:44',
      'trending_position': 5,
      'previous_position': 5,
      'release_date': '2021-10-15',
      'genre': 'Pop',
      'explicit': false,
      'liked': true,
    },
    {
      'id': 'song6',
      'title': 'Bad Habits',
      'artist': 'Ed Sheeran',
      'album': '=',
      'image': 'https://picsum.photos/400/400?random=206',
      'plays': 2950000,
      'change': '-3%',
      'duration': '3:51',
      'trending_position': 6,
      'previous_position': 4,
      'release_date': '2021-06-25',
      'genre': 'Pop',
      'explicit': false,
      'liked': false,
    },
    {
      'id': 'song7',
      'title': 'Woman',
      'artist': 'Doja Cat',
      'album': 'Planet Her',
      'image': 'https://picsum.photos/400/400?random=207',
      'plays': 2780000,
      'change': '+10%',
      'duration': '2:52',
      'trending_position': 7,
      'previous_position': 9,
      'release_date': '2021-06-25',
      'genre': 'R&B',
      'explicit': true,
      'liked': true,
    },
    {
      'id': 'song8',
      'title': 'Good 4 U',
      'artist': 'Olivia Rodrigo',
      'album': 'SOUR',
      'image': 'https://picsum.photos/400/400?random=208',
      'plays': 2650000,
      'change': '-8%',
      'duration': '2:58',
      'trending_position': 8,
      'previous_position': 6,
      'release_date': '2021-05-14',
      'genre': 'Pop punk',
      'explicit': true,
      'liked': false,
    },
    {
      'id': 'song9',
      'title': 'INDUSTRY BABY',
      'artist': 'Lil Nas X, Jack Harlow',
      'album': 'MONTERO',
      'image': 'https://picsum.photos/400/400?random=209',
      'plays': 2520000,
      'change': '+5%',
      'duration': '3:32',
      'trending_position': 9,
      'previous_position': 10,
      'release_date': '2021-07-23',
      'genre': 'Hip hop',
      'explicit': true,
      'liked': true,
    },
    {
      'id': 'song10',
      'title': 'STAY',
      'artist': 'The Kid LAROI, Justin Bieber',
      'album': 'F*CK LOVE 3: OVER YOU',
      'image': 'https://picsum.photos/400/400?random=210',
      'plays': 2410000,
      'change': '+1%',
      'duration': '2:21',
      'trending_position': 10,
      'previous_position': 11,
      'release_date': '2021-07-09',
      'genre': 'Pop',
      'explicit': true,
      'liked': false,
    },
  ];

  final List<Map<String, dynamic>> _trendingArtists = [
    // Artist data remains the same
  ];

  final List<Map<String, dynamic>> _trendingPlaylists = [
    // Playlist data remains the same
  ];

  final List<Map<String, dynamic>> _trendingAlbums = [
    // Album data remains the same
  ];

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

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 120;
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
    _tabController.dispose();
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

  void _showSongOptions(Map<String, dynamic> song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Song info header
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(song['image']),
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
                              song['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song['artist'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  song['album'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${song['duration']}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                if (song['explicit'])
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Text(
                                      'E',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
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

                  const SizedBox(height: 24),

                  // Trending stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          '#${song['trending_position']}',
                          'Chart Position',
                          const Color(0xFF6366F1),
                        ),
                        _buildStatColumn(
                          _formatNumber(song['plays']),
                          'Total Plays',
                          Colors.green,
                        ),
                        _buildStatColumn(
                          song['change'],
                          'Weekly Change',
                          song['change'].startsWith('+')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        Icons.play_arrow,
                        'Play Now',
                        () => Navigator.pop(context),
                      ),
                      _buildActionButton(
                        Icons.playlist_add,
                        'Add to Playlist',
                        () => _showAddToPlaylistDialog(context, song),
                      ),
                      _buildActionButton(
                        song['liked'] ? Icons.favorite : Icons.favorite_border,
                        song['liked'] ? 'Liked' : 'Like',
                        () {
                          setState(() {
                            song['liked'] = !song['liked'];
                          });
                        },
                        color: song['liked'] ? Colors.red : null,
                      ),
                      _buildActionButton(
                        Icons.download,
                        'Download',
                        () => _showDownloadOptions(context, song),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Additional options
                  Column(
                    children: [
                      _buildOptionTile(
                        Icons.person,
                        'View Artist',
                        'Go to ${song['artist']}',
                        () => Navigator.pop(context),
                      ),
                      _buildOptionTile(
                        Icons.album,
                        'View Album',
                        'Go to ${song['album']}',
                        () => Navigator.pop(context),
                      ),
                      _buildOptionTile(
                        Icons.share,
                        'Share',
                        'Share this song with friends',
                        () => Navigator.pop(context),
                      ),
                      _buildOptionTile(
                        Icons.queue_music,
                        'Add to Queue',
                        'Play this song next',
                        () => Navigator.pop(context),
                      ),
                      _buildOptionTile(
                        Icons.radio,
                        'Start Radio',
                        'Create a station based on this song',
                        () => Navigator.pop(context),
                      ),
                      _buildOptionTile(
                        Icons.info_outline,
                        'Song Info',
                        'View detailed information',
                        () => _showSongInfo(context, song),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color ?? const Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: onTap,
    );
  }

  void _showAddToPlaylistDialog(
    BuildContext context,
    Map<String, dynamic> song,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Add to Playlist',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add, color: Color(0xFF6366F1)),
                    title: const Text(
                      'Create New Playlist',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(color: Colors.grey),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      children: [
                        _buildPlaylistItem('Favorites', '32 songs'),
                        _buildPlaylistItem('Workout Mix', '18 songs'),
                        _buildPlaylistItem('Chill Vibes', '45 songs'),
                        _buildPlaylistItem('Party Playlist', '28 songs'),
                        _buildPlaylistItem('Road Trip', '52 songs'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPlaylistItem(String name, String songCount) {
    return ListTile(
      title: Text(name, style: const TextStyle(color: Colors.white)),
      subtitle: Text(songCount, style: const TextStyle(color: Colors.grey)),
      onTap: () => Navigator.pop(context),
    );
  }

  void _showDownloadOptions(BuildContext context, Map<String, dynamic> song) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Download Options',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDownloadOption('Standard Quality', '128 kbps', '3.5 MB'),
                _buildDownloadOption('High Quality', '320 kbps', '9.2 MB'),
                _buildDownloadOption('HD Quality', 'FLAC', '27.8 MB'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDownloadOption(String quality, String bitrate, String size) {
    return ListTile(
      title: Text(quality, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        '$bitrate • $size',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.download, color: Color(0xFF6366F1)),
      onTap: () => Navigator.pop(context),
    );
  }

  void _showSongInfo(BuildContext context, Map<String, dynamic> song) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Song Information',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Title', song['title']),
                _buildInfoRow('Artist', song['artist']),
                _buildInfoRow('Album', song['album']),
                _buildInfoRow('Duration', song['duration']),
                _buildInfoRow('Genre', song['genre']),
                _buildInfoRow('Release Date', song['release_date']),
                _buildInfoRow('Explicit', song['explicit'] ? 'Yes' : 'No'),
                _buildInfoRow(
                  'Trending Position',
                  '#${song['trending_position']}',
                ),
                _buildInfoRow('Plays', _formatNumber(song['plays'])),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 150,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1A1A1A),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title:
                  _showAppBarTitle
                      ? const Text(
                        'Trending',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showSortOptions,
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
                          painter: TrendingWavePainter(_waveAnimation.value),
                          child: Container(),
                        );
                      },
                    ),

                    // Trending indicator
                    Positioned(
                      left: 16,
                      bottom: 48,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Color(0xFF6366F1),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'TRENDING NOW',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
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
                title:
                    !_showAppBarTitle
                        ? const Text(
                          'Trending',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF6366F1),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Songs'),
                  Tab(text: 'Artists'),
                  Tab(text: 'Playlists'),
                  Tab(text: 'Albums'),
                ],
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Sort info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTabTitle(),
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

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Songs tab
                  _buildSongsTab(),

                  // Artists tab
                  _buildArtistsTab(),

                  // Playlists tab
                  _buildPlaylistsTab(),

                  // Albums tab
                  _buildAlbumsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
       
 
    );
  }

  String _getTabTitle() {
    switch (_tabController.index) {
      case 0:
        return 'Trending Songs';
      case 1:
        return 'Trending Artists';
      case 2:
        return 'Trending Playlists';
      case 3:
        return 'Trending Albums';
      default:
        return 'Trending';
    }
  }

  Widget _buildSongsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _trendingSongs.length,
      itemBuilder: (context, index) {
        final song = _trendingSongs[index];
        final isPositionUp =
            song['trending_position'] < song['previous_position'];
        final isPositionDown =
            song['trending_position'] > song['previous_position'];
        final isPositionSame =
            song['trending_position'] == song['previous_position'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${song['trending_position']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(song['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (song['explicit'])
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'E',
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
                ),
              ],
            ),
            title: Text(
              song['title'],
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
                  song['artist'],
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.grey[600], size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(song['plays']),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.trending_up,
                      color:
                          song['change'].startsWith('+')
                              ? Colors.green
                              : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      song['change'],
                      style: TextStyle(
                        color:
                            song['change'].startsWith('+')
                                ? Colors.green
                                : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPositionUp)
                  const Icon(Icons.arrow_upward, color: Colors.green, size: 16)
                else if (isPositionDown)
                  const Icon(Icons.arrow_downward, color: Colors.red, size: 16)
                else
                  const Icon(Icons.remove, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () => _showSongOptions(song),
                ),
              ],
            ),
            onTap: () => _showSongOptions(song),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildArtistsTab() {
    // Artists tab implementation remains the same
    return Container();
  }

  Widget _buildPlaylistsTab() {
    // Playlists tab implementation remains the same
    return Container();
  }

  Widget _buildAlbumsTab() {
    // Albums tab implementation remains the same
    return Container();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class TrendingWavePainter extends CustomPainter {
  final double animationValue;

  TrendingWavePainter(this.animationValue);

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
