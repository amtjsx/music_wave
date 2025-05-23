import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/download_setting.dart';
import 'package:music/screens/download/storage_location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Provider for download settings
final downloadSettingsProvider =
    StateNotifierProvider<DownloadSettingsNotifier, DownloadSettings>((ref) {
      return DownloadSettingsNotifier();
    });

// Provider for available storage locations
final storageLocationsProvider = FutureProvider<List<StorageLocation>>((
  ref,
) async {
  return await _getAvailableStorageLocations();
});

// Provider for storage space info
final storageSpaceProvider = FutureProvider.family<StorageSpaceInfo, String>((
  ref,
  path,
) async {
  return await _getStorageSpaceInfo(path);
});

// Notifier for download settings
class DownloadSettingsNotifier extends StateNotifier<DownloadSettings> {
  DownloadSettingsNotifier() : super(DownloadSettings.defaultSettings()) {
    _loadSettings();
  }

  // Load settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('downloadSettings');

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        state = DownloadSettings.fromMap(settingsMap);
      } else {
        // Initialize with default settings and default storage location
        final defaultLocation = await _getDefaultStorageLocation();
        state = DownloadSettings.defaultSettings().copyWith(
          storageLocation: defaultLocation,
        );
        await _saveSettings();
      }
    } catch (e) {
      print('Error loading settings: $e');
      // Initialize with default settings and default storage location
      final defaultLocation = await _getDefaultStorageLocation();
      state = DownloadSettings.defaultSettings().copyWith(
        storageLocation: defaultLocation,
      );
      await _saveSettings();
    }
  }

  // Save settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(state.toMap());
      await prefs.setString('downloadSettings', settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Update download quality
  void updateQuality(DownloadQuality quality) {
    state = state.copyWith(quality: quality);
    _saveSettings();
  }

  // Update storage location
  void updateStorageLocation(String location) {
    state = state.copyWith(storageLocation: location);
    _saveSettings();
  }

  // Update folder organization settings
  void updateFolderSettings({
    bool? createArtistFolders,
    bool? createAlbumFolders,
  }) {
    state = state.copyWith(
      createArtistFolders: createArtistFolders,
      createAlbumFolders: createAlbumFolders,
    );
    _saveSettings();
  }

  // Update artwork download setting
  void updateDownloadArtwork(bool downloadArtwork) {
    state = state.copyWith(downloadArtwork: downloadArtwork);
    _saveSettings();
  }

  // Update WiFi only setting
  void updateWifiOnly(bool wifiOnly) {
    state = state.copyWith(wifiOnly: wifiOnly);
    _saveSettings();
  }

  // Update max concurrent downloads
  void updateMaxConcurrentDownloads(int maxConcurrentDownloads) {
    state = state.copyWith(maxConcurrentDownloads: maxConcurrentDownloads);
    _saveSettings();
  }

  // Update auto download lyrics setting
  void updateAutoDownloadLyrics(bool autoDownloadLyrics) {
    state = state.copyWith(autoDownloadLyrics: autoDownloadLyrics);
    _saveSettings();
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    final defaultLocation = await _getDefaultStorageLocation();
    state = DownloadSettings.defaultSettings().copyWith(
      storageLocation: defaultLocation,
    );
    _saveSettings();
  }
}

// Get default storage location
Future<String> _getDefaultStorageLocation() async {
  try {
    if (Platform.isAndroid) {
      // For Android, use the Music directory in external storage
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final musicDir = Directory('${directory.path}/Music');
        if (!await musicDir.exists()) {
          await musicDir.create(recursive: true);
        }
        return musicDir.path;
      }
    }

    // Fallback to application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${directory.path}/Music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }
    return musicDir.path;
  } catch (e) {
    print('Error getting default storage location: $e');
    // Fallback to application documents directory
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

// Get available storage locations
Future<List<StorageLocation>> _getAvailableStorageLocations() async {
  final List<StorageLocation> locations = [];

  try {
    if (Platform.isAndroid) {
      // Internal storage
      final internalDir = await getApplicationDocumentsDirectory();
      final internalMusicDir = Directory('${internalDir.path}/Music');
      if (!await internalMusicDir.exists()) {
        await internalMusicDir.create(recursive: true);
      }

      final internalSpaceInfo = await _getStorageSpaceInfo(
        internalMusicDir.path,
      );
      locations.add(
        StorageLocation(
          id: 'internal',
          name: 'Internal Storage',
          path: internalMusicDir.path,
          isRemovable: false,
          spaceInfo: internalSpaceInfo,
        ),
      );

      // External storage (primary)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final externalMusicDir = Directory('${externalDir.path}/Music');
        if (!await externalMusicDir.exists()) {
          await externalMusicDir.create(recursive: true);
        }

        final externalSpaceInfo = await _getStorageSpaceInfo(
          externalMusicDir.path,
        );
        locations.add(
          StorageLocation(
            id: 'external_primary',
            name: 'SD Card',
            path: externalMusicDir.path,
            isRemovable: true,
            spaceInfo: externalSpaceInfo,
          ),
        );
      }

      // TODO: Add support for secondary external storage (multiple SD cards)
      // This requires more complex Android-specific code
    } else if (Platform.isIOS) {
      // iOS only has one storage location
      final directory = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${directory.path}/Music');
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      final spaceInfo = await _getStorageSpaceInfo(musicDir.path);
      locations.add(
        StorageLocation(
          id: 'ios_documents',
          name: 'iPhone Storage',
          path: musicDir.path,
          isRemovable: false,
          spaceInfo: spaceInfo,
        ),
      );
    }

    // Add custom locations from user preferences
    // This would require additional code to manage custom locations

    return locations;
  } catch (e) {
    print('Error getting storage locations: $e');

    // Fallback to application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${directory.path}/Music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }

    final spaceInfo = await _getStorageSpaceInfo(musicDir.path);
    locations.add(
      StorageLocation(
        id: 'fallback',
        name: 'Device Storage',
        path: musicDir.path,
        isRemovable: false,
        spaceInfo: spaceInfo,
      ),
    );

    return locations;
  }
}

// Get storage space information
Future<StorageSpaceInfo> _getStorageSpaceInfo(String path) async {
  try {
    final directory = Directory(path);
    final stat = await directory.stat();

    // This is a simplified approach - getting actual free space requires platform-specific code
    // For a real app, you would use a plugin like disk_space or platform channels

    // Simulate getting storage info
    // In a real app, you would get actual values from the device
    final totalSpace = 64 * 1024 * 1024 * 1024; // 64 GB
    final freeSpace = 12 * 1024 * 1024 * 1024; // 12 GB

    return StorageSpaceInfo(
      totalSpace: totalSpace,
      freeSpace: freeSpace,
      usedSpace: totalSpace - freeSpace,
    );
  } catch (e) {
    print('Error getting storage space info: $e');

    // Return default values
    return StorageSpaceInfo(totalSpace: 0, freeSpace: 0, usedSpace: 0);
  }
}
