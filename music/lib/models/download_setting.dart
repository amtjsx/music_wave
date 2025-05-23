enum DownloadQuality {
  low, // 128 kbps
  medium, // 256 kbps
  high, // 320 kbps
  lossless, // FLAC
}

class DownloadSettings {
  final DownloadQuality quality;
  final String storageLocation;
  final bool createArtistFolders;
  final bool createAlbumFolders;
  final bool downloadArtwork;
  final bool wifiOnly;
  final int maxConcurrentDownloads;
  final bool autoDownloadLyrics;

  const DownloadSettings({
    required this.quality,
    required this.storageLocation,
    required this.createArtistFolders,
    required this.createAlbumFolders,
    required this.downloadArtwork,
    required this.wifiOnly,
    required this.maxConcurrentDownloads,
    required this.autoDownloadLyrics,
  });

  // Default settings
  DownloadSettings.defaultSettings()
    : quality = DownloadQuality.high,
      storageLocation = '', // Will be set on init
      createArtistFolders = true,
      createAlbumFolders = true,
      downloadArtwork = true,
      wifiOnly = true,
      maxConcurrentDownloads = 3,
      autoDownloadLyrics = false;

  // Copy with method for immutability
  DownloadSettings copyWith({
    DownloadQuality? quality,
    String? storageLocation,
    bool? createArtistFolders,
    bool? createAlbumFolders,
    bool? downloadArtwork,
    bool? wifiOnly,
    int? maxConcurrentDownloads,
    bool? autoDownloadLyrics,
  }) {
    return DownloadSettings(
      quality: quality ?? this.quality,
      storageLocation: storageLocation ?? this.storageLocation,
      createArtistFolders: createArtistFolders ?? this.createArtistFolders,
      createAlbumFolders: createAlbumFolders ?? this.createAlbumFolders,
      downloadArtwork: downloadArtwork ?? this.downloadArtwork,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      maxConcurrentDownloads:
          maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      autoDownloadLyrics: autoDownloadLyrics ?? this.autoDownloadLyrics,
    );
  }

  // Get file size estimate based on quality (in MB per minute)
  double getFileSizeEstimate(double durationMinutes) {
    switch (quality) {
      case DownloadQuality.low:
        return 1.0 * durationMinutes; // ~1 MB per minute at 128 kbps
      case DownloadQuality.medium:
        return 2.0 * durationMinutes; // ~2 MB per minute at 256 kbps
      case DownloadQuality.high:
        return 2.5 * durationMinutes; // ~2.5 MB per minute at 320 kbps
      case DownloadQuality.lossless:
        return 5.0 * durationMinutes; // ~5 MB per minute for FLAC
    }
  }

  // Get quality string
  String get qualityString {
    switch (quality) {
      case DownloadQuality.low:
        return 'Low (128 kbps)';
      case DownloadQuality.medium:
        return 'Medium (256 kbps)';
      case DownloadQuality.high:
        return 'High (320 kbps)';
      case DownloadQuality.lossless:
        return 'Lossless (FLAC)';
    }
  }

  // Get file extension based on quality
  String get fileExtension {
    return quality == DownloadQuality.lossless ? 'flac' : 'mp3';
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'quality': quality.index,
      'storageLocation': storageLocation,
      'createArtistFolders': createArtistFolders,
      'createAlbumFolders': createAlbumFolders,
      'downloadArtwork': downloadArtwork,
      'wifiOnly': wifiOnly,
      'maxConcurrentDownloads': maxConcurrentDownloads,
      'autoDownloadLyrics': autoDownloadLyrics,
    };
  }

  // Create from Map
  factory DownloadSettings.fromMap(Map<String, dynamic> map) {
    return DownloadSettings(
      quality: DownloadQuality.values[map['quality'] ?? 2],
      storageLocation: map['storageLocation'] ?? '',
      createArtistFolders: map['createArtistFolders'] ?? true,
      createAlbumFolders: map['createAlbumFolders'] ?? true,
      downloadArtwork: map['downloadArtwork'] ?? true,
      wifiOnly: map['wifiOnly'] ?? true,
      maxConcurrentDownloads: map['maxConcurrentDownloads'] ?? 3,
      autoDownloadLyrics: map['autoDownloadLyrics'] ?? false,
    );
  }
}
