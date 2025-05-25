import '../models/artist.dart';
import '../models/song.dart';

class PlaylistData {
  static List<Song> getSamplePlaylist() {
    // Create a sample artist
    final sampleArtist = Artist.sample();
    
    return [
      Song(
        id: '1',
        title: 'Midnight Dreams',
        artistId: sampleArtist.id,
        artist: sampleArtist,
        albumId: 'album_1',
        albumName: 'Album 1',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        audioUrl: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '3:45',
      ),
      Song(
        id: '2',
        title: 'Echoes of You',
        artistId: sampleArtist.id,
        artist: sampleArtist,
        albumId: 'album_2',
        albumName: 'Album 2',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover+2',
        audioUrl: 'https://via.placeholder.com/500?text=Album+Cover+2',
        duration: '4:12',
      ),
      Song(
        id: '3',
        title: 'Crystal Skies',
        artistId: sampleArtist.id,
        artist: sampleArtist,
        albumId: 'album_3',
        albumName: 'Album 3',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover+3',
        audioUrl: 'https://via.placeholder.com/500?text=Album+Cover+3',
        duration: '3:28',
      ),
      Song(
        id: '4',
        title: 'Velvet Moon',
        artistId: sampleArtist.id,
        artist: sampleArtist,
        albumId: 'album_4',
        albumName: 'Album 4',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover+4',
        audioUrl: 'https://via.placeholder.com/500?text=Album+Cover+4',
        duration: '5:02',
      ),
      Song(
        id: '5',
        title: 'Electric Touch',
        artistId: sampleArtist.id,
        artist: sampleArtist,
        albumId: 'album_5',
        albumName: 'Album 5',
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover+5',
        audioUrl: 'https://via.placeholder.com/500?text=Album+Cover+5',
        duration: '3:56',
      ),
    ];
  }
}