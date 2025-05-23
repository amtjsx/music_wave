import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/download_setting.dart';
import 'package:music/screens/download/setting_provider.dart';
import 'package:music/screens/download/storage_location.dart';

class DownloadSettingsScreen extends ConsumerStatefulWidget {
  const DownloadSettingsScreen({super.key});

  @override
  ConsumerState<DownloadSettingsScreen> createState() =>
      _DownloadSettingsScreenState();
}

class _DownloadSettingsScreenState
    extends ConsumerState<DownloadSettingsScreen> {
  bool _isCreatingCustomFolder = false;
  final TextEditingController _folderNameController = TextEditingController();

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(downloadSettingsProvider);
    final storageLocations = ref.watch(storageLocationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to defaults',
            onPressed: () => _showResetConfirmationDialog(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Download Quality Section
          _buildSectionHeader('Download Quality', theme),
          _buildQualitySelector(settings),
          const SizedBox(height: 24),

          // Storage Location Section
          _buildSectionHeader('Storage Location', theme),
          storageLocations.when(
            data:
                (locations) =>
                    _buildStorageLocationSelector(locations, settings),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) =>
                    Text('Error loading storage locations: $error'),
          ),
          const SizedBox(height: 24),

          // Folder Organization Section
          _buildSectionHeader('Folder Organization', theme),
          _buildFolderOrganizationSettings(settings),
          const SizedBox(height: 24),

          // Additional Settings Section
          _buildSectionHeader('Additional Settings', theme),
          _buildAdditionalSettings(settings),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQualitySelector(DownloadSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quality options
            _buildQualityOption(
              DownloadQuality.low,
              'Low (128 kbps)',
              'Smaller files, lower quality',
              settings,
            ),
            const Divider(),
            _buildQualityOption(
              DownloadQuality.medium,
              'Medium (256 kbps)',
              'Balanced quality and size',
              settings,
            ),
            const Divider(),
            _buildQualityOption(
              DownloadQuality.high,
              'High (320 kbps)',
              'High quality, larger files',
              settings,
            ),
            const Divider(),
            _buildQualityOption(
              DownloadQuality.lossless,
              'Lossless (FLAC)',
              'Best quality, largest files',
              settings,
            ),

            // File size estimate
            const SizedBox(height: 16),
            Text(
              'Estimated file size: ${_getFileSizeEstimate(settings)} per minute',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(
    DownloadQuality quality,
    String title,
    String subtitle,
    DownloadSettings settings,
  ) {
    return RadioListTile<DownloadQuality>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: quality,
      groupValue: settings.quality,
      onChanged: (value) {
        if (value != null) {
          ref.read(downloadSettingsProvider.notifier).updateQuality(value);
        }
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  String _getFileSizeEstimate(DownloadSettings settings) {
    final sizePerMinute = settings.getFileSizeEstimate(1.0);

    if (sizePerMinute >= 1.0) {
      return '${sizePerMinute.toStringAsFixed(1)} MB';
    } else {
      return '${(sizePerMinute * 1024).toStringAsFixed(0)} KB';
    }
  }

  Widget _buildStorageLocationSelector(
    List<StorageLocation> locations,
    DownloadSettings settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Storage locations
            ...locations.map(
              (location) => _buildStorageLocationOption(location, settings),
            ),

            // Add custom folder button
            const SizedBox(height: 8),
            if (!_isCreatingCustomFolder)
              TextButton.icon(
                icon: const Icon(Icons.create_new_folder),
                label: const Text('Create Custom Folder'),
                onPressed: () {
                  setState(() {
                    _isCreatingCustomFolder = true;
                  });
                },
              )
            else
              _buildCreateCustomFolderForm(locations.first.path),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageLocationOption(
    StorageLocation location,
    DownloadSettings settings,
  ) {
    final isSelected = settings.storageLocation == location.path;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          ref
              .read(downloadSettingsProvider.notifier)
              .updateStorageLocation(location.path);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Icon
              Icon(
                location.isRemovable ? Icons.sd_card : Icons.storage,
                color:
                    isSelected ? Theme.of(context).colorScheme.secondary : null,
              ),
              const SizedBox(width: 16),

              // Location details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.path,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),

                    // Storage space indicator
                    LinearProgressIndicator(
                      value: location.spaceInfo.usagePercentage,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStorageIndicatorColor(
                          location.spaceInfo.usagePercentage,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${location.spaceInfo.formattedFreeSpace} free of ${location.spaceInfo.formattedTotalSpace}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.secondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStorageIndicatorColor(double percentage) {
    if (percentage > 0.9) {
      return Colors.red;
    } else if (percentage > 0.7) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.secondary;
    }
  }

  Widget _buildCreateCustomFolderForm(String basePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Create a new folder in your music directory:'),
        const SizedBox(height: 8),
        TextField(
          controller: _folderNameController,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                setState(() {
                  _isCreatingCustomFolder = false;
                  _folderNameController.clear();
                });
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () => _createCustomFolder(basePath),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _createCustomFolder(String basePath) async {
    final folderName = _folderNameController.text.trim();
    if (folderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a folder name')),
      );
      return;
    }

    try {
      // Create the directory
      final newFolderPath = '$basePath/$folderName';
      final directory = Directory(newFolderPath);

      if (await directory.exists()) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Folder already exists')));
        return;
      }

      await directory.create(recursive: true);

      // Update settings
      ref
          .read(downloadSettingsProvider.notifier)
          .updateStorageLocation(newFolderPath);

      // Reset form
      setState(() {
        _isCreatingCustomFolder = false;
        _folderNameController.clear();
      });

      // Refresh storage locations
      ref.refresh(storageLocationsProvider);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Created folder: $folderName')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating folder: $e')));
    }
  }

  Widget _buildFolderOrganizationSettings(DownloadSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Create artist folders'),
              subtitle: const Text('Organize music by artist'),
              value: settings.createArtistFolders,
              onChanged: (value) {
                ref
                    .read(downloadSettingsProvider.notifier)
                    .updateFolderSettings(createArtistFolders: value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Create album folders'),
              subtitle: const Text(
                'Organize music by album within artist folders',
              ),
              value: settings.createAlbumFolders,
              onChanged:
                  settings.createArtistFolders
                      ? (value) {
                        ref
                            .read(downloadSettingsProvider.notifier)
                            .updateFolderSettings(createAlbumFolders: value);
                      }
                      : null,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Text(
              'Example: ${_getFolderStructureExample(settings)}',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _getFolderStructureExample(DownloadSettings settings) {
    final basePath = settings.storageLocation.split('/').last;

    if (settings.createArtistFolders && settings.createAlbumFolders) {
      return '$basePath/Artist Name/Album Name/Song Title.${settings.fileExtension}';
    } else if (settings.createArtistFolders) {
      return '$basePath/Artist Name/Song Title.${settings.fileExtension}';
    } else {
      return '$basePath/Song Title.${settings.fileExtension}';
    }
  }

  Widget _buildAdditionalSettings(DownloadSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Download album artwork'),
              subtitle: const Text('Save album covers with music'),
              value: settings.downloadArtwork,
              onChanged: (value) {
                ref
                    .read(downloadSettingsProvider.notifier)
                    .updateDownloadArtwork(value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Download on Wi-Fi only'),
              subtitle: const Text('Prevent downloads on mobile data'),
              value: settings.wifiOnly,
              onChanged: (value) {
                ref
                    .read(downloadSettingsProvider.notifier)
                    .updateWifiOnly(value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Auto-download lyrics'),
              subtitle: const Text('Download lyrics with songs when available'),
              value: settings.autoDownloadLyrics,
              onChanged: (value) {
                ref
                    .read(downloadSettingsProvider.notifier)
                    .updateAutoDownloadLyrics(value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              title: const Text('Maximum concurrent downloads'),
              subtitle: const Text(
                'Number of songs to download simultaneously',
              ),
              contentPadding: EdgeInsets.zero,
              trailing: DropdownButton<int>(
                value: settings.maxConcurrentDownloads,
                items:
                    [1, 2, 3, 4, 5].map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(downloadSettingsProvider.notifier)
                        .updateMaxConcurrentDownloads(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text(
              'Are you sure you want to reset all download settings to default values?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Reset'),
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(downloadSettingsProvider.notifier).resetToDefaults();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset to defaults')),
                  );
                },
              ),
            ],
          ),
    );
  }
}
