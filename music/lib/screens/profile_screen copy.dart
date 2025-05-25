import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  
  // Sample user data
  final Map<String, dynamic> _userData = {
    'username': 'Sarah Johnson',
    'handle': '@sarahmusic',
    'bio': 'Music producer | DJ | Vinyl collector\nLover of all things audio 🎵\nBooking: sarah@musicwave.com',
    'profileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
    'coverImage': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
    'followers': '24.5K',
    'following': '867',
    'posts': '342',
    'verified': true,
    'location': 'Los Angeles, CA',
    'website': 'musicwave.com/sarah',
    'joinDate': 'Joined March 2018',
  };
  
  // Sample posts data
  final List<Map<String, dynamic>> _musicPosts = [
    {
      'type': 'track',
      'title': 'Summer Vibes',
      'artist': 'Sarah Johnson',
      'coverArt': 'https://images.unsplash.com/photo-1487180144351-b8472da7d491?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1472&q=80',
      'duration': '3:45',
      'plays': '1.2M',
      'date': '2 weeks ago',
    },
    {
      'type': 'track',
      'title': 'Midnight Dreams',
      'artist': 'Sarah Johnson ft. Alex Rivera',
      'coverArt': 'https://images.unsplash.com/photo-1614149162883-504ce4d13909?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1374&q=80',
      'duration': '4:12',
      'plays': '876K',
      'date': '1 month ago',
    },
    {
      'type': 'track',
      'title': 'Electric Soul',
      'artist': 'Sarah Johnson',
      'coverArt': 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80',
      'duration': '3:28',
      'plays': '2.3M',
      'date': '3 months ago',
    },
  ];
  
  final List<Map<String, dynamic>> _playlistPosts = [
    {
      'title': 'Morning Chill',
      'description': 'Start your day with these relaxing tunes',
      'coverArt': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1374&q=80',
      'tracks': '24 tracks',
      'followers': '12.4K',
      'date': '1 week ago',
    },
    {
      'title': 'Workout Mix 2023',
      'description': 'High energy tracks to fuel your workout',
      'coverArt': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
      'tracks': '32 tracks',
      'followers': '45.7K',
      'date': '2 weeks ago',
    },
    {
      'title': 'Late Night Vibes',
      'description': 'Perfect for those late night sessions',
      'coverArt': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
      'tracks': '18 tracks',
      'followers': '32.1K',
      'date': '1 month ago',
    },
  ];
  
  final List<Map<String, dynamic>> _albumPosts = [
    {
      'title': 'Neon Dreams',
      'artist': 'Sarah Johnson',
      'coverArt': 'https://images.unsplash.com/photo-1496293455970-f8581aae0e3b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1626&q=80',
      'tracks': '12 tracks',
      'releaseDate': 'Released: Jan 15, 2023',
      'plays': '4.5M',
    },
    {
      'title': 'Urban Echoes',
      'artist': 'Sarah Johnson',
      'coverArt': 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80',
      'tracks': '10 tracks',
      'releaseDate': 'Released: Aug 3, 2022',
      'plays': '6.2M',
    },
  ];
  
  final List<Map<String, dynamic>> _artistPosts = [
    {
      'name': 'Alex Rivera',
      'genre': 'Electronic, House',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      'followers': '1.2M',
      'date': 'Collaborated 2 weeks ago',
    },
    {
      'name': 'DJ Maximus',
      'genre': 'EDM, Dubstep',
      'image': 'https://randomuser.me/api/portraits/men/45.jpg',
      'followers': '3.4M',
      'date': 'Collaborated 1 month ago',
    },
    {
      'name': 'Luna Ray',
      'genre': 'Pop, R&B',
      'image': 'https://randomuser.me/api/portraits/women/22.jpg',
      'followers': '2.8M',
      'date': 'Collaborated 3 months ago',
    },
  ];
  
  final List<Map<String, dynamic>> _otherPosts = [
    {
      'type': 'text',
      'content': 'Just finished recording my new track! Can\'t wait to share it with you all next week. Stay tuned! 🎵 #newmusic #comingsoon',
      'likes': '3.2K',
      'comments': '245',
      'shares': '87',
      'date': '2 days ago',
    },
    {
      'type': 'event',
      'title': 'Summer Beach Festival',
      'location': 'Venice Beach, CA',
      'date': 'July 15, 2023',
      'image': 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
      'attending': '12.5K',
      'interested': '34.2K',
    },
    {
      'type': 'text',
      'content': 'Just got my hands on this vintage vinyl collection! Absolute gems in here. What\'s your favorite vinyl record? 💿 #vinylcollection #musiclover',
      'likes': '5.7K',
      'comments': '432',
      'shares': '156',
      'date': '1 week ago',
      'image': 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
    },
  ];
  
  // About section data
  final Map<String, dynamic> _aboutData = {
    'bio': 'Music producer and DJ based in Los Angeles. I specialize in electronic, house, and ambient music. I\'ve been producing music for over 10 years and have released 5 albums and numerous singles.',
    'influences': ['Daft Punk', 'Bonobo', 'Tycho', 'Four Tet', 'Jon Hopkins'],
    'equipment': ['Ableton Live', 'Native Instruments Komplete', 'Roland TR-8', 'Moog Sub 37', 'Pioneer DJ equipment'],
    'education': 'Berklee College of Music, Electronic Music Production',
    'awards': [
      'Best New Artist - Electronic Music Awards 2019',
      'Best House Track - DJ Mag Awards 2021',
      'Producer of the Year - LA Music Scene 2022'
    ],
    'contact': {
      'email': 'sarah@musicwave.com',
      'booking': 'booking@sarahjohnson.com',
      'management': 'mgmt@wavelength.com'
    }
  };
  
  // Photos data
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
    'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
    'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
    'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
    'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1374&q=80',
    'https://images.unsplash.com/photo-1603048588665-791ca8aea617?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
    'https://images.unsplash.com/photo-1598387993281-cecf8b71a8f8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1476&q=80',
    'https://images.unsplash.com/photo-1574169208507-84376144848b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1479&q=80',
    'https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // App Bar with Cover Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  _showProfileOptions(context);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover image
                  CachedNetworkImage(
                    imageUrl: _userData['coverImage'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFF2A2A2A),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF2A2A2A),
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Info Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(bottom: 16),
              color: const Color(0xFF1A1A1A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile picture, name, and follow button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Profile picture
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: -50),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF1A1A1A),
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(46),
                            child: CachedNetworkImage(
                              imageUrl: _userData['profileImage'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFF2A2A2A),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF2A2A2A),
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Name and handle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _userData['username'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_userData['verified'])
                                    Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      child: const Icon(
                                        Icons.verified,
                                        color: Color(0xFF6366F1),
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                _userData['handle'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Follow button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isFollowing = !_isFollowing;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
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
                  ),

                  // Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _userData['bio'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats (followers, following, posts)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildStatItem(_userData['posts'], 'Posts'),
                        const SizedBox(width: 24),
                        _buildStatItem(_userData['followers'], 'Followers'),
                        const SizedBox(width: 24),
                        _buildStatItem(_userData['following'], 'Following'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location, website, join date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _userData['location'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.link,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _userData['website'],
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _userData['joinDate'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(Icons.message, 'Message'),
                        _buildActionButton(Icons.share, 'Share'),
                        _buildActionButton(Icons.notifications, 'Notify'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFF6366F1),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Music'),
                  Tab(text: 'Playlists'),
                  Tab(text: 'Albums'),
                  Tab(text: 'Artists'),
                  Tab(text: 'Posts'),
                  Tab(text: 'About'),
                  Tab(text: 'Photos'),
                ],
              ),
            ),
            pinned: true,
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Music Tab
                _buildMusicTab(),
                
                // Playlists Tab
                _buildPlaylistsTab(),
                
                // Albums Tab
                _buildAlbumsTab(),
                
                // Artists Tab
                _buildArtistsTab(),
                
                // Posts Tab
                _buildPostsTab(),
                
                // About Tab
                _buildAboutTab(),
                
                // Photos Tab
                _buildPhotosTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: const Color(0xFF1A1A1A),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1496293455970-f8581aae0e3b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1626&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Neon Dreams',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Sarah Johnson',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.pause, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Music Tab
  Widget _buildMusicTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _musicPosts.length,
      itemBuilder: (context, index) {
        final post = _musicPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(post['coverArt']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              post['title'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['artist'],
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      post['plays'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      post['duration'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      post['date'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  // Playlists Tab
  Widget _buildPlaylistsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _playlistPosts.length,
      itemBuilder: (context, index) {
        final playlist = _playlistPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Playlist cover image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  playlist['coverArt'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist['description'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.queue_music, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          playlist['tracks'],
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.people, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          playlist['followers'],
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          playlist['date'],
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.play_arrow, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Play',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Albums Tab
  Widget _buildAlbumsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _albumPosts.length,
      itemBuilder: (context, index) {
        final album = _albumPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album cover
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  album['coverArt'],
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        album['artist'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        album['tracks'],
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        album['releaseDate'],
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.play_arrow, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            album['plays'],
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Play',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Artists Tab
  Widget _buildArtistsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _artistPosts.length,
      itemBuilder: (context, index) {
        final artist = _artistPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
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
            title: Text(
              artist['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist['genre'],
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      artist['followers'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      artist['date'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Posts Tab
  Widget _buildPostsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _otherPosts.length,
      itemBuilder: (context, index) {
        final post = _otherPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post header with profile pic and name
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(_userData['profileImage']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _userData['username'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_userData['verified'])
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                child: const Icon(
                                  Icons.verified,
                                  color: Color(0xFF6366F1),
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          post['date'],
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Post content
                Text(
                  post['content'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                
                // Post image if available
                if (post['image'] != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post['image'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                
                // Event details if it's an event post
                if (post['type'] == 'event') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              post['location'],
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              post['date'],
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Interested',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Going',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Post stats (likes, comments, shares)
                Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      post['likes'] ?? '0',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment_outlined, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      post['comments'] ?? '0',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      post['shares'] ?? '0',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // About Tab
  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bio section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bio',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _aboutData['bio'],
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Influences section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Influences',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_aboutData['influences'] as List).map((influence) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      influence,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Equipment section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Equipment',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (_aboutData['equipment'] as List).map((equipment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFF6366F1), size: 8),
                        const SizedBox(width: 8),
                        Text(
                          equipment,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Education section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Education',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.school, color: Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _aboutData['education'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Awards section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Awards',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (_aboutData['awards'] as List).map((award) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            award,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Contact section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, color: Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _aboutData['contact']['email'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _aboutData['contact']['booking'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.business, color: Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _aboutData['contact']['management'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Photos Tab
  Widget _buildPhotosTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Show full screen image
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: _photos[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFF2A2A2A),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF2A2A2A),
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionItem(Icons.share, 'Share Profile'),
              _buildOptionItem(Icons.qr_code, 'QR Code'),
              _buildOptionItem(Icons.block, 'Block User'),
              _buildOptionItem(Icons.flag, 'Report User'),
              _buildOptionItem(Icons.notifications_off, 'Mute Notifications'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}