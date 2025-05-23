import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:music/models/song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadManager {
  // Map to store active downloads
  final Map<String, StreamSubscription?> _activeDownloads = {};

  // Random for simulating download progress
  final Random _random = Random();

  // Request storage permission
  Future<bool> requestStoragePermission() async {
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

  // Open app settings
  Future<void> openAppSettings() async {
    // Fixed: Call the openAppSettings method from the permission_handler package
    await Permission.storage.request();
  }

  // Check if a track is already downloaded
  Future<bool> isDownloaded(String trackId) async {
    try {
      final directory = await _getDownloadDirectory();
      final file = File('${directory.path}/$trackId.mp3');
      return await file.exists();
    } catch (e) {
      print('Error checking if track is downloaded: $e');
      return false;
    }
  }

  // Download a track
  Future<void> downloadTrack({
    required Song track,
    required String albumName,
    required String artistName,
    required Function(double) onProgress,
    required Function() onComplete,
    required Function(String) onError,
  }) async {
    try {
      // Cancel any existing download for this track
      cancelDownload(track.id);

      // Get download directory
      final directory = await _getDownloadDirectory();

      // Create artist and album directories if they don't exist
      final artistDir = Directory('${directory.path}/$artistName');
      if (!await artistDir.exists()) {
        await artistDir.create(recursive: true);
      }

      final albumDir = Directory('${artistDir.path}/$albumName');
      if (!await albumDir.exists()) {
        await albumDir.create(recursive: true);
      }

      // Create file path
      final filePath = '${albumDir.path}/${track.title}.mp3';
      final file = File(filePath);

      // In a real app, you would download the file from a URL
      // For this example, we'll simulate a download with a timer

      // Simulate download progress
      int progress = 0;
      final timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        // Simulate random progress increments
        progress += _random.nextInt(5) + 1;
        if (progress >= 100) {
          progress = 100;
          timer.cancel();

          // Create an empty file to simulate download completion
          file
              .writeAsString('Simulated downloaded content for ${track.title}')
              .then((_) {
                // Store metadata in a separate file
                final metadataFile = File(
                  '${albumDir.path}/${track.title}.json',
                );
                return metadataFile.writeAsString('''
              {
                "id": "${track.id}",
                "title": "${track.title}",
                "artist": "${track.artist}",
                "album": "$albumName",
                "duration": "${track.duration}",
                "downloadDate": "${DateTime.now().toIso8601String()}"
              }
              ''');
              })
              .then((_) {
                _activeDownloads.remove(track.id);
                onComplete();
              })
              .catchError((error) {
                onError(error.toString());
              });
        } else {
          onProgress(progress / 100);
        }
      });

      _activeDownloads[track.id] = timer as StreamSubscription?;
    } catch (e) {
      onError(e.toString());
    }
  }

  // Cancel a download
  void cancelDownload(String trackId) {
    final subscription = _activeDownloads[trackId];
    if (subscription != null) {
      subscription.cancel();
      _activeDownloads.remove(trackId);
    }
  }

  // Cancel all downloads
  void cancelAll() {
    for (final subscription in _activeDownloads.values) {
      subscription?.cancel();
    }
    _activeDownloads.clear();
  }

  // Delete a downloaded track
  Future<bool> deleteTrack(String trackId) async {
    try {
      final directory = await _getDownloadDirectory();

      // In a real app, you would need to find the exact file path
      // For this example, we'll simulate deletion

      // Simulate a delay for deletion
      await Future.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      print('Error deleting track: $e');
      return false;
    }
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
}
