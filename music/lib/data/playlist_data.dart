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
        artist: sampleArtist.name,
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover',
        duration: '3:45',
        artistDetails: sampleArtist,
      ),
      Song(
        id: '2',
        title: 'Echoes of You',
        artist: sampleArtist.name,
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover+2',
        duration: '4:12',
        artistDetails: sampleArtist,
      ),
      Song(
        id: '3',
        title: 'Crystal Skies',
        artist: sampleArtist.name,
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover+3',
        duration: '3:28',
        artistDetails: sampleArtist,
      ),
      Song(
        id: '4',
        title: 'Velvet Moon',
        artist: sampleArtist.name,
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover+4',
        duration: '5:02',
        artistDetails: sampleArtist,
      ),
      Song(
        id: '5',
        title: 'Electric Touch',
        artist: sampleArtist.name,
        albumArt: 'https://via.placeholder.com/500?text=Album+Cover+5',
        duration: '3:56',
        artistDetails: sampleArtist,
      ),
    ];
  }
}