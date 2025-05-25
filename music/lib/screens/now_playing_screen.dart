import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music/screens/playlists/add_to_playlist_sheet.dart';
import 'package:music/services/share_service.dart';
import 'package:music/services/song_service.dart';
import 'package:music/widgets/share_sheet.dart';

import '../data/playlist_data.dart';
import '../models/comment.dart';
import '../models/song.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/circular_visualizer.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreen();
}

class _NowPlayingScreen extends ConsumerState<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Comment> _comments = [];
  bool _isCommenting = false;
  String? _replyingToId;
  String? _replyingToCommentId;
  String? _replyingToUsername;

  // Create a dedicated FocusNode for the reply input
  final FocusNode _replyFocusNode = FocusNode();

  // Animation controller for the player
  late AnimationController _playerAnimationController;
  late Animation<double> _playerScaleAnimation;

  // Track if player is minimized
  bool _isPlayerMinimized = false;

  // Track if reply input is showing
  bool _isReplyInputVisible = false;

  // Random for generating demo user data
  final Random _random = Random();

  late List<Song> playlist;

  @override
  void initState() {
    super.initState();
    // Get sample playlist data
    playlist = PlaylistData.getSamplePlaylist();

    // Initialize animation controller
    _playerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _playerScaleAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _playerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Add some initial comments
    _addSampleComments();

    // Listen to scroll but don't animate
    _scrollController.addListener(() {
      // Just update player state without animation
      if (_scrollController.offset > 150 && !_isPlayerMinimized) {
        setState(() {
          _isPlayerMinimized = true;
        });
      } else if (_scrollController.offset <= 150 && _isPlayerMinimized) {
        setState(() {
          _isPlayerMinimized = false;
        });
      }
    });
  }

  void _addSampleComments() {
    final sampleComments = [
      "This song is amazing! 🔥",
      "Love the beat on this track",
      "Who's listening in 2023?",
      "The lyrics are so meaningful",
      "This artist never disappoints",
      "Can't stop listening to this on repeat",
      "The production quality is incredible",
      "This brings back so many memories",
    ];

    // Add sample comments with random timestamps within the last hour
    for (int i = 0; i < 5; i++) {
      final minutesAgo = _random.nextInt(60);
      final likeCount = _random.nextInt(
        50,
      ); // Random like count between 0 and 49
      final isLiked = _random.nextBool(); // Randomly liked or not

      final comment = Comment(
        id: 'comment_${_random.nextInt(100)}',
        username: 'User ${_random.nextInt(100)}',
        avatarUrl: 'https://via.placeholder.com/40?text=User',
        text: sampleComments[_random.nextInt(sampleComments.length)],
        timestamp: DateTime.now().subtract(Duration(minutes: minutesAgo)),
        likeCount: likeCount,
        isLikedByMe: isLiked,
      );

      // Add some sample replies to the first two comments
      if (i < 2) {
        final replies = <Comment>[];
        final replyCount = _random.nextInt(3) + 1;

        for (int j = 0; j < replyCount; j++) {
          final replyLikeCount = _random.nextInt(
            20,
          ); // Random like count for replies
          final replyIsLiked = _random.nextBool(); // Randomly liked or not

          replies.add(
            Comment(
              id: 'comment_${_random.nextInt(100)}',
              parentId: comment.id,
              username: 'User ${_random.nextInt(100)}',
              avatarUrl: 'https://via.placeholder.com/40?text=User',
              text:
                  'Totally agree! ${sampleComments[_random.nextInt(sampleComments.length)]}',
              timestamp: DateTime.now().subtract(
                Duration(minutes: _random.nextInt(minutesAgo)),
              ),
              likeCount: replyLikeCount,
              isLikedByMe: replyIsLiked,
            ),
          );
        }

        _comments.add(
          Comment(
            id: comment.id,
            username: comment.username,
            avatarUrl: comment.avatarUrl,
            text: comment.text,
            timestamp: comment.timestamp,
            replies: replies,
            likeCount: comment.likeCount,
            isLikedByMe: comment.isLikedByMe,
          ),
        );
      } else {
        _comments.add(comment);
      }
    }

    // Sort comments by timestamp (newest first)
    _comments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _playerAnimationController.dispose();
    _replyFocusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  void _addComment(String text, {String? parentId, String? parentUsername}) {
    if (text.trim().isEmpty) return;

    setState(() {
      if (parentId != null) {
        // This is a reply
        final parentIndex = _comments.indexWhere((c) => c.id == parentId);
        if (parentIndex != -1) {
          final parent = _comments[parentIndex];
          final newReplies = List<Comment>.from(parent.replies);

          newReplies.add(
            Comment(
              id: 'comment_${_random.nextInt(100)}',
              parentId: parentId,
              username: 'You',
              avatarUrl: 'https://via.placeholder.com/40?text=You',
              text: text,
              timestamp: DateTime.now(),
              likeCount: 0,
              isLikedByMe: false,
            ),
          );

          // Replace the parent comment with updated replies
          _comments[parentIndex] = parent.copyWith(replies: newReplies);
        }

        // Clear reply state
        _replyingToId = null;
        _replyingToUsername = null;
        _isReplyInputVisible = false;
      } else {
        // This is a new comment
        _comments.insert(
          0,
          Comment(
            id: 'comment_${_random.nextInt(100)}',
            username: 'You',
            avatarUrl: 'https://via.placeholder.com/40?text=You',
            text: text,
            timestamp: DateTime.now(),
            likeCount: 0,
            isLikedByMe: false,
          ),
        );
      }
    });

    _commentController.clear();

    // Scroll to show the new comment or reply without animation
    if (_scrollController.hasClients) {
      if (parentId != null) {
        // Find the position of the parent comment
        final parentIndex = _comments.indexWhere((c) => c.id == parentId);
        if (parentIndex != -1) {
          // Calculate approximate position of the comment in the scroll view
          final commentPosition = 600.0 + (parentIndex * 120.0);
          _scrollController.jumpTo(
            commentPosition,
          ); // Use jumpTo instead of animateTo
        }
      } else {
        // For new comments, scroll to the top of the comments section
        final commentSectionPosition = 600.0;
        _scrollController.jumpTo(
          commentSectionPosition,
        ); // Use jumpTo instead of animateTo
      }
    }
  }

  void _toggleLikeComment(String commentId, {String? parentId}) {
    setState(() {
      if (parentId == null) {
        // This is a main comment
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          final comment = _comments[index];
          final newLikeCount =
              comment.isLikedByMe
                  ? comment.likeCount - 1
                  : comment.likeCount + 1;

          _comments[index] = comment.copyWith(
            likeCount: newLikeCount,
            isLikedByMe: !comment.isLikedByMe,
          );
        }
      } else {
        // This is a reply
        final parentIndex = _comments.indexWhere((c) => c.id == parentId);
        if (parentIndex != -1) {
          final parent = _comments[parentIndex];
          final replyIndex = parent.replies.indexWhere(
            (r) => r.id == commentId,
          );

          if (replyIndex != -1) {
            final reply = parent.replies[replyIndex];
            final newLikeCount =
                reply.isLikedByMe ? reply.likeCount - 1 : reply.likeCount + 1;

            final newReplies = List<Comment>.from(parent.replies);
            newReplies[replyIndex] = reply.copyWith(
              likeCount: newLikeCount,
              isLikedByMe: !reply.isLikedByMe,
            );

            _comments[parentIndex] = parent.copyWith(replies: newReplies);
          }
        }
      }
    });
  }

  void _startReply(String commentId, String username) {
    setState(() {
      _replyingToId = commentId;
      _replyingToCommentId = commentId;
      _replyingToUsername = username;
      _isReplyInputVisible = true;
      _commentController.clear();
    });

    // Use a short delay to ensure the reply input is built before focusing
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_replyFocusNode.hasListeners) {
        _replyFocusNode.requestFocus();
      }
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToCommentId = null;
      _replyingToUsername = null;
      _isReplyInputVisible = false;
      _commentController.clear();
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatLikeCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the player state from the StateNotifierProvider
    final playerState = ref.watch(songNotifierProvider);
    final currentSong = playerState.currentSong ?? playlist[0];
    final isPlaying = playerState.playbackState == PlaybackState.playing;

    // Calculate current value for the progress slider based on song duration
    final songDurationMs = _parseDuration(currentSong.duration).inMilliseconds;
    final currentValue =
        songDurationMs > 0
            ? playerState.position.inMilliseconds / songDurationMs
            : 0.0;

    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Wave'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            physics:
                const ClampingScrollPhysics(), // Remove bounce/overscroll animation
            children: [
              _buildFullPlayerWithVisualizer(
                currentSong,
                accentColor,
                isPlaying,
                currentValue,
              ),
              // Song details section
              _buildSongDetailsSection(currentSong),

              // Lyrics section
              _buildLyricsSection(),

              // Related songs section
              _buildRelatedSongsSection(),

              // Comments header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_comments.length} comments',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Comment input (only for new comments, not replies)
              if (!_isReplyInputVisible) _buildCommentInput(isReply: false),

              // Comments list
              ..._comments
                  .map((comment) => _buildCommentItem(comment))
                  .toList(),

              // Bottom padding
              const SizedBox(height: 80),
            ],
          ),

          // Reply input at the bottom of the screen (appears when replying)
          if (_isReplyInputVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom:
                  MediaQuery.of(
                    context,
                  ).viewInsets.bottom, // Adjust for keyboard
              child: _buildCommentInput(isReply: true),
            ),
        ],
      ),
    );
  }

  // Helper method to parse duration string like "3:45" to Duration
  Duration _parseDuration(String durationStr) {
    final parts = durationStr.split(':');
    if (parts.length == 2) {
      return Duration(
        minutes: int.tryParse(parts[0]) ?? 0,
        seconds: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const Duration(minutes: 3); // Default to 3 minutes
  }

  Widget _buildFullPlayerWithVisualizer(
    Song song,
    Color accentColor,
    bool isPlaying,
    double currentValue,
  ) {
    // Get the player state from the StateNotifierProvider
    final playerState = ref.watch(songNotifierProvider);

    return Stack(
      children: [
        // Background visualizer
        Positioned.fill(
          child: Opacity(
            opacity: 0.7,
            child: CircularVisualizer(
              isPlaying: isPlaying,
              color: accentColor,
              size: 500,
              barCount: 120,
            ),
          ),
        ),

        Container(
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
              const SizedBox(height: 20),

              // Song title
              Text(
                song.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              // Artist profile section
              GestureDetector(
                onTap: () {
                  context.push('/artists/${song.artistId}');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Artist avatar
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(song.artist.imageUrl),
                        backgroundColor: Colors.grey[800],
                      ),
                      const SizedBox(width: 8),

                      // Artist name
                      Text(
                        song.artist.name,
                        style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                      ),

                      // Arrow icon
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Progress Bar
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: Theme.of(context).colorScheme.secondary,
                  inactiveTrackColor: Colors.grey[700],
                  thumbColor: Theme.of(context).colorScheme.secondary,
                  overlayColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
                ),
                child: Slider(
                  value: currentValue.clamp(0.0, 1.0),
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    // Calculate the position in milliseconds based on song duration
                    final songDuration = _parseDuration(song.duration);
                    final position = Duration(
                      milliseconds:
                          (value * songDuration.inMilliseconds).round(),
                    );

                    // Use the StateNotifierProvider to seek to position
                    ref.read(songNotifierProvider.notifier).seek(position);
                  },
                ),
              ),

              // Time Indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Current position
                    Text(
                      _formatDuration(playerState.position),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    // Total duration
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle button
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color:
                          playerState.isShuffleEnabled
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey[400],
                    ),
                    onPressed: () {
                      // Toggle shuffle mode
                      ref
                          .read(songNotifierProvider.notifier)
                          .toggleShuffleMode();
                    },
                    iconSize: 24,
                  ),
                  // Previous button
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      ref.read(songNotifierProvider.notifier).skipToPrevious();
                    },
                    iconSize: 40,
                    color: Colors.white,
                  ),
                  // Play/Pause button
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        ref.read(songNotifierProvider.notifier).playPause();
                      },
                      iconSize: 40,
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  // Next button
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      ref.read(songNotifierProvider.notifier).skipToNext();
                    },
                    iconSize: 40,
                    color: Colors.white,
                  ),
                  // Repeat button
                  IconButton(
                    icon: Icon(
                      _getRepeatIcon(playerState.repeatMode),
                      color:
                          playerState.repeatMode != RepeatMode.off
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey[400],
                    ),
                    onPressed: () {
                      // Cycle through repeat modes
                      ref.read(songNotifierProvider.notifier).cycleRepeatMode();
                    },
                    iconSize: 24,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Bottom visualizer
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AudioVisualizer(
              isPlaying: isPlaying,
              color: accentColor,
              height: 30,
              barCount: 40,
            ),
          ),
        ),
      ],
    );
  }

  void _addToPlaylist(Song track) {
    print('Adding to playlist: ${track.title}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddToPlaylistSheet(song: track),
    );
  }

  void _showShareSheet(Song song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              ShareSheet(contentType: ShareContentType.song, content: song),
    );
  }

  Widget _buildSongDetailsSection(Song song) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.favorite_border, 'Like'),
                _buildActionButton(
                  Icons.playlist_add,
                  'Add',
                  onPressed: () => _addToPlaylist(song),
                ),
                _buildActionButton(
                  Icons.share,
                  'Share',
                  onPressed: () => _showShareSheet(song),
                ),
                _buildActionButton(Icons.download_outlined, 'Download'),
              ],
            ),
          ),

          // Divider
          Divider(color: Colors.grey[800]),

          // Song description
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Released on Album "Greatest Hits" • 2023\n\n'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
              'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
              style: TextStyle(fontSize: 14),
            ),
          ),

          // Divider
          Divider(color: Colors.grey[800]),
        ],
      ),
    );
  }

  Widget _buildLyricsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lyrics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Sample lyrics
          Text(
            'Verse 1:\n'
            'Lorem ipsum dolor sit amet\n'
            'Consectetur adipiscing elit\n'
            'Sed do eiusmod tempor incididunt\n'
            'Ut labore et dolore magna aliqua\n\n'
            'Chorus:\n'
            'Ut enim ad minim veniam\n'
            'Quis nostrud exercitation ullamco\n'
            'Laboris nisi ut aliquip ex ea commodo\n'
            'Consequat duis aute irure dolor\n\n'
            'Verse 2:\n'
            'In reprehenderit in voluptate\n'
            'Velit esse cillum dolore eu fugiat\n'
            'Nulla pariatur excepteur sint\n'
            'Occaecat cupidatat non proident\n',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[300],
            ),
          ),

          // Show more button
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Show More',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),

          Divider(color: Colors.grey[800]),
        ],
      ),
    );
  }

  Widget _buildRelatedSongsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            'You Might Also Like',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // Horizontal list of related songs
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(), // Remove scroll animation
            itemCount: playlist.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final song = playlist[index];
              final currentSong = ref.watch(songNotifierProvider).currentSong;

              if (currentSong != null && song.id == currentSong.id) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  // Play the selected song using the StateNotifierProvider
                  ref.read(songNotifierProvider.notifier).playSong(song);
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Song image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          song.albumArt,
                          height: 140,
                          width: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 140,
                              width: 140,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Song title
                      Text(
                        song.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Artist name
                      Text(
                        song.artist.name,
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Divider(color: Colors.grey[800]),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        IconButton(icon: Icon(icon), onPressed: onPressed),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildCommentInput({required bool isReply}) {
    // For reply input, use a different style with a header bar
    if (isReply) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Replying to $_replyingToUsername',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelReply,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Comment input field
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode:
                          _replyFocusNode, // Use the dedicated focus node
                      autofocus: true, // Set autofocus to true
                      keyboardType:
                          TextInputType
                              .multiline, // Ensure keyboard shows for multiline
                      textCapitalization:
                          TextCapitalization
                              .sentences, // Auto-capitalize first letter
                      decoration: InputDecoration(
                        hintText: 'Add a reply...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      minLines: 1,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _addComment(
                            value,
                            parentId: _replyingToId,
                            parentUsername: _replyingToUsername,
                          );
                        }
                      },
                    ),
                  ),

                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      _addComment(
                        _commentController.text,
                        parentId: _replyingToId,
                        parentUsername: _replyingToUsername,
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

    // Regular comment input
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCommenting ? Colors.grey[900] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),

          // Comment input field
          Expanded(
            child: TextField(
              controller: _commentController,
              onTap: () {
                setState(() {
                  _isCommenting = true;
                });
              },
              onSubmitted: (value) {
                _addComment(value);
                setState(() {
                  _isCommenting = false;
                });
              },
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: () {
                    _addComment(_commentController.text);
                    setState(() {
                      _isCommenting = false;
                    });
                  },
                ),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: _isCommenting ? 3 : 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    final isNewComment =
        DateTime.now().difference(comment.timestamp).inSeconds < 3;

    final isReplying = comment.id == _replyingToCommentId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main comment
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color:
              isNewComment
                  ? Colors.grey[800]!.withOpacity(0.3)
                  : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: NetworkImage(comment.avatarUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle error
                  },
                ),
                const SizedBox(width: 12),

                // Comment content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isReplying ? Colors.grey[800] : Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username and timestamp
                            Row(
                              children: [
                                Text(
                                  comment.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimestamp(comment.timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                if (isNewComment)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[700],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Comment text
                            Text(
                              comment.text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      // Comment actions
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            // Like button with count
                            GestureDetector(
                              onTap: () => _toggleLikeComment(comment.id),
                              child: _buildLikeAction(
                                'Like',
                                comment.likeCount,
                                comment.isLikedByMe,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap:
                                  () =>
                                      _startReply(comment.id, comment.username),
                              child: _buildReplyAction('Reply'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Replies
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Column(
              children:
                  comment.replies.map((reply) {
                    return _buildCommentItem(reply);
                  }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLikeAction(String label, int count, bool isLiked) {
    final Color textColor = isLiked ? Colors.red : Colors.grey[500]!;

    return Text(
      count > 0 ? '$label · ${_formatLikeCount(count)}' : label,
      style: TextStyle(fontSize: 12, color: textColor),
    );
  }

  Widget _buildReplyAction(String label) {
    return Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500]));
  }

  // Helper method to format duration
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Helper method to get the appropriate repeat icon based on the repeat mode
  IconData _getRepeatIcon(RepeatMode repeatMode) {
    switch (repeatMode) {
      case RepeatMode.off:
        return Icons.repeat;
      case RepeatMode.all:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
    }
  }
}
