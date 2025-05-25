import 'dart:convert';

import 'song.dart';

class Playlist {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final List<Song> songs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOffline;
  final String? creatorId;
  final String? creatorName;
  final int playCount;

  Playlist({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    required this.songs,
    required this.createdAt,
    required this.updatedAt,
    this.isOffline = false,
    this.creatorId,
    this.creatorName,
    this.playCount = 0,
  });

  // Create a new empty playlist
  factory Playlist.create({
    required String title,
    String? description,
    String? coverUrl,
    bool isOffline = false,
    String? creatorId,
    String? creatorName,
    int playCount = 0,
  }) {
    final now = DateTime.now();
    return Playlist(
      id: 'pl_${now.millisecondsSinceEpoch}',
      title: title,
      description: description,
      coverUrl: coverUrl,
      songs: [],
      createdAt: now,
      updatedAt: now,
      isOffline: isOffline,
      creatorId: creatorId,
      creatorName: creatorName,
      playCount: playCount,
    );
  }

  // Copy with method for immutability
  Playlist copyWith({
    String? id,
    String? title,
    String? description,
    String? coverUrl,
    List<Song>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOffline,
    String? creatorId,
    String? creatorName,
    int? playCount,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOffline: isOffline ?? this.isOffline,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      playCount: playCount ?? this.playCount,
    );
  }

  // Add a song to the playlist
  Playlist addSong(Song song) {
    // Check if song already exists in playlist
    if (songs.any((s) => s.id == song.id)) {
      return this;
    }

    final updatedSongs = List<Song>.from(songs)..add(song);
    return copyWith(songs: updatedSongs, updatedAt: DateTime.now());
  }

  // Remove a song from the playlist
  Playlist removeSong(String songId) {
    final updatedSongs = List<Song>.from(songs)
      ..removeWhere((song) => song.id == songId);
    return copyWith(songs: updatedSongs, updatedAt: DateTime.now());
  }

  // Reorder songs in the playlist
  Playlist reorderSongs(int oldIndex, int newIndex) {
    final updatedSongs = List<Song>.from(songs);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final song = updatedSongs.removeAt(oldIndex);
    updatedSongs.insert(newIndex, song);

    return copyWith(songs: updatedSongs, updatedAt: DateTime.now());
  }

  // Get total duration of the playlist
  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + _parseDuration(song.duration),
    );
  }

  // Format total duration as string
  String get formattedTotalDuration {
    final duration = totalDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr ${minutes} min';
    } else {
      return '$minutes min';
    }
  }

  // Parse duration string to Duration
  Duration _parseDuration(String durationStr) {
    try {
      final parts = durationStr.split(':');
      if (parts.length == 2) {
        // Format: "3:45" (minutes:seconds)
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return Duration(minutes: minutes, seconds: seconds);
      } else if (parts.length == 3) {
        // Format: "1:23:45" (hours:minutes:seconds)
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return Duration(hours: hours, minutes: minutes, seconds: seconds);
      }
    } catch (e) {
      print('Error parsing duration: $e');
    }

    return Duration.zero;
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'songs': songs.map((song) => song.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isOffline': isOffline,
      'creatorId': creatorId,
      'creatorName': creatorName,
    };
  }

  // Create from Map
  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      coverUrl: map['coverUrl'],
      songs:
          (map['songs'] as List)
              .map((songMap) => Song.fromJson(songMap))
              .toList(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isOffline: map['isOffline'] ?? false,
      creatorId: map['creatorId'],
      creatorName: map['creatorName'],
    );
  }

  // Convert to JSON string
  String toJson() => json.encode(toMap());

  // Create from JSON string
  factory Playlist.fromJson(String source) =>
      Playlist.fromMap(json.decode(source));
}
