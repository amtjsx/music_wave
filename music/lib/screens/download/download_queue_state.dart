import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/song.dart';
import 'package:music/screens/download/download_item.dart';
import 'package:music/screens/download/setting_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// State class for download queue
class DownloadQueueState {
  final Queue<DownloadItem> queue;
  final Map<String, DownloadItem> activeDownloads;
  final Map<String, DownloadItem> allDownloads;
  final int maxConcurrentDownloads;

  DownloadQueueState({
    required this.queue,
    required this.activeDownloads,
    required this.allDownloads,
    this.maxConcurrentDownloads = 3,
  });

  // Constructor for initial state
  DownloadQueueState.initial()
    : queue = Queue<DownloadItem>(),
      activeDownloads = {},
      allDownloads = {},
      maxConcurrentDownloads = 3;

  // Copy with method for immutability
  DownloadQueueState copyWith({
    Queue<DownloadItem>? queue,
    Map<String, DownloadItem>? activeDownloads,
    Map<String, DownloadItem>? allDownloads,
    int? maxConcurrentDownloads,
  }) {
    return DownloadQueueState(
      queue: queue ?? Queue<DownloadItem>.from(this.queue),
      activeDownloads:
          activeDownloads ??
          Map<String, DownloadItem>.from(this.activeDownloads),
      allDownloads:
          allDownloads ?? Map<String, DownloadItem>.from(this.allDownloads),
      maxConcurrentDownloads:
          maxConcurrentDownloads ?? this.maxConcurrentDownloads,
    );
  }

  // Getters for download lists
  List<DownloadItem> get queuedDownloads => queue.toList();
  List<DownloadItem> get activeDownloadsList => activeDownloads.values.toList();
  List<DownloadItem> get allDownloadsList => allDownloads.values.toList();
  List<DownloadItem> get completedDownloads =>
      allDownloads.values
          .where((item) => item.status == DownloadStatus.completed)
          .toList();
  List<DownloadItem> get failedDownloads =>
      allDownloads.values
          .where((item) => item.status == DownloadStatus.failed)
          .toList();
}

// Stream controllers for download events
final downloadAddedController = StreamController<DownloadItem>.broadcast();
final downloadProgressController = StreamController<DownloadItem>.broadcast();
final downloadCompletedController = StreamController<DownloadItem>.broadcast();
final downloadFailedController = StreamController<DownloadItem>.broadcast();
final downloadPausedController = StreamController<DownloadItem>.broadcast();
final downloadResumedController = StreamController<DownloadItem>.broadcast();
final downloadCancelledController = StreamController<DownloadItem>.broadcast();

// Streams for download events
Stream<DownloadItem> get onDownloadAdded => downloadAddedController.stream;
Stream<DownloadItem> get onDownloadProgress =>
    downloadProgressController.stream;
Stream<DownloadItem> get onDownloadCompleted =>
    downloadCompletedController.stream;
Stream<DownloadItem> get onDownloadFailed => downloadFailedController.stream;
Stream<DownloadItem> get onDownloadPaused => downloadPausedController.stream;
Stream<DownloadItem> get onDownloadResumed => downloadResumedController.stream;
Stream<DownloadItem> get onDownloadCancelled =>
    downloadCancelledController.stream;

// Provider for download queue state
final downloadQueueProvider =
    StateNotifierProvider<DownloadQueueNotifier, DownloadQueueState>((ref) {
      return DownloadQueueNotifier();
    });

// Notifier for download queue state
class DownloadQueueNotifier extends StateNotifier<DownloadQueueState> {
  DownloadQueueNotifier() : super(DownloadQueueState.initial());

  // Start a download
  Future<void> _startDownload(DownloadItem item) async {
    // Update status
    final updatedItem = item.copyWith(
      status: DownloadStatus.downloading,
      startedAt: DateTime.now(),
    );

    // Update state
    final newActiveDownloads = Map<String, DownloadItem>.from(
      state.activeDownloads,
    )..[item.id] = updatedItem;
    final newAllDownloads = Map<String, DownloadItem>.from(state.allDownloads)
      ..[item.id] = updatedItem;

    state = state.copyWith(
      activeDownloads: newActiveDownloads,
      allDownloads: newAllDownloads,
    );

    try {
      // Get download settings
      final settingsProvider = ProviderContainer().read(
        downloadSettingsProvider,
      );

      // Check if we're on WiFi if WiFi-only setting is enabled
      if (settingsProvider.wifiOnly) {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult != ConnectivityResult.wifi) {
          throw Exception(
            'Downloads are set to WiFi only. Connect to WiFi and try again.',
          );
        }
      }

      // Get base directory from settings
      final baseDir = Directory(settingsProvider.storageLocation);
      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      // Determine file path based on folder organization settings
      String filePath;
      if (settingsProvider.createArtistFolders) {
        final artistDir = Directory(
          '${baseDir.path}/${updatedItem.song.artist}',
        );
        if (!await artistDir.exists()) {
          await artistDir.create(recursive: true);
        }

        if (settingsProvider.createAlbumFolders) {
          final albumDir = Directory(
            '${artistDir.path}/${updatedItem.albumName}',
          );
          if (!await albumDir.exists()) {
            await albumDir.create(recursive: true);
          }
          filePath =
              '${albumDir.path}/${updatedItem.song.title}.${settingsProvider.fileExtension}';
        } else {
          filePath =
              '${artistDir.path}/${updatedItem.song.title}.${settingsProvider.fileExtension}';
        }
      } else {
        filePath =
            '${baseDir.path}/${updatedItem.song.title}.${settingsProvider.fileExtension}';
      }

      final file = File(filePath);

      // In a real app, you would download from a URL with the appropriate quality
      // For this example, we'll simulate a download

      // Simulate download with periodic updates
      int totalChunks = 100;
      for (int i = 0; i < totalChunks; i++) {
        // Get current item state
        final currentItem = state.allDownloads[item.id];
        if (currentItem == null) {
          // Item was removed
          return;
        }

        // Check if download was cancelled or paused
        if (currentItem.status == DownloadStatus.cancelled) {
          // Remove from active downloads
          final newActiveDownloads = Map<String, DownloadItem>.from(
            state.activeDownloads,
          )..remove(item.id);

          state = state.copyWith(activeDownloads: newActiveDownloads);
          return;
        } else if (currentItem.status == DownloadStatus.paused) {
          // Wait until resumed
          await currentItem.pauseCompleter.future;

          // Get updated item after pause
          final updatedItem = state.allDownloads[item.id];
          if (updatedItem == null ||
              updatedItem.status != DownloadStatus.downloading) {
            // Item was removed or status changed
            return;
          }
        }

        // Update progress
        final progress = (i + 1) / totalChunks;
        final progressItem = currentItem.copyWith(progress: progress);

        // Update state
        final newActiveDownloads = Map<String, DownloadItem>.from(
          state.activeDownloads,
        )..[item.id] = progressItem;
        final newAllDownloads = Map<String, DownloadItem>.from(
          state.allDownloads,
        )..[item.id] = progressItem;

        state = state.copyWith(
          activeDownloads: newActiveDownloads,
          allDownloads: newAllDownloads,
        );

        // Notify listeners
        downloadProgressController.add(progressItem);

        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Create the file
      await file.writeAsString(
        'Simulated downloaded content for ${updatedItem.song.title}',
      );

      // Save metadata
      final metadataFile = File(
        '${file.path.substring(0, file.path.lastIndexOf('.'))}.json',
      );
      await metadataFile.writeAsString('''
    {
      "id": "${updatedItem.song.id}",
      "title": "${updatedItem.song.title}",
      "artist": "${updatedItem.song.artist}",
      "album": "${updatedItem.albumName}",
      "duration": "${updatedItem.song.duration}",
      "quality": "${settingsProvider.qualityString}",
      "downloadDate": "${DateTime.now().toIso8601String()}"
    }
    ''');

      // Download album artwork if enabled
      if (settingsProvider.downloadArtwork) {
        try {
          final artworkDir = file.parent;
          final artworkFile = File('${artworkDir.path}/cover.jpg');

          // In a real app, you would download the artwork from a URL
          // For this example, we'll simulate downloading artwork
          await Future.delayed(const Duration(milliseconds: 500));
          await artworkFile.writeAsString('Simulated artwork content');
        } catch (e) {
          print('Error downloading artwork: $e');
          // Continue even if artwork download fails
        }
      }

      // Download lyrics if enabled
      if (settingsProvider.autoDownloadLyrics) {
        try {
          final lyricsFile = File(
            '${file.path.substring(0, file.path.lastIndexOf('.'))}.lrc',
          );

          // In a real app, you would download lyrics from a service
          // For this example, we'll simulate downloading lyrics
          await Future.delayed(const Duration(milliseconds: 300));
          await lyricsFile.writeAsString('Simulated lyrics content');
        } catch (e) {
          print('Error downloading lyrics: $e');
          // Continue even if lyrics download fails
        }
      }

      // Update status
      final completedItem = updatedItem.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        completedAt: DateTime.now(),
      );

      // Update state
      final newActiveDownloads = Map<String, DownloadItem>.from(
        state.activeDownloads,
      )..remove(item.id);
      final newAllDownloads = Map<String, DownloadItem>.from(state.allDownloads)
        ..[item.id] = completedItem;

      state = state.copyWith(
        activeDownloads: newActiveDownloads,
        allDownloads: newAllDownloads,
      );

      // Notify listeners
      downloadCompletedController.add(completedItem);

      // Process queue for next download
      _processQueue();
    } catch (e) {
      // Update status
      final failedItem = updatedItem.copyWith(
        status: DownloadStatus.failed,
        error: e.toString(),
      );

      // Update state
      final newActiveDownloads = Map<String, DownloadItem>.from(
        state.activeDownloads,
      )..remove(item.id);
      final newAllDownloads = Map<String, DownloadItem>.from(state.allDownloads)
        ..[item.id] = failedItem;

      state = state.copyWith(
        activeDownloads: newActiveDownloads,
        allDownloads: newAllDownloads,
      );

      // Notify listeners
      downloadFailedController.add(failedItem);

      // Process queue for next download
      _processQueue();
    }
  }

  // Also update the _processQueue method to respect maxConcurrentDownloads from settings:

  // Process the download queue
  Future<void> _processQueue() async {
    // Get max concurrent downloads from settings
    final settingsProvider = ProviderContainer().read(downloadSettingsProvider);
    final maxConcurrent = settingsProvider.maxConcurrentDownloads;

    // Check if we can start more downloads
    while (state.activeDownloads.length < maxConcurrent &&
        state.queue.isNotEmpty) {
      // Get next download from queue
      final newQueue = Queue<DownloadItem>.from(state.queue);
      final downloadItem = newQueue.removeFirst();

      // Check if we have permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        // Put back in queue and stop processing
        newQueue.addFirst(downloadItem);
        state = state.copyWith(queue: newQueue);
        break;
      }

      // Update state
      state = state.copyWith(queue: newQueue);

      // Start download
      _startDownload(downloadItem);
    }
  }

  // Add a download to the queue
  Future<void> addToQueue(Song song, String albumName) async {
    // Check if already in queue or active
    if (state.allDownloads.containsKey(song.id)) {
      final existingItem = state.allDownloads[song.id]!;
      if (existingItem.status == DownloadStatus.completed) {
        // Already downloaded
        return;
      } else if (existingItem.status == DownloadStatus.paused ||
          existingItem.status == DownloadStatus.failed) {
        // Resume paused or retry failed download
        final updatedItem = existingItem.copyWith(
          status: DownloadStatus.queued,
          progress: 0.0,
          error: null,
        );

        // Update state
        final newQueue = Queue<DownloadItem>.from(state.queue)
          ..add(updatedItem);
        final newAllDownloads = Map<String, DownloadItem>.from(
          state.allDownloads,
        )..[song.id] = updatedItem;

        state = state.copyWith(queue: newQueue, allDownloads: newAllDownloads);

        // Notify listeners
        downloadAddedController.add(updatedItem);

        // Process queue
        _processQueue();
        return;
      } else if (existingItem.status == DownloadStatus.downloading ||
          existingItem.status == DownloadStatus.queued) {
        // Already downloading or queued
        return;
      }
    }

    // Create new download item
    final downloadItem = DownloadItem(
      id: song.id,
      song: song,
      albumName: albumName,
      status: DownloadStatus.queued,
      progress: 0.0,
      addedAt: DateTime.now(),
    );

    // Update state
    final newQueue = Queue<DownloadItem>.from(state.queue)..add(downloadItem);
    final newAllDownloads = Map<String, DownloadItem>.from(state.allDownloads)
      ..[song.id] = downloadItem;

    state = state.copyWith(queue: newQueue, allDownloads: newAllDownloads);

    // Notify listeners
    downloadAddedController.add(downloadItem);

    // Process queue
    _processQueue();
  }

  // Pause a download
  void pauseDownload(String id) {
    final item = state.allDownloads[id];
    if (item != null && item.status == DownloadStatus.downloading) {
      // Create new pause completer
      final pauseCompleter = Completer<void>();

      // Update item
      final pausedItem = item.copyWith(
        status: DownloadStatus.paused,
        pauseCompleter: pauseCompleter,
      );

      // Update state
      final newActiveDownloads = Map<String, DownloadItem>.from(
        state.activeDownloads,
      )..[id] = pausedItem;
      final newAllDownloads = Map<String, DownloadItem>.from(state.allDownloads)
        ..[id] = pausedItem;

      state = state.copyWith(
        activeDownloads: newActiveDownloads,
        allDownloads: newAllDownloads,
      );

      // Notify listeners
      downloadPausedController.add(pausedItem);
    }
  }

  // Resume a paused download
  void resumeDownload(String id) {
    final item = state.allDownloads[id];
    if (item != null && item.status == DownloadStatus.paused) {
      // Update item
      final resumedItem = item.copyWith(status: DownloadStatus.downloading);

      // Update state
      final newActiveDownloads = Map<String, DownloadItem>.from(
        state.activeDownloads,
      )..[id] = resumedItem;
      final newAllDownloads = Map<String, DownloadItem>.from(state.allDownloads)
        ..[id] = resumedItem;

      state = state.copyWith(
        activeDownloads: newActiveDownloads,
        allDownloads: newAllDownloads,
      );

      // Complete the pause completer to resume download
      if (!item.pauseCompleter.isCompleted) {
        item.pauseCompleter.complete();
      }

      // Notify listeners
      downloadResumedController.add(resumedItem);
    } else if (item != null && item.status == DownloadStatus.failed) {
      // Retry failed download
      final retriedItem = item.copyWith(
        status: DownloadStatus.queued,
        progress: 0.0,
        error: null,
      );

      // Update state
      final newQueue = Queue<DownloadItem>.from(state.queue)..add(retriedItem);
      final newAllDownloads = Map<String, DownloadItem>.from(state.allDownloads)
        ..[id] = retriedItem;

      state = state.copyWith(queue: newQueue, allDownloads: newAllDownloads);

      // Notify listeners
      downloadAddedController.add(retriedItem);

      // Process queue
      _processQueue();
    }
  }

  // Cancel a download
  void cancelDownload(String id) {
    final item = state.allDownloads[id];
    if (item != null) {
      // Create a copy of the current state components
      final newQueue = Queue<DownloadItem>.from(state.queue);
      final newActiveDownloads = Map<String, DownloadItem>.from(
        state.activeDownloads,
      );
      final newAllDownloads = Map<String, DownloadItem>.from(
        state.allDownloads,
      );

      if (item.status == DownloadStatus.queued) {
        // Remove from queue
        newQueue.removeWhere((element) => element.id == id);
      } else if (item.status == DownloadStatus.downloading) {
        // Mark as cancelled
        final cancelledItem = item.copyWith(status: DownloadStatus.cancelled);
        newActiveDownloads[id] = cancelledItem;
        newAllDownloads[id] = cancelledItem;

        // Notify listeners
        downloadCancelledController.add(cancelledItem);
      } else if (item.status == DownloadStatus.paused) {
        // Complete the pause completer to allow cleanup
        if (!item.pauseCompleter.isCompleted) {
          item.pauseCompleter.complete();
        }

        // Mark as cancelled
        final cancelledItem = item.copyWith(status: DownloadStatus.cancelled);
        newActiveDownloads[id] = cancelledItem;
        newAllDownloads[id] = cancelledItem;

        // Notify listeners
        downloadCancelledController.add(cancelledItem);
      }

      // Remove from active downloads and all downloads
      newActiveDownloads.remove(id);
      newAllDownloads.remove(id);

      // Update state
      state = state.copyWith(
        queue: newQueue,
        activeDownloads: newActiveDownloads,
        allDownloads: newAllDownloads,
      );

      // Process queue for next download
      _processQueue();
    }
  }

  // Cancel all downloads
  void cancelAllDownloads() {
    // Notify listeners for all active downloads
    for (final item in state.activeDownloads.values) {
      final cancelledItem = item.copyWith(status: DownloadStatus.cancelled);
      downloadCancelledController.add(cancelledItem);

      // Complete pause completers
      if (item.status == DownloadStatus.paused &&
          !item.pauseCompleter.isCompleted) {
        item.pauseCompleter.complete();
      }
    }

    // Reset state
    state = DownloadQueueState.initial();
  }

  // Prioritize a download (move to front of queue)
  void prioritizeDownload(String id) {
    final item = state.allDownloads[id];
    if (item != null && item.status == DownloadStatus.queued) {
      // Create a new queue without the item
      final newQueue = Queue<DownloadItem>.from(state.queue)
        ..removeWhere((element) => element.id == id);

      // Add to front of queue
      newQueue.addFirst(item);

      // Update state
      state = state.copyWith(queue: newQueue);
    }
  }

  // Check if a song is downloaded
  Future<bool> isDownloaded(String songId) async {
    try {
      final item = state.allDownloads[songId];
      if (item != null && item.status == DownloadStatus.completed) {
        return true;
      }

      // Check file system
      final directory = await _getDownloadDirectory();

      // In a real app, you would need to search for the file
      // For this example, we'll just return false
      return false;
    } catch (e) {
      return false;
    }
  }

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Check Android version
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+
        // Request the specific media permissions
        final audioStatus = await Permission.audio.status;
        if (audioStatus.isGranted) {
          return true;
        }

        final result = await Permission.audio.request();
        return result.isGranted;
      } else if (sdkInt >= 29) {
        // Android 10+
        // For Android 10 and 11, we still use storage permission
        final status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }

        final result = await Permission.storage.request();
        return result.isGranted;
      } else {
        // Android 9 and below
        final status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }

        final result = await Permission.storage.request();
        return result.isGranted;
      }
    }

    // For iOS, we don't need explicit permission for downloads
    return true;
  }

  // Get the download directory
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // For Android, use the external storage directory
      return await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      // For iOS, use the documents directory
      return await getApplicationDocumentsDirectory();
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Permission.storage.request();
  }
}
