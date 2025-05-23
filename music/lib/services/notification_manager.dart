import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/screens/download/download_item.dart';
import 'package:music/screens/download/download_queue_state.dart';

import '../services/notification_service.dart';

// Provider for notification manager
final notificationManagerProvider = Provider<NotificationManager>((ref) {
  return NotificationManager(ref);
});

class NotificationManager {
  final ProviderRef _ref;
  final NotificationService _notificationService = NotificationService();

  // Subscription for download events
  StreamSubscription? _downloadProgressSubscription;
  StreamSubscription? _downloadCompletedSubscription;
  StreamSubscription? _downloadFailedSubscription;

  // Batch download tracking
  final Map<String, List<String>> _batchDownloads = {};

  // Timer for throttling progress notifications
  Timer? _progressNotificationTimer;

  NotificationManager(this._ref) {
    _initialize();
  }

  // Initialize notification manager
  Future<void> _initialize() async {
    // Initialize notification service
    await _notificationService.init();

    // Listen for notification actions
    _notificationService.notificationActions.listen(_handleNotificationAction);

    // Subscribe to download events
    _subscribeToDownloadEvents();
  }

  // Subscribe to download events
  void _subscribeToDownloadEvents() {
    // Progress updates
    _downloadProgressSubscription = onDownloadProgress.listen((item) {
      _throttleProgressNotification();
    });

    // Completed downloads
    _downloadCompletedSubscription = onDownloadCompleted.listen((item) {
      _handleDownloadCompleted(item);
    });

    // Failed downloads
    _downloadFailedSubscription = onDownloadFailed.listen((item) {
      if (item.error != null) {
        _notificationService.showDownloadErrorNotification(
          download: item,
          error: item.error!,
        );
      }
    });
  }

  // Throttle progress notifications to avoid too many updates
  void _throttleProgressNotification() {
    if (_progressNotificationTimer?.isActive != true) {
      _progressNotificationTimer = Timer(const Duration(milliseconds: 500), () {
        _updateProgressNotification();
      });
    }
  }

  // Update progress notification
  void _updateProgressNotification() {
    final queueState = _ref.read(downloadQueueProvider);
    final activeDownloads = queueState.activeDownloadsList;
    final queuedCount = queueState.queuedDownloads.length;

    if (activeDownloads.isNotEmpty) {
      _notificationService.showDownloadProgressNotification(
        activeDownloads: activeDownloads,
        queuedCount: queuedCount,
      );
    } else {
      _notificationService.cancelNotification(
        NotificationService.downloadProgressNotificationId,
      );
    }
  }

  // Handle download completed
  void _handleDownloadCompleted(DownloadItem item) {
    // Check if this is part of a batch download
    final albumName = item.albumName;
    if (_batchDownloads.containsKey(albumName)) {
      // Add to batch
      _batchDownloads[albumName]!.add(item.id);

      // Check if all downloads in the batch are complete
      final queueState = _ref.read(downloadQueueProvider);
      final allDownloads = queueState.allDownloadsList;

      // Count remaining downloads for this album
      final remainingForAlbum =
          allDownloads
              .where(
                (download) =>
                    download.albumName == albumName &&
                    download.status != DownloadStatus.completed &&
                    download.status != DownloadStatus.failed &&
                    download.status != DownloadStatus.cancelled,
              )
              .length;

      if (remainingForAlbum == 0) {
        // All downloads in the batch are complete
        _notificationService.showBatchDownloadCompleteNotification(
          count: _batchDownloads[albumName]!.length,
          albumName: albumName,
        );

        // Clear batch
        _batchDownloads.remove(albumName);
      }
    } else {
      // Single download completed
      _notificationService.showDownloadCompleteNotification(download: item);
    }

    // Update progress notification
    _updateProgressNotification();
  }

  // Register a batch download
  void registerBatchDownload(String albumName, List<String> trackIds) {
    _batchDownloads[albumName] = [];
  }

  // Handle notification actions
  void _handleNotificationAction(NotificationPayload payload) {
    final queueNotifier = _ref.read(downloadQueueProvider.notifier);

    switch (payload.type) {
      case NotificationType.downloadProgress:
        // Handle progress notification actions
        if (payload.message == 'pause_all') {
          // Pause all active downloads
          final queueState = _ref.read(downloadQueueProvider);
          for (final download in queueState.activeDownloadsList) {
            queueNotifier.pauseDownload(download.id);
          }
        } else if (payload.message == 'cancel_all') {
          // Cancel all downloads
          queueNotifier.cancelAllDownloads();
        }
        break;

      case NotificationType.downloadComplete:
        // Handle complete notification actions
        if (payload.message == 'open_track' && payload.id != null) {
          // Open the track (would be implemented in the app)
          print('Open track: ${payload.id}');
        }
        break;

      case NotificationType.downloadError:
        // Handle error notification actions
        if (payload.message == 'retry' && payload.id != null) {
          // Retry the download
          queueNotifier.resumeDownload(payload.id!);
        }
        break;

      default:
        // Default action is to open the downloads screen
        // This would be handled in the app's navigation
        break;
    }
  }

  // Dispose resources
  void dispose() {
    _progressNotificationTimer?.cancel();
    _downloadProgressSubscription?.cancel();
    _downloadCompletedSubscription?.cancel();
    _downloadFailedSubscription?.cancel();
  }
}
