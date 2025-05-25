import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class ShortScreen extends StatefulWidget {
  const ShortScreen({super.key});

  @override
  State<ShortScreen> createState() => _ShortScreenState();
}

class _ShortScreenState extends State<ShortScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Map<String, dynamic>> _videos = [];

  // Track if this screen is currently visible
  bool _isCurrentScreen = true;

  // Pagination parameters
  int _page = 1;
  final int _perPage = 5;
  bool _hasMoreVideos = true;
  String _lastQuery = 'nature';

  // List of search queries to rotate through for variety
  final List<String> _searchQueries = [
    'nature',
    'travel',
    'food',
    'animals',
    'sports',
    'city',
    'dance',
    'music',
    'ocean',
    'sunset',
  ];

  @override
  void initState() {
    super.initState();
    // Register this object as an observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController();
    _fetchVideos();

    // Add listener to detect when user is near the end of the list
    _pageController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Unregister the observer
    WidgetsBinding.instance.removeObserver(this);

    _pageController.removeListener(_scrollListener);
    _pageController.dispose();

    // Ensure we mark the screen as not visible when disposed
    _isCurrentScreen = false;
    super.dispose();
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause videos when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseAllVideos();
    }
  }

  // Method to pause all active videos
  void _pauseAllVideos() {
    // This will trigger all VideoItem widgets to pause their videos
    setState(() {
      _isCurrentScreen = false;
    });
  }

  // Method to resume playing the current video
  void _resumeCurrentVideo() {
    setState(() {
      _isCurrentScreen = true;
    });
  }

  // Scroll listener to detect when to load more videos
  void _scrollListener() {
    // If we're at 80% of the available videos, load more
    if (_pageController.position.pixels > 0 &&
        _currentPage >= _videos.length - 2 &&
        !_isLoadingMore &&
        _hasMoreVideos) {
      _loadMoreVideos();
    }
  }

  // Rest of the methods remain the same...
  // Rotate through search queries for variety
  String _getNextSearchQuery() {
    // Rotate through different queries for variety
    final nextQueryIndex = _page % _searchQueries.length;
    return _searchQueries[nextQueryIndex];
  }

  // Initial fetch of videos
  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
      _page = 1;
      _videos = [];
    });

    await _loadVideos();

    setState(() {
      _isLoading = false;
    });
  }

  // Load more videos when scrolling
  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore || !_hasMoreVideos) return;

    setState(() {
      _isLoadingMore = true;
    });

    _page++;
    await _loadVideos();

    setState(() {
      _isLoadingMore = false;
    });
  }

  // Common method to load videos with current pagination parameters
  Future<void> _loadVideos() async {
    try {
      // Rotate search queries for variety
      final query = _getNextSearchQuery();
      _lastQuery = query;

      // Using Pexels API for video content
      final response = await http.get(
        Uri.parse(
          'https://api.pexels.com/videos/search?query=$query&page=$_page&per_page=$_perPage',
        ),
        headers: {
          'Authorization':
              'TOxH8elJpWcxRiXsdQTWEUpRviXV5IDsVPkA3KwcgfdThwUTDqHOg4SN', // Replace with your actual API key
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> fetchedVideos = [];

        // Check if we've reached the end of available videos
        if (data['videos'].isEmpty) {
          setState(() {
            _hasMoreVideos = false;
          });
          return;
        }

        for (var video in data['videos']) {
          // Find the medium quality video file
          var videoUrl = '';
          for (var file in video['video_files']) {
            if (file['quality'] == 'hd' || file['quality'] == 'sd') {
              videoUrl = file['link'];
              break;
            }
          }

          if (videoUrl.isNotEmpty) {
            fetchedVideos.add({
              'id': video['id'].toString(),
              'videoUrl': videoUrl,
              'thumbnail': video['image'],
              'duration': video['duration'],
              'username': '@pexels_${video['user']['id']}',
              'userAvatar':
                  video['user']['url'] ??
                  'https://randomuser.me/api/portraits/men/32.jpg',
              'description':
                  '${_capitalizeFirstLetter(query)}: ${video['url'].split('/').last.replaceAll('-', ' ')} #shorts #${query}',
              'likes': '${(video['duration'] * 1000).round()}',
              'comments': '${(video['duration'] * 100).round()}',
              'shares': '${(video['duration'] * 50).round()}',
              'musicName': 'Original Sound - Pexels ${query.capitalize()}',
              'videoComments': _generateRandomComments(query),
              'query': query, // Store the query for reference
            });
          }
        }

        setState(() {
          // Append new videos to existing list
          _videos.addAll(fetchedVideos);
        });
      } else {
        // If API fails and we have no videos yet, use sample data
        if (_videos.isEmpty) {
          setState(() {
            _videos = _getSampleVideos();
            _hasMoreVideos = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching videos: $e');
      // If error and we have no videos yet, use sample data
      if (_videos.isEmpty) {
        setState(() {
          _videos = _getSampleVideos();
          _hasMoreVideos = false;
        });
      }
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Generate random comments related to the video query
  List<Map<String, dynamic>> _generateRandomComments(String query) {
    final querySpecificComments = [
      'This $query video is amazing! 🔥',
      'Where was this $query filmed?',
      'The $query looks so beautiful! 💙',
      'I love $query content like this',
      'Best $query video I\'ve seen today',
      'This makes me want to explore more $query content',
      'Can you share more $query videos?',
      'The quality of this $query footage is incredible',
      'I could watch $query videos all day',
      'This $query content is exactly what I needed today',
    ];

    querySpecificComments.shuffle();

    final comments = [
      {
        'username': '@${query}_lover',
        'avatar': 'https://randomuser.me/api/portraits/women/1.jpg',
        'comment': querySpecificComments[0],
        'likes': 45,
        'timeAgo': '2h',
        'isLiked': false,
      },
      {
        'username': '@${query}_fan',
        'avatar': 'https://randomuser.me/api/portraits/men/2.jpg',
        'comment': querySpecificComments[1],
        'likes': 23,
        'timeAgo': '4h',
        'isLiked': true,
      },
      {
        'username': '@explore_${query}',
        'avatar': 'https://randomuser.me/api/portraits/women/3.jpg',
        'comment': querySpecificComments[2],
        'likes': 67,
        'timeAgo': '6h',
        'isLiked': false,
      },
      {
        'username': '@${query}_enthusiast',
        'avatar': 'https://randomuser.me/api/portraits/men/4.jpg',
        'comment': querySpecificComments[3],
        'likes': 12,
        'timeAgo': '8h',
        'isLiked': false,
      },
    ];

    // Return a random subset of comments
    comments.shuffle();
    return comments.take(3).toList();
  }

  // Sample videos in case API fails
  List<Map<String, dynamic>> _getSampleVideos() {
    return [
      {
        'id': '1',
        'videoUrl':
            'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
        'thumbnail':
            'https://mixkit.imgix.net/videos/preview/mixkit-tree-with-yellow-flowers-1173-0.jpg',
        'username': '@naturelover',
        'description': 'Beautiful yellow flowers blooming 🌼 #nature #flowers',
        'likes': '45.2K',
        'comments': '1.2K',
        'shares': '8.5K',
        'musicName': 'Original Sound - Nature Channel',
        'userAvatar': 'https://randomuser.me/api/portraits/women/44.jpg',
        'videoComments': _generateRandomComments('nature'),
        'query': 'nature',
      },
      {
        'id': '2',
        'videoUrl':
            'https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4',
        'thumbnail':
            'https://mixkit.imgix.net/videos/preview/mixkit-waves-in-the-water-1164-0.jpg',
        'username': '@oceanvibes',
        'description': 'Ocean waves are so calming 🌊 #ocean #waves #relax',
        'likes': '120.5K',
        'comments': '3.4K',
        'shares': '18.2K',
        'musicName': 'Ocean Sounds - Relax Music',
        'userAvatar': 'https://randomuser.me/api/portraits/men/32.jpg',
        'videoComments': _generateRandomComments('ocean'),
        'query': 'ocean',
      },
      {
        'id': '3',
        'videoUrl':
            'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-sunlight-529-large.mp4',
        'thumbnail':
            'https://mixkit.imgix.net/videos/preview/mixkit-forest-stream-in-the-sunlight-529-0.jpg',
        'username': '@forestexplorer',
        'description':
            'Morning sunlight through the forest 🌲 #forest #sunlight #nature',
        'likes': '89.7K',
        'comments': '2.1K',
        'shares': '12.3K',
        'musicName': 'Forest Ambience - Nature Sounds',
        'userAvatar': 'https://randomuser.me/api/portraits/women/68.jpg',
        'videoComments': _generateRandomComments('forest'),
        'query': 'forest',
      },
    ];
  }

  void _showCommentsBottomSheet(Map<String, dynamic> videoData) {
    // Pause videos when comments are shown
    _pauseAllVideos();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(videoData: videoData),
    ).then((_) {
      // Resume playing when comments are closed
      _resumeCurrentVideo();
    });
  }

  // Refresh videos with new content
  Future<void> _refreshVideos() async {
    // Reset pagination and fetch new videos
    setState(() {
      _page = 1;
      _hasMoreVideos = true;
    });

    await _fetchVideos();

    // Return to the first video
    if (_videos.isNotEmpty) {
      _pageController.jumpToPage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Handle back button press
      onWillPop: () async {
        // Pause all videos before navigating back
        _pauseAllVideos();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : RefreshIndicator(
                  onRefresh: _refreshVideos,
                  color: Colors.white,
                  backgroundColor: Colors.black,
                  child: Stack(
                    children: [
                      // Video Feed with PageView for vertical scrolling
                      PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _videos.length + (_hasMoreVideos ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show loading indicator at the end when loading more videos
                          if (index == _videos.length) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }

                          return VideoItem(
                            videoData: _videos[index],
                            onCommentTap:
                                () => _showCommentsBottomSheet(_videos[index]),
                            isCurrentPage:
                                _currentPage == index && _isCurrentScreen,
                          );
                        },
                      ),

                      // Top navigation
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Following',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Text(
                                'For You',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Loading indicator for pagination
                      if (_isLoadingMore)
                        Positioned(
                          bottom: 70,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Loading more videos...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class VideoItem extends StatefulWidget {
  final Map<String, dynamic> videoData;
  final VoidCallback onCommentTap;
  final bool isCurrentPage;

  const VideoItem({
    Key? key,
    required this.videoData,
    required this.onCommentTap,
    required this.isCurrentPage,
  }) : super(key: key);

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLiked = false;
  bool _isContainMode = false;
  bool _showControls = false;
  bool _isDisposed = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app going to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isPlaying && !_isDisposed) {
        _videoController.pause();
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle page changes
    if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage && _isInitialized && !_isDisposed) {
        _videoController.play();
        setState(() {
          _isPlaying = true;
        });
      } else if (_isInitialized && !_isDisposed) {
        _videoController.pause();
        setState(() {
          _isPlaying = false;
          _showControls = false;
        });
        _cancelControlsTimer();
      }
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoData['videoUrl']),
    );

    try {
      await _videoController.initialize();
      _videoController.setLooping(true);

      // Add listener to update UI when video position changes
      _videoController.addListener(_videoListener);

      if (widget.isCurrentPage && !_isDisposed) {
        _videoController.play();
        _isPlaying = true;
      }

      if (!_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _videoListener() {
    if (mounted && !_isDisposed) {
      setState(() {});
    }
  }

  void _togglePlayPause() {
    if (_isDisposed) return;

    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoController.play();
      } else {
        _videoController.pause();
      }

      _showControls = true;
      _startControlsTimer();
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _showVideoControls() {
    if (_isDisposed) return;

    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
      _startControlsTimer();
    } else {
      _resetControlsTimer();
    }
  }

  void _startControlsTimer() {
    if (_isDisposed) return;

    _cancelControlsTimer();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying && !_isDisposed) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _resetControlsTimer() {
    if (_isDisposed) return;

    _cancelControlsTimer();
    _startControlsTimer();
  }

  void _cancelControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _seekToPosition(double position) {
    if (_isDisposed) return;

    final Duration newPosition = Duration(milliseconds: position.round());
    _videoController.seekTo(newPosition);
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _cancelControlsTimer();
    _videoController.removeListener(_videoListener);
    _videoController.pause();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _togglePlayPause();
        _showVideoControls();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video background
          Container(color: Colors.black),

          // Video player
          _isInitialized
              ? Center(
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              )
              : Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.videoData['thumbnail'] != null)
                    Image.network(
                      widget.videoData['thumbnail'],
                      fit: _isContainMode ? BoxFit.contain : BoxFit.cover,
                    ),
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ],
              ),

          // Play/Pause indicator in center
          if (_showControls)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),

          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Right side action buttons - moved up to make room for slider
          Positioned(
            right: 16,
            bottom: 150, // Increased from 100 to make room for slider
            child: Column(
              children: [
                // Profile picture with plus button
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(25),
                        image: DecorationImage(
                          image: NetworkImage(widget.videoData['userAvatar']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Like button
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 35,
                        color: _isLiked ? Colors.red : Colors.white,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.videoData['likes'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Comment button
                GestureDetector(
                  onTap: widget.onCommentTap,
                  child: Column(
                    children: [
                      const Icon(Icons.comment, size: 35, color: Colors.white),
                      const SizedBox(height: 5),
                      Text(
                        widget.videoData['comments'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Share button
                Column(
                  children: [
                    const Icon(Icons.share, size: 35, color: Colors.white),
                    const SizedBox(height: 5),
                    Text(
                      widget.videoData['shares'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Rotating record for music
                RotatingMusicDisc(isPlaying: _isPlaying),
              ],
            ),
          ),

          // Bottom section - username, description, and music info - moved up
          Positioned(
            left: 16,
            right: 80,
            bottom: 70, // Increased from 20 to make room for slider
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videoData['username'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.videoData['description'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.music_note, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.videoData['musicName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Video progress slider - ALWAYS VISIBLE AT THE BOTTOM
          if (_isInitialized)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 20, // Extra padding for gesture area
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_videoController.value.position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDuration(_videoController.value.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    SizedBox(
                      height: 20, // Increased height for better touch target
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8, // Larger thumb
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16, // Larger touch area
                          ),
                          activeTrackColor: Colors.red,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.red,
                          overlayColor: Colors.red.withOpacity(0.3),
                        ),
                        child: Slider(
                          min: 0,
                          max:
                              _videoController.value.duration.inMilliseconds
                                  .toDouble(),
                          value: _videoController.value.position.inMilliseconds
                              .toDouble()
                              .clamp(
                                0,
                                _videoController.value.duration.inMilliseconds
                                    .toDouble(),
                              ),
                          onChanged: (value) {
                            _seekToPosition(value);
                            if (_showControls) {
                              _resetControlsTimer();
                            }
                          },
                          onChangeStart: (_) {
                            if (_isPlaying) {
                              _videoController.pause();
                            }
                            _cancelControlsTimer();
                          },
                          onChangeEnd: (_) {
                            if (_isPlaying) {
                              _videoController.play();
                            }
                            if (_showControls) {
                              _startControlsTimer();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// The rest of the classes remain the same...
class RotatingMusicDisc extends StatefulWidget {
  final bool isPlaying;

  const RotatingMusicDisc({super.key, required this.isPlaying});

  @override
  State<RotatingMusicDisc> createState() => _RotatingMusicDiscState();
}

class _RotatingMusicDiscState extends State<RotatingMusicDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    if (!widget.isPlaying) {
      _animationController.stop();
    }
  }

  @override
  void didUpdateWidget(RotatingMusicDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animationController,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: const DecorationImage(
            image: NetworkImage('https://picsum.photos/400?random=${18}'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class CommentsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> videoData;

  const CommentsBottomSheet({Key? key, required this.videoData})
    : super(key: key);

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    comments = List.from(widget.videoData['videoComments'] ?? []);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        comments.insert(0, {
          'username': '@you',
          'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
          'comment': _commentController.text.trim(),
          'likes': 0,
          'timeAgo': 'now',
          'isLiked': false,
        });
      });
      _commentController.clear();
    }
  }

  void _toggleCommentLike(int index) {
    setState(() {
      comments[index]['isLiked'] = !comments[index]['isLiked'];
      if (comments[index]['isLiked']) {
        comments[index]['likes']++;
      } else {
        comments[index]['likes']--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${comments.length} comments',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.grey, height: 1),

          // Comments list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return CommentItem(
                  comment: comment,
                  onLikeTap: () => _toggleCommentLike(index),
                );
              },
            ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2E),
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // User avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://randomuser.me/api/portraits/men/1.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text input
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send button
                  GestureDetector(
                    onTap: _addComment,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _commentController.text.trim().isNotEmpty
                                ? Colors.blue
                                : Colors.grey[600],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final VoidCallback onLikeTap;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: DecorationImage(
                image: NetworkImage(comment['avatar']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and time
                Row(
                  children: [
                    Text(
                      comment['username'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment['timeAgo'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                Text(
                  comment['comment'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Reply and like count
                Row(
                  children: [
                    const Text(
                      'Reply',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (comment['likes'] > 0)
                      Text(
                        '${comment['likes']} likes',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Like button
          GestureDetector(
            onTap: onLikeTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                comment['isLiked'] ? Icons.favorite : Icons.favorite_border,
                color: comment['isLiked'] ? Colors.red : Colors.grey,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
