class Comment {
  final String id;
  final String username;
  final String avatarUrl;
  final String text;
  final DateTime timestamp;
  final List<Comment> replies;
  final String? parentId; // For replies
  final int likeCount;
  final bool isLikedByMe;

  Comment({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
    this.replies = const [],
    this.parentId,
    this.likeCount = 0,
    this.isLikedByMe = false,
  });

  // Create a copy of the comment with updated properties
  Comment copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? text,
    DateTime? timestamp,
    List<Comment>? replies,
    String? parentId,
    int? likeCount,
    bool? isLikedByMe,
  }) {
    return Comment(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      replies: replies ?? this.replies,
      parentId: parentId ?? this.parentId,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}
