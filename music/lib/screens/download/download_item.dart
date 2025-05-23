import 'dart:async';

import 'package:music/models/song.dart';

enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
  error,
}

class DownloadItem {
  final String id;
  final Song song;
  final String albumName;
  final DownloadStatus status;
  final double progress;
  final String? error;
  final DateTime addedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Completer<void> pauseCompleter;

  DownloadItem({
    required this.id,
    required this.song,
    required this.albumName,
    required this.status,
    required this.progress,
    required this.addedAt,
    this.error,
    this.startedAt,
    this.completedAt,
    Completer<void>? pauseCompleter,
  }) : pauseCompleter = pauseCompleter ?? Completer<void>();

  // Copy with method for immutability
  DownloadItem copyWith({
    String? id,
    Song? song,
    String? albumName,
    DownloadStatus? status,
    double? progress,
    String? error,
    DateTime? addedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    Completer<void>? pauseCompleter,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      song: song ?? this.song,
      albumName: albumName ?? this.albumName,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      addedAt: addedAt ?? this.addedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      pauseCompleter: pauseCompleter ?? this.pauseCompleter,
    );
  }

  // Get estimated time remaining based on progress and elapsed time
  Duration? get estimatedTimeRemaining {
    if (status != DownloadStatus.downloading ||
        startedAt == null ||
        progress <= 0) {
      return null;
    }

    final elapsedTime = DateTime.now().difference(startedAt!);
    final estimatedTotalTime = elapsedTime.inMilliseconds / progress;
    final remainingTime = estimatedTotalTime - elapsedTime.inMilliseconds;

    return Duration(milliseconds: remainingTime.round());
  }

  // Get download speed in KB/s
  double? get downloadSpeed {
    if (status != DownloadStatus.downloading ||
        startedAt == null ||
        progress <= 0) {
      return null;
    }

    // Assume average song size is 5MB
    const averageSongSize = 5 * 1024; // KB
    final elapsedTime = DateTime.now().difference(startedAt!);
    final downloadedSize = averageSongSize * progress;

    return downloadedSize / (elapsedTime.inMilliseconds / 1000);
  }

  // Format download speed as string
  String? get formattedDownloadSpeed {
    final speed = downloadSpeed;
    if (speed == null) {
      return null;
    }

    if (speed >= 1024) {
      return '${(speed / 1024).toStringAsFixed(1)} MB/s';
    } else {
      return '${speed.toStringAsFixed(1)} KB/s';
    }
  }

  // Format estimated time remaining as string
  String? get formattedTimeRemaining {
    final remaining = estimatedTimeRemaining;
    if (remaining == null) {
      return null;
    }

    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m remaining';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m ${remaining.inSeconds.remainder(60)}s remaining';
    } else {
      return '${remaining.inSeconds}s remaining';
    }
  }
}
