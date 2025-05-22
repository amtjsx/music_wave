import 'package:flutter/material.dart';

void main() {
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        colorScheme: ColorScheme.dark(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// New Main Navigation Screen that contains the bottom navigation
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    const MusicPlayerScreen(), // Home tab shows the music player
    const ExploreScreen(),
    const LiveScreen(),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Required for more than 3 items
        backgroundColor: Colors.grey[900],
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Existing Music Player Screen (now used as the Home tab)
class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({Key? key}) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  double currentValue = 0.0;
  int currentSongIndex = 0;

  // Controller for the draggable sheet
  final DraggableScrollableController _playlistController =
      DraggableScrollableController();
  bool _isPlaylistExpanded = false;

  final List<Song> playlist = [
    Song(
      title: "Blinding Lights",
      artist: "The Weeknd",
      albumArt: "https://via.placeholder.com/400?text=Blinding+Lights",
      duration: "3:20",
    ),
    Song(
      title: "Save Your Tears",
      artist: "The Weeknd",
      albumArt: "https://via.placeholder.com/400?text=Save+Your+Tears",
      duration: "3:35",
    ),
    Song(
      title: "Starboy",
      artist: "The Weeknd ft. Daft Punk",
      albumArt: "https://via.placeholder.com/400?text=Starboy",
      duration: "3:50",
    ),
    Song(
      title: "Shape of You",
      artist: "Ed Sheeran",
      albumArt: "https://via.placeholder.com/400?text=Shape+of+You",
      duration: "3:54",
    ),
    Song(
      title: "Levitating",
      artist: "Dua Lipa",
      albumArt: "https://via.placeholder.com/400?text=Levitating",
      duration: "3:23",
    ),
    Song(
      title: "Stay",
      artist: "The Kid LAROI, Justin Bieber",
      albumArt: "https://via.placeholder.com/400?text=Stay",
      duration: "2:21",
    ),
    Song(
      title: "Montero",
      artist: "Lil Nas X",
      albumArt: "https://via.placeholder.com/400?text=Montero",
      duration: "2:17",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Listen to changes in the draggable sheet
    _playlistController.addListener(_onPlaylistDrag);
  }

  void _onPlaylistDrag() {
    // Update expanded state based on sheet position
    final isExpanded = _playlistController.size > 0.5;
    if (isExpanded != _isPlaylistExpanded) {
      setState(() {
        _isPlaylistExpanded = isExpanded;
      });
    }
  }

  @override
  void dispose() {
    _playlistController.removeListener(_onPlaylistDrag);
    _playlistController.dispose();
    super.dispose();
  }

  void _togglePlaylistExpansion() {
    final targetSize = _isPlaylistExpanded ? 0.4 : 0.9;
    _playlistController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = playlist[currentSongIndex];

    return Scaffold(
      appBar:
          _isPlaylistExpanded
              ? null // Hide app bar when playlist is expanded
              : AppBar(
                title: const Text('Music Player'),
                elevation: 0,
                actions: [
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
      body: Stack(
        children: [
          // Now Playing Section (visible when playlist is not expanded)
          AnimatedOpacity(
            opacity: _isPlaylistExpanded ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: NowPlayingSection(
              song: currentSong,
              isPlaying: isPlaying,
              currentValue: currentValue,
              onPlayPause: () {
                setState(() {
                  isPlaying = !isPlaying;
                });
              },
              onPrevious: () {
                setState(() {
                  if (currentSongIndex > 0) {
                    currentSongIndex--;
                    currentValue = 0.0;
                  }
                });
              },
              onNext: () {
                setState(() {
                  if (currentSongIndex < playlist.length - 1) {
                    currentSongIndex++;
                    currentValue = 0.0;
                  }
                });
              },
              onSliderChanged: (value) {
                setState(() {
                  currentValue = value;
                });
              },
            ),
          ),

          // Draggable Playlist Section
          DraggableScrollableSheet(
            initialChildSize: 0.4, // Initial height (40% of screen)
            minChildSize: 0.1, // Minimum height when collapsed
            maxChildSize: 0.9, // Maximum height when expanded
            controller: _playlistController,
            builder: (context, scrollController) {
              return PlaylistSection(
                playlist: playlist,
                currentIndex: currentSongIndex,
                scrollController: scrollController,
                isExpanded: _isPlaylistExpanded,
                onTap: (index) {
                  setState(() {
                    currentSongIndex = index;
                    currentValue = 0.0;
                    isPlaying = true;

                    // Collapse playlist when a song is selected
                    if (_isPlaylistExpanded) {
                      _togglePlaylistExpansion();
                    }
                  });
                },
                onHeaderTap: _togglePlaylistExpansion,
                currentSong: currentSong,
                playlistController: _playlistController,
              );
            },
          ),
        ],
      ),
    );
  }
}

// New screen for Explore tab
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView(
        children: [
          // Featured playlists section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Featured Playlists',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      5,
                      (index) => Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              child: Image.network(
                                'https://via.placeholder.com/160?text=Playlist+${index + 1}',
                                height: 120,
                                width: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Playlist ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${10 + index} songs',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // New releases section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Releases',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://via.placeholder.com/200?text=Album+${index + 1}',
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'New Album ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Artist ${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// New screen for Live tab
class LiveScreen extends StatelessWidget {
  const LiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Live now section
          const Text(
            'Live Now',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Live event cards
          ...List.generate(
            3,
            (index) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.grey[850],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          'https://via.placeholder.com/400x200?text=Live+Event+${index + 1}',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${1000 + index * 500} viewers',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Concert ${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Artist ${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text('Join Stream'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Upcoming section
          const SizedBox(height: 24),
          const Text(
            'Upcoming',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Upcoming event list
          ...List.generate(
            4,
            (index) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://via.placeholder.com/60?text=Event+${index + 1}',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text('Upcoming Event ${index + 1}'),
              subtitle: Text(
                'In ${index + 2} days • Artist ${index + 4}',
                style: TextStyle(color: Colors.grey[400]),
              ),
              trailing: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: const Text('Remind'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// New screen for Library tab
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Library'),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Tab(text: 'Playlists'),
              Tab(text: 'Artists'),
              Tab(text: 'Albums'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Playlists tab
            ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Icon(
                        index % 3 == 0 ? Icons.favorite : Icons.music_note,
                        color: index % 3 == 0 ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                  title: Text('Playlist ${index + 1}'),
                  subtitle: Text('${10 + index} songs'),
                  trailing: const Icon(Icons.more_vert),
                );
              },
            ),

            // Artists tab
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/120?text=Artist+${index + 1}',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Artist ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${index + 5} albums',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                );
              },
            ),

            // Albums tab
            ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      'https://via.placeholder.com/50?text=Album+${index + 1}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text('Album ${index + 1}'),
                  subtitle: Text('Artist ${index % 3 + 1}'),
                  trailing: const Icon(Icons.more_vert),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// New screen for Profile tab
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/100?text=User',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'John Doe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '@johndoe',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          '245',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Following',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      color: Colors.grey[700],
                    ),
                    Column(
                      children: [
                        const Text(
                          '12.4K',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Followers',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 40),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),

          // Divider
          Divider(color: Colors.grey[800]),

          // Stats section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Stats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        Icons.headphones,
                        '128',
                        'Hours Listened',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        Icons.favorite,
                        '87',
                        'Liked Songs',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        Icons.playlist_play,
                        '14',
                        'Playlists',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        Icons.album,
                        '32',
                        'Albums',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Recently played
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recently Played',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      5,
                      (index) => Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://via.placeholder.com/120?text=Recent+${index + 1}',
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Song ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Artist ${index % 3 + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

class NowPlayingSection extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final double currentValue;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<double> onSliderChanged;

  const NowPlayingSection({
    Key? key,
    required this.song,
    required this.isPlaying,
    required this.currentValue,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onSliderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              song.albumArt,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.music_note,
                    size: 80,
                    color: Colors.white54,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),

          // Song Info
          Text(
            song.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            song.artist,
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Progress Bar
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Theme.of(context).colorScheme.secondary,
              inactiveTrackColor: Colors.grey[700],
              thumbColor: Theme.of(context).colorScheme.secondary,
              overlayColor: Theme.of(
                context,
              ).colorScheme.secondary.withOpacity(0.3),
            ),
            child: Slider(
              value: currentValue,
              min: 0.0,
              max: 100.0,
              onChanged: onSliderChanged,
            ),
          ),

          // Time Indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(currentValue),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                Text(
                  song.duration,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shuffle),
                onPressed: () {},
                iconSize: 24,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: onPrevious,
                iconSize: 40,
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: onPlayPause,
                  iconSize: 40,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: onNext,
                iconSize: 40,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.repeat),
                onPressed: () {},
                iconSize: 24,
                color: Colors.grey[400],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(double value) {
    // Convert slider value to time format
    final int seconds = (value / 100 * 200).round();
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class PlaylistSection extends StatelessWidget {
  final List<Song> playlist;
  final int currentIndex;
  final Function(int) onTap;
  final ScrollController scrollController;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final Song currentSong;
  final DraggableScrollableController playlistController;

  const PlaylistSection({
    Key? key,
    required this.playlist,
    required this.currentIndex,
    required this.onTap,
    required this.scrollController,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.currentSong,
    required this.playlistController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isExpanded ? 0 : 30),
          topRight: Radius.circular(isExpanded ? 0 : 30),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          DragHandle(
            playlistController: playlistController,
            isExpanded: isExpanded,
            onTap: onHeaderTap,
          ),

          // Playlist Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Text(
                  isExpanded ? "Playlist" : "Up Next",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isExpanded)
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: onHeaderTap,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.playlist_play),
                    onPressed: onHeaderTap,
                  ),
              ],
            ),
          ),

          // Now Playing Bar (only in expanded view)
          if (isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              color: Colors.grey[850],
              child: Row(
                children: [
                  const Text(
                    "NOW PLAYING",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${currentSong.title} • ${currentSong.artist}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Playlist Items
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                final song = playlist[index];
                final isSelected = index == currentIndex;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      song.albumArt,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            size: 20,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.equalizer,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        song.duration,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () => onTap(index),
                  selected: isSelected,
                  selectedTileColor: Colors.grey[850],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Drag Handle widget with proper drag gesture support
class DragHandle extends StatefulWidget {
  final DraggableScrollableController playlistController;
  final bool isExpanded;
  final VoidCallback onTap;

  const DragHandle({
    Key? key,
    required this.playlistController,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle> {
  double _dragStartPosition = 0;
  double _dragStartSize = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      // Handle vertical drag to move the sheet
      onVerticalDragStart: (details) {
        _dragStartPosition = details.globalPosition.dy;
        _dragStartSize = widget.playlistController.size;
      },
      onVerticalDragUpdate: (details) {
        // Calculate how much the user has dragged
        final dragDistance = details.globalPosition.dy - _dragStartPosition;

        // Convert to a size change (negative because dragging down should decrease size)
        final sizeDelta = -dragDistance / MediaQuery.of(context).size.height;

        // Calculate new size and clamp it to valid range
        final newSize = (_dragStartSize + sizeDelta).clamp(0.1, 0.9);

        // Update the sheet position
        widget.playlistController.jumpTo(newSize);
      },
      onVerticalDragEnd: (details) {
        // Snap to either expanded or collapsed state based on velocity and current position
        final currentSize = widget.playlistController.size;
        final targetSize =
            (currentSize > 0.5 || details.velocity.pixelsPerSecond.dy < -300)
                ? 0.9
                : 0.4;

        widget.playlistController.animateTo(
          targetSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.transparent, // Make the entire area draggable
        child: Column(
          children: [
            // Visual drag handle indicator
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Add a small text hint for better UX
            if (!widget.isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Drag to expand",
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Song {
  final String title;
  final String artist;
  final String albumArt;
  final String duration;

  Song({
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.duration,
  });
}
