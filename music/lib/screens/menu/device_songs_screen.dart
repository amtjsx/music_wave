import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/services/audio_service.dart';
import 'package:music/services/scanner_service.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// Provider to persist the last scanned directory path
final lastScannedDirectoryProvider =
    StateNotifierProvider<LastDirectoryNotifier, String?>((ref) {
      return LastDirectoryNotifier(ref);
    });

class LastDirectoryNotifier extends StateNotifier<String?> {
  final Ref ref;
  static const String _key = 'last_scanned_directory';

  LastDirectoryNotifier(this.ref) : super(null) {
    _loadLastDirectory();
  }

  Future<void> _loadLastDirectory() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    state = prefs.getString(_key);
  }

  Future<void> setDirectory(String? directory) async {
    state = directory;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (directory != null) {
      await prefs.setString(_key, directory);
    } else {
      await prefs.remove(_key);
    }
  }
}

// Scanner service provider
final scannerServiceProvider = Provider<ScannerService>((ref) {
  final service = ScannerService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

// Scan progress provider
final scanProgressProvider = StreamProvider<ScanProgress>((ref) {
  final scannerService = ref.watch(scannerServiceProvider);
  return scannerService.progressStream;
});

// Is scanning provider
final isScanningProvider = StateProvider<bool>((ref) => false);

// Providers for music data
final allSongsProvider = StateProvider<List<MusicFile>>((ref) => []);
final albumsProvider = StateProvider<Map<String, List<MusicFile>>>((ref) => {});
final artistsProvider = StateProvider<Map<String, List<MusicFile>>>(
  (ref) => {},
);
final foldersProvider = StateProvider<Map<String, List<MusicFile>>>(
  (ref) => {},
);
final searchQueryProvider = StateProvider<String>((ref) => '');
final currentSortOptionProvider = StateProvider<String>((ref) => 'Name');
final currentViewProvider = StateProvider<String>((ref) => 'List');

// Filtered songs provider
final filteredSongsProvider = Provider<List<MusicFile>>((ref) {
  final allSongs = ref.watch(allSongsProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return allSongs;
  }

  return allSongs.where((song) {
    final title = song.title.toLowerCase();
    final artist = song.artist.toLowerCase();
    final album = song.album.toLowerCase();
    final query = searchQuery.toLowerCase();

    return title.contains(query) ||
        artist.contains(query) ||
        album.contains(query);
  }).toList();
});

class DeviceSongsScreen extends ConsumerStatefulWidget {
  const DeviceSongsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DeviceSongsScreen> createState() => _DeviceSongsScreenState();
}

class _DeviceSongsScreenState extends ConsumerState<DeviceSongsScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _waveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    // Check for permissions and load music
    _checkPermissionAndLoadMusic();

    // Auto-scan if we have a saved directory and no music loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final allSongs = ref.read(allSongsProvider);
      final lastDirectory = ref.read(lastScannedDirectoryProvider);

      if (allSongs.isEmpty && lastDirectory != null && _hasPermission) {
        // Auto-scan the last directory
        if (await Directory(lastDirectory).exists()) {
          _startBackgroundScan(lastDirectory);
        }
      }
    });

    // Set up listeners for scanner service
    _setupScannerListeners();
  }

  void _setupScannerListeners() {
    final scannerService = ref.read(scannerServiceProvider);

    // Listen for new songs found during scanning
    scannerService.songsStream.listen((songs) {
      if (songs.isNotEmpty) {
        // Add new songs to the existing list
        final currentSongs = List<MusicFile>.from(ref.read(allSongsProvider));
        currentSongs.addAll(songs);
        ref.read(allSongsProvider.notifier).state = currentSongs;

        // Organize the new songs
        _organizeMusicFiles(songs);
      }
    });

    // Listen for scan completion
    scannerService.completeStream.listen((songs) {
      ref.read(isScanningProvider.notifier).state = false;

      // Sort songs based on current sort option
      _sortSongs();

      // Show completion snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan complete: ${songs.length} songs found'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    // Listen for scan errors
    scannerService.errorStream.listen((error) {
      ref.read(isScanningProvider.notifier).state = false;

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 150;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  Future<void> _checkPermissionAndLoadMusic() async {
    // First check if we already have music loaded
    final allSongs = ref.read(allSongsProvider);
    if (allSongs.isNotEmpty) {
      // Music already loaded, no need to request permission or scan again
      setState(() {
        _hasPermission = true;
      });
      return;
    }

    // Check if we have permission
    final status = await Permission.storage.status;

    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      // Don't automatically scan, let user choose when to scan
    } else {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      _scanDeviceMusic();
    } else {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  Future<void> _scanDeviceMusic() async {
    try {
      String? selectedDirectory;

      // Check if we have a previously selected directory
      final lastDirectory = ref.read(lastScannedDirectoryProvider);

      if (lastDirectory != null && await Directory(lastDirectory).exists()) {
        // Ask user if they want to use the same directory
        final useLastDirectory = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFF1A1A1A),
                title: const Text(
                  'Use Previous Music Folder?',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Would you like to scan the same folder as last time?\n\n$lastDirectory',
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Choose New Folder',
                      style: TextStyle(color: Color(0xFF6366F1)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Use Same Folder',
                      style: TextStyle(color: Color(0xFF6366F1)),
                    ),
                  ),
                ],
              ),
        );

        if (useLastDirectory == true) {
          selectedDirectory = lastDirectory;
        }
      }

      // If no previous directory or user wants to choose new one
      if (selectedDirectory == null) {
        selectedDirectory = await FilePicker.platform.getDirectoryPath();
      }

      if (selectedDirectory != null) {
        // Save the selected directory
        await ref
            .read(lastScannedDirectoryProvider.notifier)
            .setDirectory(selectedDirectory);

        // Start background scan
        _startBackgroundScan(selectedDirectory);
      }
    } catch (e) {
      debugPrint('Error scanning music: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning music: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startBackgroundScan(String directoryPath) {
    // Clear existing songs if starting a new scan
    ref.read(allSongsProvider.notifier).state = [];
    ref.read(albumsProvider.notifier).state = {};
    ref.read(artistsProvider.notifier).state = {};
    ref.read(foldersProvider.notifier).state = {};

    // Set scanning state
    ref.read(isScanningProvider.notifier).state = true;

    // Start the background scan
    final scannerService = ref.read(scannerServiceProvider);
    scannerService.startScan(directoryPath);

    // Show a snackbar to indicate scanning has started
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Scanning for music in background...'),
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: () {
            scannerService.cancelScan();
            ref.read(isScanningProvider.notifier).state = false;
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _organizeMusicFiles(List<MusicFile> musicFiles) {
    // Get current collections
    final albums = Map<String, List<MusicFile>>.from(ref.read(albumsProvider));
    final artists = Map<String, List<MusicFile>>.from(
      ref.read(artistsProvider),
    );
    final folders = Map<String, List<MusicFile>>.from(
      ref.read(foldersProvider),
    );

    for (final song in musicFiles) {
      // Organize by album
      if (!albums.containsKey(song.album)) {
        albums[song.album] = [];
      }
      albums[song.album]!.add(song);

      // Organize by artist
      if (!artists.containsKey(song.artist)) {
        artists[song.artist] = [];
      }
      artists[song.artist]!.add(song);

      // Organize by folder
      final folderPath = path.dirname(song.filePath);
      final folderName = path.basename(folderPath);
      if (!folders.containsKey(folderName)) {
        folders[folderName] = [];
      }
      folders[folderName]!.add(song);
    }

    // Update providers
    ref.read(albumsProvider.notifier).state = albums;
    ref.read(artistsProvider.notifier).state = artists;
    ref.read(foldersProvider.notifier).state = folders;
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds == 0) return '--:--';

    final duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatFileSize(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  void _sortSongs() {
    final currentSortOption = ref.read(currentSortOptionProvider);
    final allSongs = ref.read(allSongsProvider);

    final sortedSongs = List<MusicFile>.from(allSongs);

    switch (currentSortOption) {
      case 'Name':
        sortedSongs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Artist':
        sortedSongs.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case 'Album':
        sortedSongs.sort((a, b) => a.album.compareTo(b.album));
        break;
      case 'Date Added':
        sortedSongs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
    }

    ref.read(allSongsProvider.notifier).state = sortedSongs;
  }

  void _playSong(MusicFile song, {int? index}) {
    final audioNotifier = ref.read(audioStateProvider.notifier);

    if (index != null) {
      final allSongs = ref.read(allSongsProvider);
      audioNotifier.setPlaylist(allSongs, initialIndex: index);
    } else {
      audioNotifier.playSong(song);
    }

    // Add to recently played
    addToRecentlyPlayed(ref, song);
  }

  void _playAlbum(String albumName) {
    final albums = ref.read(albumsProvider);
    final albumSongs = albums[albumName];

    if (albumSongs != null && albumSongs.isNotEmpty) {
      ref.read(audioStateProvider.notifier).setPlaylist(albumSongs);

      // Add first song to recently played
      addToRecentlyPlayed(ref, albumSongs.first);
    }
  }

  void _playArtist(String artistName) {
    final artists = ref.read(artistsProvider);
    final artistSongs = artists[artistName];

    if (artistSongs != null && artistSongs.isNotEmpty) {
      ref.read(audioStateProvider.notifier).setPlaylist(artistSongs);

      // Add first song to recently played
      addToRecentlyPlayed(ref, artistSongs.first);
    }
  }

  void _playFolder(String folderName) {
    final folders = ref.read(foldersProvider);
    final folderSongs = folders[folderName];

    if (folderSongs != null && folderSongs.isNotEmpty) {
      ref.read(audioStateProvider.notifier).setPlaylist(folderSongs);

      // Add first song to recently played
      addToRecentlyPlayed(ref, folderSongs.first);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSortFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final currentSortOption = ref.watch(currentSortOptionProvider);
            final currentView = ref.watch(currentViewProvider);

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort & View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildSortChip('Name', currentSortOption),
                      _buildSortChip('Artist', currentSortOption),
                      _buildSortChip('Album', currentSortOption),
                      _buildSortChip('Date Added', currentSortOption),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'View as',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildViewChip('List', currentView),
                      _buildViewChip('Grid', currentView),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _sortSongs();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(String label, String currentSortOption) {
    final isSelected = currentSortOption == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFF2A2A2A),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      onSelected: (selected) {
        if (selected) {
          ref.read(currentSortOptionProvider.notifier).state = label;
        }
      },
    );
  }

  Widget _buildViewChip(String label, String currentView) {
    final isSelected = currentView == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFF2A2A2A),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      onSelected: (selected) {
        if (selected) {
          ref.read(currentViewProvider.notifier).state = label;
        }
      },
    );
  }

  void _showSongOptionsBottomSheet(MusicFile song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            // Song info
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Color(0xFF6366F1),
                  size: 30,
                ),
              ),
              title: Text(
                song.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${song.artist} • ${song.album}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(color: Colors.grey),
            // Options
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.white),
              title: const Text('Play', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _playSong(song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text(
                'Add to Queue',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Add to queue functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.album, color: Colors.white),
              title: const Text(
                'Go to Album',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to album
                final albums = ref.read(albumsProvider);
                if (albums.containsKey(song.album)) {
                  _showAlbumDetails(song.album, albums[song.album]!);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Go to Artist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to artist
                final artists = ref.read(artistsProvider);
                if (artists.containsKey(song.artist)) {
                  _showArtistDetails(song.artist, artists[song.artist]!);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Share song
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text(
                'Song Info',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSongInfoDialog(song);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showSongInfoDialog(MusicFile song) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(song.title, style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Color(0xFF6366F1),
                      size: 80,
                    ),
                  ),
                ),
                _buildInfoRow('Title', song.title),
                _buildInfoRow('Artist', song.artist),
                _buildInfoRow('Album', song.album),
                _buildInfoRow('Duration', _formatDuration(song.duration)),
                _buildInfoRow('File Name', song.fileName),
                _buildInfoRow('File Size', _formatFileSize(song.fileSize)),
                _buildInfoRow(
                  'Date Added',
                  song.dateAdded.toString().split('.')[0],
                ),
                _buildInfoRow('File Path', song.filePath),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAlbumDetails(String albumName, List<MusicFile> songs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final audioState = ref.watch(audioStateProvider);

                return Column(
                  children: [
                    // Album header
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Album art
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.album,
                              color: Color(0xFF6366F1),
                              size: 60,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Album info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  albumName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  songs.isNotEmpty
                                      ? songs.first.artist
                                      : 'Unknown Artist',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${songs.length} songs',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _playAlbum(albumName);
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Shuffle and play
                              final shuffledSongs = List<MusicFile>.from(songs)
                                ..shuffle();
                              ref
                                  .read(audioStateProvider.notifier)
                                  .setPlaylist(shuffledSongs);

                              // Add first song to recently played
                              if (shuffledSongs.isNotEmpty) {
                                addToRecentlyPlayed(ref, shuffledSongs.first);
                              }
                            },
                            icon: const Icon(Icons.shuffle),
                            label: const Text('Shuffle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A2A2A),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.grey),

                    // Song list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          final isCurrentSong =
                              audioState.currentSong?.id == song.id;

                          return ListTile(
                            leading: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color:
                                    isCurrentSong
                                        ? const Color(0xFF6366F1)
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                color:
                                    isCurrentSong
                                        ? const Color(0xFF6366F1)
                                        : Colors.white,
                                fontWeight:
                                    isCurrentSong
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              song.artist,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Text(
                              _formatDuration(song.duration),
                              style: const TextStyle(color: Colors.grey),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              ref
                                  .read(audioStateProvider.notifier)
                                  .setPlaylist(songs, initialIndex: index);
                              addToRecentlyPlayed(ref, song);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showArtistDetails(String artistName, List<MusicFile> songs) {
    // Group songs by album
    final albumMap = <String, List<MusicFile>>{};
    for (final song in songs) {
      if (!albumMap.containsKey(song.album)) {
        albumMap[song.album] = [];
      }
      albumMap[song.album]!.add(song);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final audioState = ref.watch(audioStateProvider);

                return Column(
                  children: [
                    // Artist header
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Artist image
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2A2A2A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF6366F1),
                              size: 60,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Artist info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artistName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${albumMap.length} albums • ${songs.length} songs',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _playArtist(artistName);
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Shuffle and play
                              final shuffledSongs = List<MusicFile>.from(songs)
                                ..shuffle();
                              ref
                                  .read(audioStateProvider.notifier)
                                  .setPlaylist(shuffledSongs);

                              // Add first song to recently played
                              if (shuffledSongs.isNotEmpty) {
                                addToRecentlyPlayed(ref, shuffledSongs.first);
                              }
                            },
                            icon: const Icon(Icons.shuffle),
                            label: const Text('Shuffle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A2A2A),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.grey),

                    // Albums section
                    if (albumMap.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          children: [
                            const Text(
                              'Albums',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${albumMap.length}',
                                style: const TextStyle(
                                  color: Color(0xFF6366F1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: albumMap.length,
                          itemBuilder: (context, index) {
                            final albumName = albumMap.keys.elementAt(index);
                            final albumSongs = albumMap[albumName]!;

                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _showAlbumDetails(albumName, albumSongs);
                              },
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.album,
                                          color: Color(0xFF6366F1),
                                          size: 60,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      albumName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${albumSongs.length} songs',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Songs section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: [
                          const Text(
                            'Songs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${songs.length}',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Song list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          final isCurrentSong =
                              audioState.currentSong?.id == song.id;

                          return ListTile(
                            title: Text(
                              song.title,
                              style: TextStyle(
                                color:
                                    isCurrentSong
                                        ? const Color(0xFF6366F1)
                                        : Colors.white,
                                fontWeight:
                                    isCurrentSong
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              song.album,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Text(
                              _formatDuration(song.duration),
                              style: const TextStyle(color: Colors.grey),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              ref
                                  .read(audioStateProvider.notifier)
                                  .setPlaylist(songs, initialIndex: index);
                              addToRecentlyPlayed(ref, song);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _waveController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          // Header with wave animation
          _buildHeader(),

          // Tab bar
          Container(
            color: const Color(0xFF1A1A1A),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF6366F1),
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Songs'),
                Tab(text: 'Albums'),
                Tab(text: 'Artists'),
                Tab(text: 'Folders'),
                Tab(text: 'Playlists'),
              ],
            ),
          ),

          // Search bar (if searching)
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search your music...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),

          // Scan progress indicator
          Consumer(
            builder: (context, ref, child) {
              final isScanning = ref.watch(isScanningProvider);
              final scanProgressAsyncValue = ref.watch(scanProgressProvider);

              if (isScanning) {
                return scanProgressAsyncValue.when(
                  data: (progress) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: const Color(0xFF2A2A2A),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Scanning: ${progress.foundSongs} songs found',
                                style: const TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(scannerServiceProvider).cancelScan();
                                  ref.read(isScanningProvider.notifier).state =
                                      false;
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF6366F1)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value:
                                progress.totalFiles > 0
                                    ? progress.processedFiles /
                                        progress.totalFiles
                                    : null,
                            backgroundColor: const Color(0xFF1A1A1A),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Current folder: ${progress.currentFolder}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                  loading:
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: const Color(0xFF2A2A2A),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Preparing scan...',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(scannerServiceProvider)
                                        .cancelScan();
                                    ref
                                        .read(isScanningProvider.notifier)
                                        .state = false;
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Color(0xFF6366F1)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const LinearProgressIndicator(
                              backgroundColor: Color(0xFF1A1A1A),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                  error: (_, __) => const SizedBox.shrink(),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          // Tab content
          Expanded(
            child:
                _hasPermission
                    ? ref.watch(allSongsProvider).isEmpty &&
                            !ref.watch(isScanningProvider)
                        ? _buildPermissionRequest()
                        : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSongsTab(),
                            _buildAlbumsTab(),
                            _buildArtistsTab(),
                            _buildFoldersTab(),
                            _buildPlaylistsTab(),
                          ],
                        )
                    : _buildPermissionRequest(),
          ),
        ],
      ),
      // Mini player (if a song is selected)
 
    );
  }

  Widget _buildHeader() {
    return Container(
      height: _isSearching ? 160 : 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
      ),
      child: Stack(
        children: [
          // Wave animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: DeviceSongsWavePainter(_waveAnimation.value),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with title and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Device Music',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isSearching ? Icons.close : Icons.search,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isSearching = !_isSearching;
                                if (!_isSearching) {
                                  _searchController.clear();
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.sort, color: Colors.white),
                            onPressed: _showSortFilterBottomSheet,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.folder_open,
                              color: Colors.white,
                            ),
                            onPressed: _scanDeviceMusic,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Subtitle
                  Consumer(
                    builder: (context, ref, child) {
                      final allSongs = ref.watch(allSongsProvider);
                      return Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          '${allSongs.length} songs on your device',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Scanning for music...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take a moment',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasPermission ? Icons.folder_open : Icons.folder_off,
            color: const Color(0xFF6366F1),
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            _hasPermission ? 'No Music Loaded' : 'Storage Permission Required',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _hasPermission
                  ? 'Select a folder to scan for music files'
                  : 'To access music on your device, we need permission to read your storage',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _hasPermission ? _scanDeviceMusic : _requestPermission,
            icon: Icon(_hasPermission ? Icons.folder_open : Icons.security),
            label: Text(
              _hasPermission ? 'Select Music Folder' : 'Grant Permission',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final filteredSongs = ref.watch(filteredSongsProvider);
        final allSongs = ref.watch(allSongsProvider);
        final recentlyPlayed = ref.watch(recentlyPlayedProvider);
        final searchQuery = ref.watch(searchQueryProvider);
        final currentView = ref.watch(currentViewProvider);
        final isScanning = ref.watch(isScanningProvider);

        if (filteredSongs.isEmpty && allSongs.isEmpty && !isScanning) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_off, color: Color(0xFF6366F1), size: 80),
                const SizedBox(height: 20),
                const Text(
                  'No songs found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the folder icon to select your music directory',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _scanDeviceMusic,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select Music Folder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (filteredSongs.isEmpty && !isScanning) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  color: Color(0xFF6366F1),
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'No songs match "$searchQuery"',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try a different search term',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Recently played section
            if (recentlyPlayed.isNotEmpty && searchQuery.isEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recently Played',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(color: Color(0xFF6366F1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: math.min(5, recentlyPlayed.length),
                    itemBuilder: (context, index) {
                      final song = recentlyPlayed[index];
                      return _buildRecentlyPlayedItem(song);
                    },
                  ),
                ),
              ),
            ],

            // All songs section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    const Text(
                      'All Songs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredSongs.length}',
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Songs list
            currentView == 'List'
                ? SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = filteredSongs[index];
                    return _buildSongItem(song);
                  }, childCount: filteredSongs.length),
                )
                : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = filteredSongs[index];
                      return _buildSongGridItem(song);
                    }, childCount: filteredSongs.length),
                  ),
                ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final albums = ref.watch(albumsProvider);
        final isScanning = ref.watch(isScanningProvider);

        if (albums.isEmpty && !isScanning) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.album_outlined, color: Color(0xFF6366F1), size: 80),
                SizedBox(height: 20),
                Text(
                  'No albums found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Select a music folder to see albums',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final albumName = albums.keys.elementAt(index);
            final albumSongs = albums[albumName]!;
            return GestureDetector(
              onTap: () => _showAlbumDetails(albumName, albumSongs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.album,
                          color: Color(0xFF6366F1),
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    albumName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    albumSongs.isNotEmpty
                        ? albumSongs.first.artist
                        : 'Unknown Artist',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${albumSongs.length} songs',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArtistsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final artists = ref.watch(artistsProvider);
        final isScanning = ref.watch(isScanningProvider);

        if (artists.isEmpty && !isScanning) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, color: Color(0xFF6366F1), size: 80),
                SizedBox(height: 20),
                Text(
                  'No artists found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Select a music folder to see artists',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artistName = artists.keys.elementAt(index);
            final artistSongs = artists[artistName]!;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF6366F1),
                  size: 30,
                ),
              ),
              title: Text(
                artistName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${artistSongs.map((s) => s.album).toSet().length} albums • ${artistSongs.length} songs',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showArtistDetails(artistName, artistSongs),
            );
          },
        );
      },
    );
  }

  Widget _buildFoldersTab() {
    return Consumer(
      builder: (context, ref, child) {
        final folders = ref.watch(foldersProvider);
        final isScanning = ref.watch(isScanningProvider);

        if (folders.isEmpty && !isScanning) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_outlined, color: Color(0xFF6366F1), size: 80),
                SizedBox(height: 20),
                Text(
                  'No folders found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Select a music folder to see folders',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folderName = folders.keys.elementAt(index);
            final folderSongs = folders[folderName]!;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder,
                  color: Color(0xFF6366F1),
                  size: 30,
                ),
              ),
              title: Text(
                folderName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${folderSongs.length} songs',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                _playFolder(folderName);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue_music, color: Color(0xFF6366F1), size: 80),
          SizedBox(height: 20),
          Text(
            'Playlists coming soon',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Create and manage your playlists',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayedItem(MusicFile song) {
    return GestureDetector(
      onTap: () => _playSong(song),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.music_note,
                  color: Color(0xFF6366F1),
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongItem(MusicFile song) {
    return Consumer(
      builder: (context, ref, child) {
        final audioState = ref.watch(audioStateProvider);
        final isCurrentSong = audioState.currentSong?.id == song.id;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.music_note,
              color: Color(0xFF6366F1),
              size: 30,
            ),
          ),
          title: Text(
            song.title,
            style: TextStyle(
              color: isCurrentSong ? const Color(0xFF6366F1) : Colors.white,
              fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${song.artist} • ${song.album}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDuration(song.duration),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _showSongOptionsBottomSheet(song),
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
          onTap: () => _playSong(song),
        );
      },
    );
  }

  Widget _buildSongGridItem(MusicFile song) {
    return Consumer(
      builder: (context, ref, child) {
        final audioState = ref.watch(audioStateProvider);
        final isCurrentSong = audioState.currentSong?.id == song.id;

        return GestureDetector(
          onTap: () => _playSong(song),
          onLongPress: () => _showSongOptionsBottomSheet(song),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        isCurrentSong
                            ? Border.all(
                              color: const Color(0xFF6366F1),
                              width: 2,
                            )
                            : null,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.music_note,
                      color: Color(0xFF6366F1),
                      size: 50,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                song.title,
                style: TextStyle(
                  color: isCurrentSong ? const Color(0xFF6366F1) : Colors.white,
                  fontSize: 14,
                  fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                song.artist,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniPlayer() {
    return Consumer(
      builder: (context, ref, child) {
        final audioState = ref.watch(audioStateProvider);
        final currentSong = audioState.currentSong;

        if (currentSong == null) return const SizedBox.shrink();

        return Container(
          height: 70,
          color: const Color(0xFF1A1A1A),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.music_note,
                color: Color(0xFF6366F1),
                size: 30,
              ),
            ),
            title: Text(
              currentSong.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              currentSong.artist,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed:
                      () =>
                          ref.read(audioStateProvider.notifier).playPrevious(),
                ),
                IconButton(
                  icon: Icon(
                    audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed:
                      () =>
                          ref
                              .read(audioStateProvider.notifier)
                              .togglePlayPause(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed:
                      () => ref.read(audioStateProvider.notifier).playNext(),
                ),
              ],
            ),
            onTap: () {
              // Navigate to now playing screen
            },
          ),
        );
      },
    );
  }
}

// Custom painter for wave animation
class DeviceSongsWavePainter extends CustomPainter {
  final double animationValue;

  DeviceSongsWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    final waveHeight = 15.0;
    final waveLength = size.width / 3;

    for (int i = 0; i < 3; i++) {
      path.reset();
      final yOffset = size.height * 0.3 + (i * 20);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            yOffset +
            waveHeight *
                math.sin(
                  (x / waveLength * 2 * math.pi) + animationValue + (i * 0.7),
                );
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
