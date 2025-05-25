import 'package:music/models/artist.dart';

class Song {
  final String id;
  final String title;
  final String artistId;
  final Artist artist;
  final String albumId;
  final String albumName;
  final String albumArt;
  final String audioUrl;
  final String duration;
  final bool isExplicit;
  final bool isPremium;
  final bool isLike;
  final int playCount;

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artist,
    required this.albumId,
    required this.albumName,
    required this.albumArt,
    required this.audioUrl,
    required this.duration,
    this.isExplicit = false,
    this.isPremium = false,
    this.isLike = false,
    this.playCount = 0,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artistId,
    Artist? artist,
    String? albumId,
    String? albumName,
    String? albumArt,
    String? audioUrl,
    String? duration,
    bool? isExplicit,
    bool? isPremium,
    bool? isLike,
    int? playCount,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artist: artist ?? this.artist,
      albumId: albumId ?? this.albumId,
      albumName: albumName ?? this.albumName,
      albumArt: albumArt ?? this.albumArt,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isExplicit: isExplicit ?? this.isExplicit,
      isPremium: isPremium ?? this.isPremium,
      isLike: isLike ?? this.isLike,
      playCount: playCount ?? this.playCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artistId': artistId,
      'artist': artist,
      'albumId': albumId,
      'albumName': albumName,
      'albumArt': albumArt,
      'audioUrl': audioUrl,
      'duration': duration,
      'isExplicit': isExplicit,
      'isPremium': isPremium,
      'isLike': isLike,
      'playCount': playCount,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artistId: json['artistId'],
      artist: json['artist'],
      albumId: json['albumId'],
      albumName: json['albumName'],
      albumArt: json['albumArt'],
      audioUrl: json['audioUrl'],
      duration: json['duration'],
      isExplicit: json['isExplicit'] ?? false,
      isPremium: json['isPremium'] ?? false,
    );
  }
}
