import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:music/models/artist.dart';
import 'package:music/models/playlist.dart';
import 'package:music/models/song.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late ScrollController _scrollController;
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  bool _showAppBarTitle = false;
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isReorderMode = false;
  bool _isSelectionMode = false;
  Set<String> _selectedSongs = {};

  // Sample playlist data
  final Playlist _playlistData = Playlist(
    id: 'playlist1',
    title: 'My Favorites',
    description:
        'All my favorite tracks in one place. A carefully curated collection of songs that never get old.',
    coverUrl: 'https://picsum.photos/400/400?random=601',
    songs: [
      Song(
        id: 'song1',
        title: 'Blinding Lights',
        artist: Artist(
          id: 'artist1',
          name: 'The Weeknd',
          imageUrl: 'https://picsum.photos/400/400?random=101',
          bio: 'The Weeknd is a Canadian singer, songwriter, and actor.',
          followers: 127,
          monthlyListeners: 127,
          genres: ['Pop', 'Hip-Hop'],
          popularSongs: [],
          albums: [],
          similarArtists: [],
        ),
        duration: '3:20',
        artistId: 'artist1',
        albumId: 'album1',
        audioUrl: 'https://picsum.photos/400/400?random=201',
        albumName: 'After Hours',
        albumArt: 'https://picsum.photos/400/400?random=201',
      ),
    ],
    creatorName: 'You',
    isOffline: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // Sample songs data
  final List<Song> _songs = [
    Song(
      id: 'song1',
      title: 'Blinding Lights',
      artist: Artist(
        id: 'artist1',
        name: 'The Weeknd',
        imageUrl: 'https://picsum.photos/400/400?random=101',
        bio: 'The Weeknd is a Canadian singer, songwriter, and actor.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '3:20',
      artistId: 'artist1',
      albumId: 'album1',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      albumName: 'After Hours',
      albumArt: 'https://picsum.photos/400/400?random=201',
    ),
    Song(
      id: 'song2',
      title: 'As It Was',
      artist: Artist(
        id: 'artist2',
        name: 'Harry Styles',
        imageUrl: 'https://picsum.photos/400/400?random=102',
        bio: 'Harry Styles is an English singer, songwriter, and actor.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '2:47',
      artistId: 'artist2',
      albumId: 'album2',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      albumName: 'Harry\'s House',
      albumArt: 'https://picsum.photos/400/400?random=202',
    ),
    Song(
      id: 'song3',
      title: 'Heat Waves',
      artist: Artist(
        id: 'artist3',
        name: 'Glass Animals',
        imageUrl: 'https://picsum.photos/400/400?random=103',
        bio: 'Glass Animals is an English indie rock band.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '3:59',
      artistId: 'artist3',
      albumId: 'album3',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      albumName: 'Dreamland',
      albumArt: 'https://picsum.photos/400/400?random=203',
    ),
    Song(
      id: 'song4',
      title: 'Stay',
      artist: Artist(
        id: 'artist4',
        name: 'The Kid LAROI, Justin Bieber',
        imageUrl: 'https://picsum.photos/400/400?random=104',
        bio: 'Harry Styles is an English singer, songwriter, and actor.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '2:47',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      albumName: 'F*CK LOVE 3: OVER YOU',
      albumArt: 'https://picsum.photos/400/400?random=204',
      artistId: 'artist4',
      albumId: 'album4',
    ),
    Song(
      id: 'song5',
      title: 'Heat Waves',
      artist: Artist(
        id: 'artist5',
        name: 'Glass Animals',
        imageUrl: 'https://picsum.photos/400/400?random=105',
        bio: 'Glass Animals is an English indie rock band.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '3:59',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      albumName: 'Dreamland',
      albumArt: 'https://picsum.photos/400/400?random=203',
      artistId: 'artist5',
      albumId: 'album5',
    ),
    Song(
      id: 'song6',
      title: 'Easy On Me',
      artist: Artist(
        id: 'artist6',
        name: 'Adele',
        imageUrl: 'https://picsum.photos/400/400?random=106',
        bio: 'Adele is an English singer, songwriter, and actress.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '3:44',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      albumName: 'Dreamland',
      albumArt: 'https://picsum.photos/400/400?random=203',
      artistId: 'artist6',
      albumId: 'album6',
    ),
    Song(
      id: 'song4',
      title: 'Stay',
      artist: Artist(
        id: 'artist4',
        name: 'The Kid LAROI, Justin Bieber',
        imageUrl: 'https://picsum.photos/400/400?random=104',
        bio: 'Harry Styles is an English singer, songwriter, and actor.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '2:21',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      artistId: 'artist6',
      albumId: 'album6',
      albumName: 'F*CK LOVE 3: OVER YOU',
      albumArt: 'https://picsum.photos/400/400?random=204',
    ),
    Song(
      id: 'song5',
      title: 'Easy On Me',
      artist: Artist(
        id: 'artist5',
        name: 'Adele',
        imageUrl: 'https://picsum.photos/400/400?random=105',
        bio: 'Adele is an English singer, songwriter, and actress.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '3:44',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      albumName: 'Dreamland',
      albumArt: 'https://picsum.photos/400/400?random=203',
      artistId: 'artist6',
      albumId: 'album6',
    ),
    Song(
      id: 'song6',
      title: 'Bad Habits',
      artist: Artist(
        id: 'artist6',
        name: 'Ed Sheeran',
        imageUrl: 'https://picsum.photos/400/400?random=106',
        bio: 'Adele is an English singer, songwriter, and actress.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '3:51',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      albumName: 'Dreamland',
      albumArt: 'https://picsum.photos/400/400?random=203',
      artistId: 'artist6',
      albumId: 'album6',
    ),
    Song(
      id: 'song7',
      title: 'Woman',
      artist: Artist(
        id: 'artist7',
        name: 'Doja Cat',
        imageUrl: 'https://picsum.photos/400/400?random=107',
        bio: 'Adele is an English singer, songwriter, and actress.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '2:52',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      albumName: 'Dreamland',
      albumArt: 'https://picsum.photos/400/400?random=203',
      artistId: 'artist6',
      albumId: 'album6',
    ),
    Song(
      id: 'song8',
      title: 'Good 4 U',
      artist: Artist(
        id: 'artist8',
        name: 'Olivia Rodrigo',
        imageUrl: 'https://picsum.photos/400/400?random=108',
        bio: 'Adele is an English singer, songwriter, and actress.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '2:58',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      albumName: 'Dreamland',
      albumArt: 'https://picsum.photos/400/400?random=203',
      artistId: 'artist6',
      albumId: 'album6',
    ),
    Song(
      id: 'song8',
      title: 'Good 4 U',
      artist: Artist(
        id: 'artist8',
        name: 'Olivia Rodrigo',
        imageUrl: 'https://picsum.photos/400/400?random=108',
        bio: 'Adele is an English singer, songwriter, and actress.',
        followers: 127,
        monthlyListeners: 127,
        genres: ['Pop', 'Hip-Hop'],
        popularSongs: [],
        albums: [],
        similarArtists: [],
      ),
      duration: '2:58',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      albumName: 'Dreamland',
      albumArt: 'https://picsum.photos/400/400?random=203',
      artistId: 'artist6',
      albumId: 'album6',
    ),
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

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeInOut),
    );

    _headerController.forward();
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
    _headerController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffled = !_isShuffled;
    });
  }

  void _toggleReorderMode() {
    setState(() {
      _isReorderMode = !_isReorderMode;
      _isSelectionMode = false;
      _selectedSongs.clear();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _isReorderMode = false;
      _selectedSongs.clear();
    });
  }

  void _toggleSongSelection(String songId) {
    setState(() {
      if (_selectedSongs.contains(songId)) {
        _selectedSongs.remove(songId);
      } else {
        _selectedSongs.add(songId);
      }

      if (_selectedSongs.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _showPlaylistOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Playlist info header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(_playlistData.coverUrl!),
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
                          _playlistData.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'By ${_playlistData.creatorName}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_playlistData.songs.length} songs • ${_playlistData.createdAt}',
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

              const SizedBox(height: 24),

              // Playlist stats
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
                      '${_playlistData.playCount}',
                      'Times Played',
                      const Color(0xFF6366F1),
                    ),
                    _buildStatColumn(
                      _formatNumber(_playlistData.playCount),
                      'Total Plays',
                      Colors.green,
                    ),
                    _buildStatColumn(
                      _playlistData.createdAt.toString(),
                      'Created',
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Options
              Column(
                children: [
                  if (_playlistData.creatorName == 'You') ...[
                    _buildOptionTile(
                      Icons.edit,
                      'Edit Details',
                      'Change title, description, and cover',
                      () => Navigator.pop(context),
                    ),
                    _buildOptionTile(
                      Icons.add,
                      'Add Songs',
                      'Add more songs to this playlist',
                      () => Navigator.pop(context),
                    ),
                    _buildOptionTile(
                      Icons.sort,
                      'Reorder Songs',
                      'Change the order of songs',
                      () {
                        Navigator.pop(context);
                        _toggleReorderMode();
                      },
                    ),
                    _buildOptionTile(
                      Icons.people,
                      'Make Collaborative',
                      'Let friends add songs',
                      () => Navigator.pop(context),
                    ),
                  ],
                  _buildOptionTile(
                    Icons.download,
                    _playlistData.isOffline ? 'Downloaded' : 'Download',
                    _playlistData.isOffline
                        ? 'Available offline'
                        : 'Make available offline',
                    () => Navigator.pop(context),
                  ),
                  _buildOptionTile(
                    Icons.share,
                    'Share Playlist',
                    'Share with friends',
                    () => Navigator.pop(context),
                  ),
                  _buildOptionTile(
                    Icons.radio,
                    'Start Radio',
                    'Play similar songs',
                    () => Navigator.pop(context),
                  ),
                  if (_playlistData.creatorName == 'You')
                    _buildOptionTile(
                      Icons.delete_outline,
                      'Delete Playlist',
                      'Remove this playlist',
                      () => Navigator.pop(context),
                      isDestructive: true,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSongOptions(Song song) {
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
              // Song info header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(song.albumArt),
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
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artist.name,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Song options
              Column(
                children: [
                  _buildOptionTile(
                    Icons.play_arrow,
                    'Play Now',
                    'Play this song',
                    () => Navigator.pop(context),
                  ),
                  _buildOptionTile(
                    Icons.queue_music,
                    'Add to Queue',
                    'Play this song next',
                    () => Navigator.pop(context),
                  ),
                  _buildOptionTile(
                    song.isLike ? Icons.favorite : Icons.favorite_border,
                    song.isLike ? 'Remove from Liked' : 'Add to Liked',
                    song.isLike
                        ? 'Remove from your liked songs'
                        : 'Add to your liked songs',
                    () => Navigator.pop(context),
                  ),
                  _buildOptionTile(
                    Icons.playlist_add,
                    'Add to Playlist',
                    'Add to another playlist',
                    () => Navigator.pop(context),
                  ),
                  _buildOptionTile(
                    Icons.person,
                    'View Artist',
                    'Go to ${song.artist.name}',
                    () => Navigator.pop(context),
                  ),
                  _buildOptionTile(
                    Icons.album,
                    'View Album',
                    'Go to ${song.albumName}',
                    () => Navigator.pop(context),
                  ),
                  _buildOptionTile(
                    Icons.share,
                    'Share Song',
                    'Share this song',
                    () => Navigator.pop(context),
                  ),
                  if (_playlistData.creatorName == 'You')
                    _buildOptionTile(
                      Icons.remove_circle_outline,
                      'Remove from Playlist',
                      'Remove this song from the playlist',
                      () => Navigator.pop(context),
                      isDestructive: true,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBatchSongOptions() {
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
              Text(
                '${_selectedSongs.length} Songs Selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildBatchOptionTile(
                Icons.playlist_add,
                'Add to Playlist',
                'Add selected songs to another playlist',
                () => Navigator.pop(context),
              ),
              _buildBatchOptionTile(
                Icons.download,
                'Download',
                'Make selected songs available offline',
                () => Navigator.pop(context),
              ),
              _buildBatchOptionTile(
                Icons.queue_music,
                'Add to Queue',
                'Add selected songs to queue',
                () => Navigator.pop(context),
              ),
              if (_playlistData.creatorName == 'You')
                _buildBatchOptionTile(
                  Icons.remove_circle_outline,
                  'Remove from Playlist',
                  'Remove selected songs from this playlist',
                  () => Navigator.pop(context),
                  isDestructive: true,
                ),
            ],
          ),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBatchOptionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              isDestructive
                  ? Colors.red.withOpacity(0.2)
                  : const Color(0xFF6366F1).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF6366F1),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: onTap,
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with playlist header
          SliverAppBar(
            expandedHeight: 350,
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
                    ? Text(
                      _playlistData.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
            actions: [
              if (_isSelectionMode) ...[
                IconButton(
                  icon: const Icon(Icons.select_all, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      if (_selectedSongs.length == _songs.length) {
                        _selectedSongs.clear();
                        _isSelectionMode = false;
                      } else {
                        _selectedSongs = _songs.map((song) => song.id).toSet();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed:
                      _selectedSongs.isNotEmpty ? _showBatchSongOptions : null,
                ),
              ] else if (_isReorderMode) ...[
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: _toggleReorderMode,
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _showPlaylistOptions,
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _headerAnimation.value,
                    child: Stack(
                      children: [
                        // Animated wave background
                        AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: PlaylistDetailWavePainter(
                                _waveAnimation.value,
                              ),
                              child: Container(),
                            );
                          },
                        ),

                        // Playlist header content
                        Positioned(
                          bottom: 20,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Playlist cover and info
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Playlist cover
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          _playlistData.coverUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        if (_playlistData.isOffline)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.7,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.download_done,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Playlist info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _playlistData.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'By ${_playlistData.creatorName}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              '${_playlistData.songs.length} songs',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 3,
                                              height: 3,
                                              decoration: const BoxDecoration(
                                                color: Colors.grey,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _playlistData.createdAt
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
                },
              ),
            ),
          ),

          // Description
          if (_playlistData.description != null &&
              _playlistData.description!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _playlistData.description!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),

          // Control buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Play button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Shuffle button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          _isShuffled
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _isShuffled ? const Color(0xFF6366F1) : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: _isShuffled ? Colors.white : Colors.grey,
                        size: 24,
                      ),
                      onPressed: _toggleShuffle,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Download button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          _playlistData.isOffline
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _playlistData.isOffline
                                ? const Color(0xFF10B981)
                                : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _playlistData.isOffline
                            ? Icons.download_done
                            : Icons.download,
                        color:
                            _playlistData.isOffline
                                ? Colors.white
                                : Colors.grey,
                        size: 24,
                      ),
                      onPressed: () {},
                    ),
                  ),

                  const Spacer(),

                  // Action buttons
                  if (!_isSelectionMode && !_isReorderMode) ...[
                    IconButton(
                      icon: const Icon(Icons.sort, color: Colors.grey),
                      onPressed: _toggleReorderMode,
                    ),
                    IconButton(
                      icon: const Icon(Icons.select_all, color: Colors.grey),
                      onPressed: _toggleSelectionMode,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Songs list header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    _isSelectionMode
                        ? '${_selectedSongs.length} selected'
                        : _isReorderMode
                        ? 'Drag to reorder'
                        : 'Songs',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_isSelectionMode || _isReorderMode)
                    TextButton(
                      onPressed:
                          _isSelectionMode
                              ? _toggleSelectionMode
                              : _toggleReorderMode,
                      child: const Text(
                        'Cancel',
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

          // Songs list
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = _songs[index];
              final isSelected = _selectedSongs.contains(song.id);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFF6366F1).withOpacity(0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isReorderMode)
                        const Icon(Icons.drag_handle, color: Colors.grey)
                      else if (_isSelectionMode)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFF6366F1)
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFF6366F1)
                                      : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child:
                              isSelected
                                  ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                  : null,
                        )
                      else
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                            image: NetworkImage(song.albumArt),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (song.isExplicit)
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
                    song.title,
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
                        song.artist.name,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (song.isPremium)
                            const Icon(
                              Icons.download_done,
                              color: Colors.grey,
                              size: 12,
                            ),
                          if (song.isPremium) const SizedBox(width: 4),
                          Text(
                            song.duration,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${_formatNumber(song.playCount)} plays',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing:
                      _isSelectionMode || _isReorderMode
                          ? null
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (song.isLike)
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _showSongOptions(song),
                              ),
                            ],
                          ),
                  onTap:
                      _isSelectionMode
                          ? () => _toggleSongSelection(song.id)
                          : _isReorderMode
                          ? null
                          : () {
                            // Play song
                          },
                  onLongPress:
                      _isSelectionMode || _isReorderMode
                          ? null
                          : () {
                            _toggleSelectionMode();
                            _toggleSongSelection(song.id);
                          },
                  isThreeLine: true,
                ),
              );
            }, childCount: _songs.length),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class PlaylistDetailWavePainter extends CustomPainter {
  final double animationValue;

  PlaylistDetailWavePainter(this.animationValue);

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
