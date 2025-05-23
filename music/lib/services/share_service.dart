import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:music/screens/download/download_item.dart';
import 'package:music/screens/download/setting_provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/song.dart';

// Share content types
enum ShareContentType { song, album, playlist, downloadedTrack, appInvite }

final shareService = ShareService();

class ShareService {
  // Singleton instance
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  // Base URL for deep links
  final String _baseDeepLinkUrl = 'https://musicapp.example.com';

  // Share a song
  Future<void> shareSong(Song song, {BuildContext? context}) async {
    try {
      // Create share text
      final String shareText = createSongShareText(song);

      // Create share link
      final String shareLink = createSongShareLink(song);

      // Share with platform share sheet
      await _shareContent(
        shareText: shareText,
        shareLink: shareLink,
        subject: 'Check out this song!',
        context: context,
      );
    } catch (e) {
      print('Error sharing song: $e');
      rethrow;
    }
  }

  // Share an album
  Future<void> shareAlbum(
    Map<String, dynamic> album, {
    BuildContext? context,
  }) async {
    try {
      // Create share text
      final String shareText = createAlbumShareText(album);

      // Create share link
      final String shareLink = createAlbumShareLink(album);

      // Download album artwork for sharing
      String? imagePath;
      if (album['artwork'] != null) {
        imagePath = await _downloadImageForSharing(album['artwork']);
      }

      // Share with platform share sheet
      await _shareContent(
        shareText: shareText,
        shareLink: shareLink,
        subject: 'Check out this album!',
        imagePath: imagePath,
        context: context,
      );
    } catch (e) {
      print('Error sharing album: $e');
      rethrow;
    }
  }

  // Share a playlist
  Future<void> sharePlaylist(
    Map<String, dynamic> playlist, {
    BuildContext? context,
  }) async {
    try {
      // Create share text
      final String shareText = createPlaylistShareText(playlist);

      // Create share link
      final String shareLink = createPlaylistShareLink(playlist);

      // Download playlist artwork for sharing
      String? imagePath;
      if (playlist['artwork'] != null) {
        imagePath = await _downloadImageForSharing(playlist['artwork']);
      }

      // Share with platform share sheet
      await _shareContent(
        shareText: shareText,
        shareLink: shareLink,
        subject: 'Check out this playlist!',
        imagePath: imagePath,
        context: context,
      );
    } catch (e) {
      print('Error sharing playlist: $e');
      rethrow;
    }
  }

  // Share a downloaded track
  Future<void> shareDownloadedTrack(
    DownloadItem download, {
    BuildContext? context,
  }) async {
    try {
      // Get file path
      final filePath = await _getDownloadedFilePath(download);
      if (filePath == null) {
        throw Exception('File not found');
      }

      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      // Create share text
      final String shareText = _createDownloadShareText(download);

      // Share file with platform share sheet
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: shareText,
        subject: 'Sharing ${download.song.title}',
      );

      print('Share result: ${result.status}');
    } catch (e) {
      print('Error sharing downloaded track: $e');
      rethrow;
    }
  }

  // Share app invite
  Future<void> shareAppInvite({BuildContext? context}) async {
    try {
      // Create share text
      final String shareText =
          'Check out this awesome music app! '
          'Download it now and enjoy millions of songs, create playlists, '
          'and download your favorite tracks for offline listening.';

      // Create share link (app store or play store link)
      final String shareLink =
          Platform.isIOS
              ? 'https://apps.apple.com/app/your-app-id'
              : 'https://play.google.com/store/apps/details?id=your.app.package';

      // Share with platform share sheet
      await _shareContent(
        shareText: shareText,
        shareLink: shareLink,
        subject: 'Check out this music app!',
        context: context,
      );
    } catch (e) {
      print('Error sharing app invite: $e');
      rethrow;
    }
  }

  // Export downloaded track to device
  Future<void> exportDownloadedTrack(DownloadItem download) async {
    try {
      // Get file path
      final filePath = await _getDownloadedFilePath(download);
      if (filePath == null) {
        throw Exception('File not found');
      }

      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      // Get file extension
      final extension = path.extension(filePath).toLowerCase();

      // Determine MIME type
      String mimeType;
      if (extension == '.mp3') {
        mimeType = 'audio/mpeg';
      } else if (extension == '.flac') {
        mimeType = 'audio/flac';
      } else {
        mimeType = 'audio/mpeg'; // Default
      }

      // Create file name
      final fileName =
          '${download.song.artist} - ${download.song.title}$extension';

      if (Platform.isAndroid) {
        // Use Flutter File Dialog for Android
        final params = SaveFileDialogParams(
          sourceFilePath: filePath,
          fileName: fileName,
          mimeTypesFilter: [mimeType],
        );

        final savedFilePath = await FlutterFileDialog.saveFile(params: params);
        if (savedFilePath != null) {
          print('File saved to: $savedFilePath');
          return;
        }
      } else if (Platform.isIOS) {
        // For iOS, use Share.shareFiles which will show the iOS share sheet
        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Save ${download.song.title}');
        return;
      }

      throw Exception('Export not supported on this platform');
    } catch (e) {
      print('Error exporting downloaded track: $e');
      rethrow;
    }
  }

  // Generate QR code for sharing
  Future<Uint8List> generateQRCode(
    String content, {
    double size = 200.0,
  }) async {
    try {
      // This would be implemented using a QR code generation library
      // For this example, we'll just return a placeholder
      return Uint8List.fromList([0, 1, 2, 3]); // Placeholder
    } catch (e) {
      print('Error generating QR code: $e');
      rethrow;
    }
  }

  // Share content with platform share sheet
  Future<void> _shareContent({
    required String shareText,
    String? shareLink,
    String? subject,
    String? imagePath,
    BuildContext? context,
  }) async {
    try {
      // Combine text and link
      final String fullText =
          shareLink != null ? '$shareText\n\n$shareLink' : shareText;

      if (imagePath != null) {
        // Share with image
        final result = await Share.shareXFiles(
          [XFile(imagePath)],
          text: fullText,
          subject: subject,
        );
        print('Share result: ${result.status}');
      } else {
        // Share text only
        final result = await Share.share(fullText, subject: subject);
      }
    } catch (e) {
      print('Error in _shareContent: $e');
      rethrow;
    }
  }

  // Create song share text
  String createSongShareText(Song song) {
    return 'Check out "${song.title}" by ${song.artist}! 🎵';
  }

  // Create album share text
  String createAlbumShareText(Map<String, dynamic> album) {
    final trackCount =
        album['tracks'] != null ? (album['tracks'] as List).length : 0;
    return 'Check out "${album['title']}" by ${album['artist']}! '
        'An album with $trackCount tracks. 🎵';
  }

  // Create playlist share text
  String createPlaylistShareText(Map<String, dynamic> playlist) {
    final trackCount =
        playlist['tracks'] != null ? (playlist['tracks'] as List).length : 0;
    return 'Check out my playlist "${playlist['title']}"! '
        'A collection of $trackCount amazing tracks. 🎵';
  }

  // Create download share text
  String _createDownloadShareText(DownloadItem download) {
    return 'Sharing "${download.song.title}" by ${download.song.artist} with you! 🎵';
  }

  // Create song share link
  String createSongShareLink(Song song) {
    return '$_baseDeepLinkUrl/song/${song.id}';
  }

  // Create album share link
  String createAlbumShareLink(Map<String, dynamic> album) {
    return '$_baseDeepLinkUrl/album/${album['id']}';
  }

  // Create playlist share link
  String createPlaylistShareLink(Map<String, dynamic> playlist) {
    return '$_baseDeepLinkUrl/playlist/${playlist['id']}';
  }

  // Download image for sharing
  Future<String?> _downloadImageForSharing(String imageUrl) async {
    try {
      // Download image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return null;
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'share_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(tempDir.path, fileName);

      // Save image to file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      print('Error downloading image for sharing: $e');
      return null;
    }
  }

  // Get downloaded file path
  Future<String?> _getDownloadedFilePath(DownloadItem download) async {
    try {
      // Get settings to determine file path
      final settingsProvider = ProviderContainer().read(
        downloadSettingsProvider,
      );

      // Determine file path based on folder organization settings
      String filePath;
      final baseDir = Directory(settingsProvider.storageLocation);

      if (settingsProvider.createArtistFolders) {
        final artistDir = Directory('${baseDir.path}/${download.song.artist}');

        if (settingsProvider.createAlbumFolders) {
          final albumDir = Directory('${artistDir.path}/${download.albumName}');
          filePath =
              '${albumDir.path}/${download.song.title}.${settingsProvider.fileExtension}';
        } else {
          filePath =
              '${artistDir.path}/${download.song.title}.${settingsProvider.fileExtension}';
        }
      } else {
        filePath =
            '${baseDir.path}/${download.song.title}.${settingsProvider.fileExtension}';
      }

      // Check if file exists
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      // If file doesn't exist, try alternative extensions
      final alternativeExtensions = ['mp3', 'flac'];
      for (final ext in alternativeExtensions) {
        final altFilePath = filePath.replaceAll(RegExp(r'\.[^.]+$'), '.$ext');
        final altFile = File(altFilePath);
        if (await altFile.exists()) {
          return altFilePath;
        }
      }

      return null;
    } catch (e) {
      print('Error getting downloaded file path: $e');
      return null;
    }
  }

  // Open URL
  Future<bool> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri);
    } catch (e) {
      print('Error opening URL: $e');
      return false;
    }
  }
}
