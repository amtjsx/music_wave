import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music/models/live-stream.dart';
import 'package:music/screens/live/live-chat-widget.dart';
import 'package:music/screens/live/live-player-widget.dart';
import 'package:music/services/live-stream-service.dart';

class LiveEventDetailScreen extends ConsumerStatefulWidget {
  final String liveId; // Changed from liveId to live

  const LiveEventDetailScreen({
    super.key,
    required this.liveId, // Changed parameter name
  });

  @override
  ConsumerState<LiveEventDetailScreen> createState() =>
      _LiveEventDetailScreenState();
}

class _LiveEventDetailScreenState extends ConsumerState<LiveEventDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();

  bool _isFollowing = false;
  bool _showGiftPanelBol = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _chatScrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use widget.live instead of widget.liveId
    final liveStream = ref.watch(liveStreamProvider(widget.liveId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Live video/audio player section
            _buildLivePlayer(liveStream),

            // Chat and interaction section
            Expanded(
              child: Container(
                color: const Color(0xFF0A0A0A),
                child: Column(
                  children: [
                    // Tab bar
                    _buildTabBar(),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLiveChat(liveStream),
                          _buildTopComments(liveStream),
                          _buildYourReplies(liveStream),
                          _buildMoreOptions(liveStream),
                        ],
                      ),
                    ),

                    // Comment input section
                    _buildCommentInput(liveStream),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePlayer(AsyncValue<LiveStream?> liveStream) {
    return liveStream.when(
      data: (stream) {
        if (stream == null) {
          return _buildErrorState();
        }

        return Stack(
          children: [
            // Live player
            LivePlayerWidget(
              streamUrl: stream.streamUrl,
              isAudioOnly: stream.isAudioOnly,
              thumbnailUrl: stream.thumbnailUrl,
            ),

            // Overlay controls
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),

                    // Live indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text(
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

                    const SizedBox(width: 8),

                    // Viewer count
                    Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatViewerCount(stream.viewerCount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Share button
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => _shareLiveStream(stream),
                    ),

                    // More options
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showMoreOptions(stream),
                    ),
                  ],
                ),
              ),
            ),

            // Host info overlay
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildHostInfo(stream),
            ),
          ],
        );
      },
      loading:
          () => const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            ),
          ),
      error: (error, stack) => _buildErrorState(),
    );
  }

  Widget _buildHostInfo(LiveStream stream) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Host avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(stream.hostAvatar),
          ),
          const SizedBox(width: 12),

          // Host info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stream.hostName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stream.title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  _isFollowing ? Colors.grey[700] : const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(bottom: BorderSide(color: Colors.grey[800]!, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF6366F1),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Live chat'),
          Tab(text: 'Top comments'),
          Tab(text: 'Your replies'),
          Tab(text: 'More'),
        ],
      ),
    );
  }

  Widget _buildLiveChat(AsyncValue<LiveStream?> liveStream) {
    return liveStream.when(
      data: (stream) {
        if (stream == null) return const SizedBox.shrink();

        // Use widget.live instead of widget.liveId
        return LiveChatWidget(
          streamId: widget.liveId,
          scrollController: _chatScrollController,
          onUserTap: (userId) => _showUserProfile(userId),
          onMessageLongPress: (message) => _showMessageOptions(message),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load chat')),
    );
  }

  Widget _buildTopComments(AsyncValue<LiveStream?> liveStream) {
    return liveStream.when(
      data: (stream) {
        if (stream == null) return const SizedBox.shrink();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stream.topComments.length,
          itemBuilder: (context, index) {
            final comment = stream.topComments[index];
            return _buildCommentItem(comment);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load comments')),
    );
  }

  Widget _buildYourReplies(AsyncValue<LiveStream?> liveStream) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No replies yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Your replies will appear here',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOptions(AsyncValue<LiveStream?> liveStream) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOptionItem(
          icon: Icons.flag_outlined,
          title: 'Report',
          onTap: () => _reportStream(),
        ),
        _buildOptionItem(
          icon: Icons.block,
          title: 'Block user',
          onTap: () => _blockUser(),
        ),
        _buildOptionItem(
          icon: Icons.volume_off,
          title: 'Mute stream',
          onTap: () => _muteStream(),
        ),
        _buildOptionItem(
          icon: Icons.info_outline,
          title: 'About this live',
          onTap: () => _showStreamInfo(),
        ),
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildCommentInput(AsyncValue<LiveStream?> liveStream) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.grey[800]!, width: 1)),
      ),
      child: Row(
        children: [
          // Comment input field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 2),
                ),
                onSubmitted: (text) => _sendComment(text),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Gift button
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Color(0xFF6366F1)),
            onPressed: () => _showGiftPanel(),
          ),

          // Like button
          IconButton(
            icon: const Icon(Icons.thumb_up_outlined, color: Color(0xFF6366F1)),
            onPressed: () => _sendReaction('like'),
          ),

          // Heart button
          IconButton(
            icon: const Icon(Icons.favorite_outline, color: Colors.red),
            onPressed: () => _sendReaction('heart'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(LiveComment comment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(comment.userAvatar),
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name and badge
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (comment.isHost) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HOST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                Text(
                  comment.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),

                // Replies
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.reply,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${comment.replyToUser} replied to ${comment.originalUser}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.replies.first.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 300,
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Stream unavailable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This live stream has ended or is not available',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViewerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _sendComment(String text) {
    if (text.trim().isEmpty) return;

    // Send comment logic - use widget.live instead of widget.liveId
    ref.read(liveStreamServiceProvider).sendComment(widget.liveId, text);

    _commentController.clear();
    _commentFocusNode.unfocus();
    _scrollToBottom();
  }

  void _sendReaction(String type) {
    // Use widget.live instead of widget.liveId
    ref.read(liveStreamServiceProvider).sendReaction(widget.liveId, type);
  }

  void _showGiftPanel() {
    setState(() {
      _showGiftPanelBol = !_showGiftPanelBol;
    });
    // Show gift panel implementation
  }

  void _shareLiveStream(LiveStream stream) {
    // Share implementation
  }

  void _showMoreOptions(LiveStream stream) {
    // Show more options bottom sheet
  }

  void _showUserProfile(String userId) {
    context.push('/profile/$userId');
  }

  void _showMessageOptions(LiveComment message) {
    // Show message options (reply, report, etc.)
  }

  void _reportStream() {
    // Report stream implementation
  }

  void _blockUser() {
    // Block user implementation
  }

  void _muteStream() {
    // Mute stream implementation
  }

  void _showStreamInfo() {
    // Show stream info implementation
  }
}
