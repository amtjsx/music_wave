class Artist {
  final String id;
  final String name;
  final String imageUrl;
  final String bio;
  final int followers;
  final int monthlyListeners;
  final List<String> genres;
  final List<String> popularSongs;
  final List<Map<String, dynamic>> albums;
  final List<Map<String, dynamic>> similarArtists;

  Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.bio,
    required this.followers,
    required this.monthlyListeners,
    required this.genres,
    required this.popularSongs,
    required this.albums,
    required this.similarArtists,
  });

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      bio: map['bio'],
      followers: map['followers'],
      monthlyListeners: map['monthlyListeners'],
      genres: List<String>.from(map['genres']),
      popularSongs: List<String>.from(map['popularSongs']),
      albums: List<Map<String, dynamic>>.from(map['albums']),
      similarArtists: List<Map<String, dynamic>>.from(map['similarArtists']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'bio': bio,
      'followers': followers,
      'monthlyListeners': monthlyListeners,
      'genres': genres,
      'popularSongs': popularSongs,
      'albums': albums,
      'similarArtists': similarArtists,
    };
  }

  // Factory method to create a sample artist
  factory Artist.sample() {
    return Artist(
      id: 'artist_1',
      name: 'Aria Nightshade',
      imageUrl: 'https://via.placeholder.com/300?text=Artist',
      bio:
          'Aria Nightshade is a multi-platinum selling artist known for her '
          'ethereal vocals and genre-bending sound. Born in a small coastal town, '
          'she rose to fame with her debut album "Midnight Whispers" in 2018. '
          'Since then, she has collaborated with numerous acclaimed producers and '
          'artists, pushing the boundaries of modern music with each release. '
          'Her lyrics often explore themes of self-discovery, resilience, and the '
          'beauty found in life\'s darker moments.\n\n'
          'With five Grammy awards and countless other accolades, Aria continues '
          'to captivate audiences worldwide with her mesmerizing performances and '
          'innovative approach to songwriting. Outside of music, she is an advocate '
          'for mental health awareness and environmental conservation.',
      followers: 4500000,
      monthlyListeners: 12800000,
      genres: ['Pop', 'Alternative', 'Electronic', 'R&B'],
      popularSongs: [
        'Midnight Dreams',
        'Echoes of You',
        'Crystal Skies',
        'Velvet Moon',
        'Electric Touch',
      ],
      albums: [
        {
          'title': 'Midnight Whispers',
          'year': '2018',
          'imageUrl': 'https://via.placeholder.com/200?text=Album1',
          'tracks': 12,
        },
        {
          'title': 'Ethereal',
          'year': '2020',
          'imageUrl': 'https://via.placeholder.com/200?text=Album2',
          'tracks': 14,
        },
        {
          'title': 'Neon Shadows',
          'year': '2022',
          'imageUrl': 'https://via.placeholder.com/200?text=Album3',
          'tracks': 10,
        },
      ],
      similarArtists: [
        {
          'name': 'Luna Eclipse',
          'imageUrl': 'https://via.placeholder.com/100?text=Artist1',
        },
        {
          'name': 'Skylar Waves',
          'imageUrl': 'https://via.placeholder.com/100?text=Artist2',
        },
        {
          'name': 'Echo Valley',
          'imageUrl': 'https://via.placeholder.com/100?text=Artist3',
        },
        {
          'name': 'Violet Dreams',
          'imageUrl': 'https://via.placeholder.com/100?text=Artist4',
        },
      ],
    );
  }
}
