import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  bool _autoPlay = false;
  bool _crossfadeEnabled = false;
  bool _highQualityStreaming = true;
  bool _downloadOnWiFiOnly = true;
  bool _showExplicitContent = false;
  bool _privateSession = false;
  String _audioQuality = '320';
  String _streamingQuality = 'High';
  String _downloadQuality = 'Very High';
  bool _notificationsEnabled = true;

  void _showAudioQualityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text(
                'Audio Quality',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose your preferred audio quality for streaming and downloads.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  _buildQualityOption('Low (96 kbps)', '96', setDialogState),
                  _buildQualityOption(
                    'Normal (160 kbps)',
                    '160',
                    setDialogState,
                  ),
                  _buildQualityOption('High (320 kbps)', '320', setDialogState),
                  _buildQualityOption(
                    'Very High (FLAC)',
                    'FLAC',
                    setDialogState,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      // Update the main state
                      if (_audioQuality == '96')
                        _streamingQuality = 'Low';
                      else if (_audioQuality == '160')
                        _streamingQuality = 'Normal';
                      else if (_audioQuality == '320')
                        _streamingQuality = 'High';
                      else if (_audioQuality == 'FLAC')
                        _streamingQuality = 'Very High';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Color(0xFF6366F1)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildQualityOption(
    String title,
    String value,
    StateSetter setDialogState,
  ) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: _audioQuality,
      onChanged: (String? value) {
        setDialogState(() {
          if (value != null) {
            _audioQuality = value;
          }
        });
      },
      activeColor: const Color(0xFF6366F1),
    );
  }

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            elevation: 0,
            pinned: true,
            title: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  // context.push('/notifications');
                },
              ),
            ],
          ),

          // All content in a single SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                GestureDetector(
                  onTap: () {
                    context.push('/profile');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Wave overlay
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _waveAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: CompactWavePainter(
                                  _waveAnimation.value,
                                ),
                              );
                            },
                          ),
                        ),
                        // Profile content
                        Row(
                          children: [
                            // Profile picture
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://randomuser.me/api/portraits/men/32.jpg',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // User info
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alex Johnson',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'View Profile',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Arrow icon
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Stats
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat('Playlists', '23'),
                      _buildQuickStat('Following', '156'),
                      _buildQuickStat('Followers', '1.2K'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Your Music'),
                _buildMenuItem(
                  'Your Musics',
                  Icons.music_note,
                  const Color(0xFF6366F1),
                  () {
                    // context.push('/device-songs');
                  },
                ),
                _buildMenuItem(
                  'Your Library',
                  Icons.library_music,
                  const Color(0xFF6366F1),
                  () {
                    // context.push('/library');
                  },
                ),
                _buildMenuItem(
                  'Liked Songs',
                  Icons.favorite,
                  const Color(0xFFE91E63),
                  () {
                    // context.push('/liked-songs');
                  },
                ),
                _buildMenuItem(
                  'Recently Played',
                  Icons.history,
                  const Color(0xFF1DB954),
                  () {
                    // context.push('/recent-played');
                  },
                ),
                _buildMenuItem(
                  'Downloaded Music',
                  Icons.download,
                  const Color(0xFF4ECDC4),
                  () {
                    // context.push('/downloads');
                  },
                ),
                _buildMenuItem(
                  'Your Playlists',
                  Icons.queue_music,
                  const Color(0xFFFECA57),
                  () {
                    // context.push('/playlists');
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Discover'),
                _buildMenuItem(
                  'Browse Genres',
                  Icons.explore,
                  const Color(0xFFFF6B6B),
                  () {
                    // context.push('/browse-genre');
                  },
                ),
                _buildMenuItem(
                  'Top Charts',
                  Icons.trending_up,
                  const Color(0xFF45B7D1),
                  () {
                    // context.push('/charts');
                  },
                ),
                _buildMenuItem(
                  'New Releases',
                  Icons.new_releases,
                  const Color(0xFF96CEB4),
                  () {
                    // context.push('/new-releases');
                  },
                ),
                _buildMenuItem(
                  'Live Events',
                  Icons.event,
                  const Color(0xFFFF5252),
                  () {
                    // context.push('/live-events');
                  },
                ),
                _buildMenuItem(
                  'Podcasts',
                  Icons.mic,
                  const Color(0xFF8B5CF6),
                  () {
                    // context.push('/podcasts');
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Social'),
                _buildMenuItem(
                  'Friends Activity',
                  Icons.people,
                  const Color(0xFF8B5CF6),
                  () {
                    // context.push('/friends');
                  },
                ),
                _buildMenuItem(
                  'Following',
                  Icons.person_add,
                  const Color(0xFFEC4899),
                  () {
                    // context.push('/following');
                  },
                ),
                _buildMenuItem(
                  'Shared with You',
                  Icons.share,
                  const Color(0xFF6366F1),
                  () {
                    // context.push('/shared');
                  },
                ),

                // Account Settings
                const SizedBox(height: 24),
                _buildSectionHeader('Account Settings'),
                _buildSettingsGroup([
                  _buildSettingsTile(
                    'Edit Profile',
                    'Update your profile information',
                    Icons.person_outline,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Privacy Settings',
                    'Manage your privacy preferences',
                    Icons.privacy_tip_outlined,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Subscription',
                    'Manage your premium subscription',
                    Icons.star_outline,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {},
                  ),
                ]),

                // Playback Settings
                const SizedBox(height: 24),
                _buildSectionHeader('Playback Settings'),
                _buildSettingsGroup([
                  _buildSwitchTile(
                    'Autoplay',
                    'Automatically play similar songs',
                    Icons.play_circle_outline,
                    _autoPlay,
                    (value) => setState(() => _autoPlay = value),
                  ),
                  _buildSwitchTile(
                    'Crossfade',
                    'Smooth transitions between songs',
                    Icons.shuffle,
                    _crossfadeEnabled,
                    (value) => setState(() => _crossfadeEnabled = value),
                  ),
                  _buildSettingsTile(
                    'Audio Quality',
                    'Streaming: $_streamingQuality • Download: $_downloadQuality',
                    Icons.high_quality,
                    onTap: () => _showAudioQualityDialog(),
                  ),
                  _buildSwitchTile(
                    'High Quality Streaming',
                    'Use more data for better sound',
                    Icons.hd,
                    _highQualityStreaming,
                    (value) => setState(() => _highQualityStreaming = value),
                  ),
                ]),

                // Download Settings
                const SizedBox(height: 24),
                _buildSectionHeader('Download Settings'),
                _buildSettingsGroup([
                  _buildSwitchTile(
                    'Download on WiFi only',
                    'Save mobile data usage',
                    Icons.wifi,
                    _downloadOnWiFiOnly,
                    (value) => setState(() => _downloadOnWiFiOnly = value),
                  ),
                  _buildSettingsTile(
                    'Downloaded Music',
                    'Manage your offline music',
                    Icons.download,
                    trailing: const Text(
                      '2.3 GB',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Storage Location',
                    'Choose where to save downloads',
                    Icons.folder_outlined,
                    onTap: () {},
                  ),
                ]),

                // Notifications & Privacy
                const SizedBox(height: 24),
                _buildSectionHeader('Notifications & Privacy'),
                _buildSettingsGroup([
                  _buildSwitchTile(
                    'Push Notifications',
                    'Get notified about new releases',
                    Icons.notifications_outlined,
                    _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Private Session',
                    "Don't save listening activity",
                    Icons.visibility_off_outlined,
                    _privateSession,
                    (value) => setState(() => _privateSession = value),
                  ),
                  _buildSwitchTile(
                    'Show Explicit Content',
                    'Allow explicit songs and podcasts',
                    Icons.explicit,
                    _showExplicitContent,
                    (value) => setState(() => _showExplicitContent = value),
                  ),
                ]),

                // Support & About
                const SizedBox(height: 24),
                _buildSectionHeader('Support & About'),
                _buildSettingsGroup([
                  _buildSettingsTile(
                    'Help Center',
                    'Get help and support',
                    Icons.help_outline,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Terms of Service',
                    'Read our terms and conditions',
                    Icons.description_outlined,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'Privacy Policy',
                    'Learn about our privacy practices',
                    Icons.policy_outlined,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    'About',
                    'Version 2.1.0',
                    Icons.info_outline,
                    onTap: () {},
                  ),
                ]),

                // Sign Out Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle sign out
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.red, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class CompactWavePainter extends CustomPainter {
  final double animationValue;

  CompactWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    const waveHeight = 10.0;
    final waveLength = size.width / 2;

    for (int i = 0; i < 2; i++) {
      path.reset();
      final yOffset = size.height * 0.3 + (i * 20);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            yOffset +
            waveHeight *
                math.sin(
                  (x / waveLength * 2 * math.pi) + animationValue + (i * 0.5),
                );
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
