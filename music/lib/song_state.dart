// models/song.dart
class Song {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final Duration duration;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.duration,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverUrl,
    Duration? duration,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverUrl: coverUrl ?? this.coverUrl,
      duration: duration ?? this.duration,
    );
  }
}
