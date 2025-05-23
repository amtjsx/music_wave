import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/screens/download/download_setting_screen.dart';

import '../services/share_service.dart';
import '../widgets/share_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Download settings
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download Settings'),
            subtitle: const Text('Quality, storage location, and more'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DownloadSettingsScreen(),
                ),
              );
            },
          ),

          // Playback settings
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('Playback Settings'),
            subtitle: const Text('Equalizer, crossfade, and more'),
            onTap: () {
              // Navigate to playback settings
            },
          ),

          // Notification settings
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            subtitle: const Text('Control app notifications'),
            onTap: () {
              // Navigate to notification settings
            },
          ),

          const Divider(),

          // Share app
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            subtitle: const Text('Invite friends to join'),
            onTap: () => _showShareAppSheet(context),
          ),

          // Rate app
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate App'),
            subtitle: const Text('Rate us on the app store'),
            onTap: () {
              // Open app store page
              ShareService().openUrl(
                Platform.isIOS
                    ? 'https://apps.apple.com/app/your-app-id'
                    : 'https://play.google.com/store/apps/details?id=your.app.package',
              );
            },
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version, licenses, and more'),
            onTap: () {
              // Navigate to about screen
            },
          ),
        ],
      ),
    );
  }

  void _showShareAppSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => const ShareSheet(
            contentType: ShareContentType.appInvite,
            content: null,
          ),
    );
  }
}
