import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:music/screens/download/download_item.dart';
import 'package:rxdart/subjects.dart';

// Notification types
enum NotificationType {
  downloadProgress,
  downloadComplete,
  downloadError,
  downloadPaused,
  downloadResumed,
  downloadCancelled,
  batchDownloadComplete,
}

// Notification action types
enum NotificationAction { pause, resume, cancel, viewDownloads, openTrack }

// Notification payload
class NotificationPayload {
  final NotificationType type;
  final String? id;
  final String? title;
  final String? message;

  NotificationPayload({required this.type, this.id, this.title, this.message});

  // Convert to JSON string
  String toJson() {
    return '{"type":${type.index},"id":"$id","title":"$title","message":"$message"}';
  }

  // Create from JSON string
  factory NotificationPayload.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return NotificationPayload(
      type: NotificationType.values[map['type'] as int],
      id: map['id'] as String?,
      title: map['title'] as String?,
      message: map['message'] as String?,
    );
  }
}

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Flutter local notifications plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stream controller for notification actions
  final BehaviorSubject<NotificationPayload> _notificationActionSubject =
      BehaviorSubject<NotificationPayload>();

  // Stream for notification actions
  Stream<NotificationPayload> get notificationActions =>
      _notificationActionSubject.stream;

  // Notification IDs
  static const int downloadProgressNotificationId = 1;
  static const int downloadCompleteNotificationId = 2;
  static const int downloadErrorNotificationId = 3;
  static const int batchDownloadCompleteNotificationId = 4;

  // Notification channels
  static const String downloadProgressChannelId = 'download_progress_channel';
  static const String downloadCompleteChannelId = 'download_complete_channel';
  static const String downloadErrorChannelId = 'download_error_channel';

  // Initialize notifications
  Future<void> init() async {
    // Initialize settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    // Request notification permissions for iOS
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Download progress channel
    const AndroidNotificationChannel downloadProgressChannel =
        AndroidNotificationChannel(
          downloadProgressChannelId,
          'Download Progress',
          description: 'Notifications for download progress',
          importance: Importance.low,
          showBadge: false,
        );

    // Download complete channel
    const AndroidNotificationChannel downloadCompleteChannel =
        AndroidNotificationChannel(
          downloadCompleteChannelId,
          'Download Complete',
          description: 'Notifications for completed downloads',
          importance: Importance.high,
        );

    // Download error channel
    const AndroidNotificationChannel downloadErrorChannel =
        AndroidNotificationChannel(
          downloadErrorChannelId,
          'Download Errors',
          description: 'Notifications for download errors',
          importance: Importance.high,
        );

    // Create channels
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          [
                downloadProgressChannel,
                downloadCompleteChannel,
                downloadErrorChannel,
              ]
              as AndroidNotificationChannel,
        );
  }

  // Handle iOS local notifications (for iOS 9 and below)
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    if (payload != null) {
      final notificationPayload = NotificationPayload.fromJson(payload);
      _notificationActionSubject.add(notificationPayload);
    }
  }

  // Handle notification responses
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final notificationPayload = NotificationPayload.fromJson(
        response.payload!,
      );
      _notificationActionSubject.add(notificationPayload);
    }
  }

  // Show download progress notification
  Future<void> showDownloadProgressNotification({
    required List<DownloadItem> activeDownloads,
    required int queuedCount,
  }) async {
    // If no active downloads, cancel the notification
    if (activeDownloads.isEmpty) {
      await _flutterLocalNotificationsPlugin.cancel(
        downloadProgressNotificationId,
      );
      return;
    }

    // Calculate overall progress
    double overallProgress = 0;
    for (final download in activeDownloads) {
      overallProgress += download.progress;
    }
    overallProgress /= activeDownloads.length;

    // Create notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          downloadProgressChannelId,
          'Download Progress',
          channelDescription: 'Notifications for download progress',
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: 100,
          progress: (overallProgress * 100).round(),
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          actions: [
            const AndroidNotificationAction(
              'pause_all',
              'Pause All',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'cancel_all',
              'Cancel All',
              showsUserInterface: true,
            ),
          ],
        );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
      subtitle: 'Tap to view downloads',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Create notification title and body
    final String title =
        activeDownloads.length == 1
            ? 'Downloading ${activeDownloads.first.song.title}'
            : 'Downloading ${activeDownloads.length} tracks';

    final String body =
        activeDownloads.length == 1
            ? '${(activeDownloads.first.progress * 100).round()}% complete'
            : '${(overallProgress * 100).round()}% complete${queuedCount > 0 ? ' • $queuedCount in queue' : ''}';

    // Create notification payload
    final payload =
        NotificationPayload(
          type: NotificationType.downloadProgress,
          title: title,
          message: body,
        ).toJson();

    // Show notification
    await _flutterLocalNotificationsPlugin.show(
      downloadProgressNotificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show download complete notification
  Future<void> showDownloadCompleteNotification({
    required DownloadItem download,
  }) async {
    // Create notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          downloadCompleteChannelId,
          'Download Complete',
          channelDescription: 'Notifications for completed downloads',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.green,
          actions: [
            const AndroidNotificationAction(
              'open_track',
              'Play',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'view_downloads',
              'View Downloads',
              showsUserInterface: true,
            ),
          ],
        );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Tap to play',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Create notification title and body
    final String title = 'Download Complete';
    final String body = '${download.song.title} by ${download.song.artist}';

    // Create notification payload
    final payload =
        NotificationPayload(
          type: NotificationType.downloadComplete,
          id: download.id,
          title: title,
          message: body,
        ).toJson();

    // Show notification
    await _flutterLocalNotificationsPlugin.show(
      downloadCompleteNotificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show batch download complete notification
  Future<void> showBatchDownloadCompleteNotification({
    required int count,
    required String albumName,
  }) async {
    // Create notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          downloadCompleteChannelId,
          'Download Complete',
          channelDescription: 'Notifications for completed downloads',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.green,
          actions: [
            const AndroidNotificationAction(
              'view_downloads',
              'View Downloads',
              showsUserInterface: true,
            ),
          ],
        );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Tap to view downloads',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Create notification title and body
    final String title = 'Batch Download Complete';
    final String body = 'Downloaded $count tracks from $albumName';

    // Create notification payload
    final payload =
        NotificationPayload(
          type: NotificationType.batchDownloadComplete,
          title: title,
          message: body,
        ).toJson();

    // Show notification
    await _flutterLocalNotificationsPlugin.show(
      batchDownloadCompleteNotificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show download error notification
  Future<void> showDownloadErrorNotification({
    required DownloadItem download,
    required String error,
  }) async {
    // Create notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          downloadErrorChannelId,
          'Download Errors',
          channelDescription: 'Notifications for download errors',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.red,
          actions: [
            const AndroidNotificationAction(
              'retry',
              'Retry',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'view_downloads',
              'View Downloads',
              showsUserInterface: true,
            ),
          ],
        );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Tap to retry',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Create notification title and body
    final String title = 'Download Failed';
    final String body = '${download.song.title}: ${_formatErrorMessage(error)}';

    // Create notification payload
    final payload =
        NotificationPayload(
          type: NotificationType.downloadError,
          id: download.id,
          title: title,
          message: body,
        ).toJson();

    // Show notification with a random ID to allow multiple error notifications
    final int notificationId =
        downloadErrorNotificationId + Random().nextInt(1000);

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Format error message
  String _formatErrorMessage(String error) {
    // Shorten and simplify error messages for notifications
    if (error.contains('Connection failed')) {
      return 'Connection failed';
    } else if (error.contains('Permission denied')) {
      return 'Permission denied';
    } else if (error.contains('WiFi only')) {
      return 'WiFi connection required';
    } else if (error.contains('storage')) {
      return 'Storage error';
    } else {
      // Limit length for notification
      return error.length > 50 ? '${error.substring(0, 47)}...' : error;
    }
  }

  // Dispose resources
  void dispose() {
    _notificationActionSubject.close();
  }
}
