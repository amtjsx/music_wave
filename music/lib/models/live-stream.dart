class LiveStream {
  final String id;
  final String title;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final String streamUrl;
  final String thumbnailUrl;
  final bool isLive;
  final bool isAudioOnly;
  final int viewerCount;
  final DateTime startedAt;
  final List<LiveComment> topComments;
  final List<String> tags;

  LiveStream({
    required this.id,
    required this.title,
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    required this.streamUrl,
    required this.thumbnailUrl,
    required this.isLive,
    required this.isAudioOnly,
    required this.viewerCount,
    required this.startedAt,
    required this.topComments,
    required this.tags,
  });
}

class LiveComment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime timestamp;
  final bool isHost;
  final List<LiveReply> replies;
  final String? replyToUser;
  final String? originalUser;

  LiveComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
    this.isHost = false,
    this.replies = const [],
    this.replyToUser,
    this.originalUser,
  });
}

class LiveReply {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;

  LiveReply({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });
}
