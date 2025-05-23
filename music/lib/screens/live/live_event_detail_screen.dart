import 'package:flutter/material.dart';

class LiveEventDetailScreen extends StatefulWidget {
  final String eventId;

  const LiveEventDetailScreen({super.key, required this.eventId});

  @override
  State<LiveEventDetailScreen> createState() => _LiveEventDetailScreenState();
}

class _LiveEventDetailScreenState extends State<LiveEventDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _reactionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _reactionAnimation;

  bool _isPlaying = true;
  bool _isMuted = false;
  bool _isFullscreen = false;
  bool _showControls = true;
  bool _isFollowing = false;
  bool _showChat = true;
  bool _isLoading = true;
  double _volume = 0.8;
  String _quality = 'HD';
  Map<String, dynamic>? _eventData;

  final List<String> _qualities = ['4K', 'HD', 'SD', 'Auto'];
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'user': 'MusicLover23',
      'message': '🔥🔥🔥 This is amazing!',
      'time': '2m ago',
    },
    {
      'user': 'ConcertFan',
      'message': 'Best performance ever!',
      'time': '3m ago',
    },
    {
      'user': 'LiveStreamPro',
      'message': 'The sound quality is incredible',
      'time': '5m ago',
    },
    {
      'user': 'FanGirl2024',
      'message': 'I love this song so much! ❤️',
      'time': '7m ago',
    },
    {
      'user': 'MusicAddict',
      'message': 'Anyone know the setlist?',
      'time': '8m ago',
    },
    {
      'user': 'ConcertGoer',
      'message': 'Wish I was there in person!',
      'time': '10m ago',
    },
  ];

  // Sample event data - in a real app, this would come from an API
  final Map<String, Map<String, dynamic>> _eventsDatabase = {
    'event1': {
      'id': 'event1',
      'artist': 'Taylor Swift',
      'title': 'Eras Tour Live',
      'venue': 'Madison Square Garden',
      'viewers': 24750,
      'image': 'https://picsum.photos/400/300?random=101',
      'category': 'Concerts',
      'duration': '01:45:20',
      'description':
          'Taylor Swift brings her record-breaking Eras Tour to Madison Square Garden for an unforgettable night of music spanning her entire career.',
      'startTime': '8:00 PM',
      'date': 'Today',
    },
    'event2': {
      'id': 'event2',
      'artist': 'Ed Sheeran',
      'title': 'Mathematics Tour',
      'venue': 'Wembley Stadium',
      'viewers': 18320,
      'image': 'https://picsum.photos/400/300?random=102',
      'category': 'Concerts',
      'duration': '01:12:05',
      'description':
          'Ed Sheeran performs his biggest hits and new material from his latest album in this intimate yet spectacular show.',
      'startTime': '7:30 PM',
      'date': 'Today',
    },
    'event3': {
      'id': 'event3',
      'artist': 'Billie Eilish',
      'title': 'Happier Than Ever Tour',
      'venue': 'Hollywood Bowl',
      'viewers': 15680,
      'image': 'https://picsum.photos/400/300?random=103',
      'category': 'Concerts',
      'duration': '00:58:30',
      'description':
          'Join Billie Eilish for a night of haunting melodies and powerful performances as she showcases her Grammy-winning album.',
      'startTime': '9:00 PM',
      'date': 'Today',
    },
    'event4': {
      'id': 'event4',
      'artist': 'The Weeknd',
      'title': 'After Hours Tour',
      'venue': 'Red Rocks',
      'viewers': 12450,
      'image': 'https://picsum.photos/400/300?random=104',
      'category': 'Concerts',
      'duration': '01:30:15',
      'description':
          'Experience The Weeknd\'s cinematic performance featuring stunning visuals and his chart-topping hits at the iconic Red Rocks Amphitheatre.',
      'startTime': '8:30 PM',
      'date': 'Today',
    },
    'event5': {
      'id': 'event5',
      'artist': 'Dua Lipa',
      'title': 'Future Nostalgia Tour',
      'venue': 'O2 Arena',
      'viewers': 19870,
      'image': 'https://picsum.photos/400/300?random=105',
      'category': 'Concerts',
      'duration': '00:45:10',
      'description':
          'Dua Lipa brings her dance-pop hits to life with an energetic performance and dazzling choreography that will keep you moving all night.',
      'startTime': '7:00 PM',
      'date': 'Today',
    },
  };

  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _reactionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _reactionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _reactionController, curve: Curves.elasticOut),
    );

    // Fetch event data
    _fetchEventData();

    // Auto-hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> _fetchEventData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, this would be an API call
    if (_eventsDatabase.containsKey(widget.eventId)) {
      setState(() {
        _eventData = _eventsDatabase[widget.eventId];
        _isLoading = false;
      });
    } else {
      // Handle event not found
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event not found'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _reactionController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showControls) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _showQualitySelector() {
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
                'Video Quality',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                _qualities.length,
                (index) => RadioListTile<String>(
                  title: Text(
                    _qualities[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: _qualities[index],
                  groupValue: _quality,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (value) {
                    setState(() {
                      _quality = value!;
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

  void _sendReaction(String emoji) {
    _reactionController.forward().then((_) {
      _reactionController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (_eventData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Event not found',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video/stream area
          GestureDetector(
            onTap: _toggleControls,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_eventData!['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top controls
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    // Live indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Viewer count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_eventData!['viewers']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Center play/pause button
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Event info
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _eventData!['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _eventData!['artist'],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _eventData!['venue'],
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
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
                              backgroundColor:
                                  _isFollowing
                                      ? Colors.grey
                                      : const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(_isFollowing ? 'Following' : 'Follow'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Control buttons
                      Row(
                        children: [
                          // Volume control
                          IconButton(
                            icon: Icon(
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isMuted = !_isMuted;
                              });
                            },
                          ),
                          Expanded(
                            child: Slider(
                              value: _isMuted ? 0 : _volume,
                              onChanged: (value) {
                                setState(() {
                                  _volume = value;
                                  _isMuted = value == 0;
                                });
                              },
                              activeColor: const Color(0xFF6366F1),
                              inactiveColor: Colors.white30,
                            ),
                          ),

                          // Quality selector
                          TextButton(
                            onPressed: _showQualitySelector,
                            child: Text(
                              _quality,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          // Chat toggle
                          IconButton(
                            icon: Icon(
                              _showChat ? Icons.chat : Icons.chat_outlined,
                              color:
                                  _showChat
                                      ? const Color(0xFF6366F1)
                                      : Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _showChat = !_showChat;
                              });
                            },
                          ),

                          // Fullscreen toggle
                          IconButton(
                            icon: Icon(
                              _isFullscreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFullscreen = !_isFullscreen;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Reaction animations
          AnimatedBuilder(
            animation: _reactionAnimation,
            builder: (context, child) {
              return Positioned(
                right: 20 + (50 * _reactionAnimation.value),
                bottom: 200 + (100 * _reactionAnimation.value),
                child: Opacity(
                  opacity: 1 - _reactionAnimation.value,
                  child: Transform.scale(
                    scale: 1 + _reactionAnimation.value,
                    child: const Text('❤️', style: TextStyle(fontSize: 30)),
                  ),
                ),
              );
            },
          ),

          // Chat panel
          if (_showChat)
            Positioned(
              right: 0,
              top: 100,
              bottom: 200,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Chat header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Live Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () {
                              setState(() {
                                _showChat = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Chat messages
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final message = _chatMessages[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['user'],
                                  style: const TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  message['message'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  message['time'],
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Chat input
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[800],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Color(0xFF6366F1),
                              size: 16,
                            ),
                            onPressed: () {
                              if (_chatController.text.isNotEmpty) {
                                // Add message to chat
                                _chatController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Reaction buttons
          Positioned(
            right: 16,
            bottom: 250,
            child: Column(
              children: [
                _buildReactionButton('❤️'),
                const SizedBox(height: 8),
                _buildReactionButton('🔥'),
                const SizedBox(height: 8),
                _buildReactionButton('👏'),
                const SizedBox(height: 8),
                _buildReactionButton('🎵'),
              ],
            ),
          ),

          // Event description overlay - visible when controls are shown
          if (_showControls)
            Positioned(
              top: 100,
              left: 16,
              right:
                  _showChat ? MediaQuery.of(context).size.width * 0.4 + 16 : 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF6366F1),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_eventData!['date']} • ${_eventData!['startTime']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _eventData!['description'] ?? 'No description available',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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

  Widget _buildReactionButton(String emoji) {
    return GestureDetector(
      onTap: () => _sendReaction(emoji),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
      ),
    );
  }
}
