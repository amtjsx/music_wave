import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/live-stream.dart';
import 'package:music/services/live-stream-service.dart';

class LiveChatWidget extends ConsumerStatefulWidget {
  final String streamId;
  final ScrollController scrollController;
  final Function(String userId)? onUserTap;
  final Function(LiveComment message)? onMessageLongPress;

  const LiveChatWidget({
    super.key,
    required this.streamId,
    required this.scrollController,
    this.onUserTap,
    this.onMessageLongPress,
  });

  @override
  ConsumerState<LiveChatWidget> createState() => _LiveChatWidgetState();
}

class _LiveChatWidgetState extends ConsumerState<LiveChatWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<_AnimatedMessage> _animatedMessages = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(liveChatProvider(widget.streamId));

    return messages.when(
      data: (messageList) {
        // Add new messages with animation
        for (final message in messageList) {
          if (!_animatedMessages.any((m) => m.message.id == message.id)) {
            _animatedMessages.add(
              _AnimatedMessage(
                message: message,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOut,
                  ),
                ),
              ),
            );
          }
        }

        _animationController.forward();

        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _animatedMessages.length,
          itemBuilder: (context, index) {
            final animatedMessage = _animatedMessages[index];

            return AnimatedBuilder(
              animation: animatedMessage.animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - animatedMessage.animation.value)),
                  child: Opacity(
                    opacity: animatedMessage.animation.value,
                    child: _buildChatMessage(animatedMessage.message),
                  ),
                );
              },
            );
          },
        );
      },
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1)),
          ),
      error:
          (error, stack) => Center(
            child: Text(
              'Failed to load chat',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
    );
  }

  Widget _buildChatMessage(LiveComment message) {
    return GestureDetector(
      onTap: () => widget.onUserTap?.call(message.userId),
      onLongPress: () => widget.onMessageLongPress?.call(message),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User avatar
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(message.userAvatar),
            ),
            const SizedBox(width: 8),

            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name with badges
                  Row(
                    children: [
                      Text(
                        message.userName,
                        style: TextStyle(
                          color:
                              message.isHost
                                  ? const Color(0xFF6366F1)
                                  : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (message.isHost) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'HOST',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Message text
                  Text(
                    message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),

                  // Reply indicator
                  if (message.replyToUser != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.reply, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'replied to ${message.replyToUser}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Timestamp
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(color: Colors.grey[700], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

class _AnimatedMessage {
  final LiveComment message;
  final Animation<double> animation;

  _AnimatedMessage({required this.message, required this.animation});
}
