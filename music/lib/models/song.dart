import 'artist.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String albumArt;
  final String duration;
  final Artist artistDetails; // Add artist details

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.duration,
    required this.artistDetails, // Add this parameter
  });

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      albumArt: map['albumArt'],
      duration: map['duration'],
      artistDetails: Artist.fromMap(map['artistDetails']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'duration': duration,
      'artistDetails': artistDetails.toMap(),
    };
  }
}
