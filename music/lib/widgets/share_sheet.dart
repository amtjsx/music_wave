import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music/models/playlist.dart';
import 'package:music/screens/download/download_item.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/song.dart';
import '../services/share_service.dart';

class ShareSheet extends StatefulWidget {
  final ShareContentType contentType;
  final dynamic content; // Song, Album, Playlist, or DownloadItem

  const ShareSheet({
    super.key,
    required this.contentType,
    required this.content,
  });

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  final ShareService _shareService = shareService;
  bool _isGeneratingQR = false;
  Uint8List? _qrCodeData;
  String _qrCodeContent = '';

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  Future<void> _generateQRCode() async {
    setState(() {
      _isGeneratingQR = true;
    });

    try {
      String content;

      switch (widget.contentType) {
        case ShareContentType.song:
          final song = widget.content as Song;
          content = _shareService.createSongShareLink(song);
          break;
        case ShareContentType.album:
          final album = widget.content as Map<String, dynamic>;
          content = _shareService.createAlbumShareLink(album);
          break;
        case ShareContentType.playlist:
          final playlist = widget.content as Map<String, dynamic>;
          content = _shareService.createPlaylistShareLink(playlist);
          break;
        case ShareContentType.downloadedTrack:
          final download = widget.content as DownloadItem;
          content =
              'Downloaded: ${download.song.title} by ${download.song.artist}';
          break;
        case ShareContentType.appInvite:
          content =
              Platform.isIOS
                  ? 'https://apps.apple.com/app/your-app-id'
                  : 'https://play.google.com/store/apps/details?id=your.app.package';
          break;
      }

      _qrCodeContent = content;
      // In a real app, you would generate a real QR code
      // For this example, we'll use the qr_flutter package
      // _qrCodeData = await _shareService.generateQRCode(content);

      setState(() {
        _isGeneratingQR = false;
      });
    } catch (e) {
      print('Error generating QR code: $e');
      setState(() {
        _isGeneratingQR = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Text('Share', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content preview
          _buildContentPreview(),
          const SizedBox(height: 24),

          // Share options
          _buildShareOptions(),
          const SizedBox(height: 24),

          // QR code
          _buildQRCode(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContentPreview() {
    switch (widget.contentType) {
      case ShareContentType.song:
        final song = widget.content as Song;
        return _buildSongPreview(song);
      case ShareContentType.album:
        final album = widget.content as Map<String, dynamic>;
        return _buildAlbumPreview(album);
      case ShareContentType.playlist:
        final playlist = widget.content as Playlist;
        return _buildPlaylistPreview(playlist);
      case ShareContentType.downloadedTrack:
        final download = widget.content as DownloadItem;
        return _buildDownloadPreview(download);
      case ShareContentType.appInvite:
        return _buildAppInvitePreview();
    }
  }

  Widget _buildSongPreview(Song song) {
    return Row(
      children: [
        // Album art
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            song.albumArt,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Song details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                song.artist,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                song.duration,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumPreview(Map<String, dynamic> album) {
    final trackCount =
        album['tracks'] != null ? (album['tracks'] as List).length : 0;

    return Row(
      children: [
        // Album art
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            album['artwork'] ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[800],
                child: const Icon(Icons.album, color: Colors.white),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Album details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                album['title'] ?? 'Unknown Album',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                album['artist'] ?? 'Unknown Artist',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$trackCount tracks',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistPreview(Playlist playlist) {
    final trackCount = playlist.songs.length;

    return Row(
      children: [
        // Playlist art
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            playlist.coverUrl ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[800],
                child: const Icon(Icons.queue_music, color: Colors.white),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Playlist details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlist.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Created by ${playlist.creatorName ?? 'you'}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$trackCount tracks',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadPreview(DownloadItem download) {
    return Row(
      children: [
        // Album art
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            download.song.albumArt,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Song details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                download.song.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                download.song.artist,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Downloaded • ${download.song.duration}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppInvitePreview() {
    return Row(
      children: [
        // App icon
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: Colors.blue[700],
            child: const Icon(Icons.music_note, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(width: 16),

        // App details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Music App',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Invite friends to join',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Share the app with your friends',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShareOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share via',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        // Share options grid
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            // Social media options
            _buildShareOption(
              icon: Icons.message,
              label: 'Messages',
              onTap: _shareViaMessages,
            ),
            _buildShareOption(
              icon: Icons.email,
              label: 'Email',
              onTap: _shareViaEmail,
            ),
            _buildShareOption(
              icon: Icons.copy,
              label: 'Copy Link',
              onTap: _copyLink,
            ),
            _buildShareOption(
              icon: Icons.more_horiz,
              label: 'More',
              onTap: _shareViaSystem,
            ),

            // For downloaded tracks, add export option
            if (widget.contentType == ShareContentType.downloadedTrack)
              _buildShareOption(
                icon: Icons.save_alt,
                label: 'Export',
                onTap: _exportFile,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[300]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    return Column(
      children: [
        const Text(
          'QR Code',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),

        // QR code
        if (_isGeneratingQR)
          const CircularProgressIndicator()
        else
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: _qrCodeContent,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),

        const SizedBox(height: 16),
        Text(
          'Scan to share',
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
      ],
    );
  }

  void _shareViaMessages() {
    // Close the bottom sheet
    Navigator.of(context).pop();

    // Share via messages (this would typically use platform-specific code)
    // For this example, we'll just use the general share method
    _shareContent();
  }

  void _shareViaEmail() {
    // Close the bottom sheet
    Navigator.of(context).pop();

    // Share via email (this would typically use platform-specific code)
    // For this example, we'll just use the general share method
    _shareContent();
  }

  void _copyLink() {
    // Close the bottom sheet
    Navigator.of(context).pop();

    // Copy link to clipboard
    String link;

    switch (widget.contentType) {
      case ShareContentType.song:
        final song = widget.content as Song;
        link = _shareService.createSongShareLink(song);
        break;
      case ShareContentType.album:
        final album = widget.content as Map<String, dynamic>;
        link = _shareService.createAlbumShareLink(album);
        break;
      case ShareContentType.playlist:
        final playlist = widget.content as Map<String, dynamic>;
        link = _shareService.createPlaylistShareLink(playlist);
        break;
      case ShareContentType.downloadedTrack:
        final download = widget.content as DownloadItem;
        link = 'Downloaded: ${download.song.title} by ${download.song.artist}';
        break;
      case ShareContentType.appInvite:
        link =
            Platform.isIOS
                ? 'https://apps.apple.com/app/your-app-id'
                : 'https://play.google.com/store/apps/details?id=your.app.package';
        break;
    }

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: link));

    // Show snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
  }

  void _shareViaSystem() {
    // Close the bottom sheet
    Navigator.of(context).pop();

    // Share via system share sheet
    _shareContent();
  }

  void _exportFile() {
    // Close the bottom sheet
    Navigator.of(context).pop();

    // Export file
    if (widget.contentType == ShareContentType.downloadedTrack) {
      final download = widget.content as DownloadItem;
      _shareService.exportDownloadedTrack(download).catchError((error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting file: $error')));
      });
    }
  }

  void _shareContent() {
    try {
      switch (widget.contentType) {
        case ShareContentType.song:
          final song = widget.content as Song;
          _shareService.shareSong(song, context: context);
          break;
        case ShareContentType.album:
          final album = widget.content as Map<String, dynamic>;
          _shareService.shareAlbum(album, context: context);
          break;
        case ShareContentType.playlist:
          final playlist = widget.content as Map<String, dynamic>;
          _shareService.sharePlaylist(playlist, context: context);
          break;
        case ShareContentType.downloadedTrack:
          final download = widget.content as DownloadItem;
          _shareService.shareDownloadedTrack(download, context: context);
          break;
        case ShareContentType.appInvite:
          _shareService.shareAppInvite(context: context);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }
}
