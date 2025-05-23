import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  // Settings state
  bool _notificationsEnabled = true;
  bool _autoPlay = false;
  bool _highQualityStreaming = true;
  bool _downloadOnWiFiOnly = true;
  bool _crossfadeEnabled = false;
  double _audioQuality = 320;
  String _streamingQuality = 'High';
  String _downloadQuality = 'Very High';
  bool _showExplicitContent = false;
  bool _privateSession = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
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
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Animated Wave Background
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                            Color(0xFFEC4899),
                          ],
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: ProfileWavePainter(_waveAnimation.value),
                          );
                        },
                      ),
                    ),
                  ),
                  // Profile Content
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            image: const DecorationImage(
                              image: NetworkImage('https://picsum.photos/300'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Info
                        const Text(
                          'Alex Johnson',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '@alexjohnson',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Music enthusiast • 1,234 followers',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Songs', '2,847'),
                  _buildStatItem('Playlists', '23'),
                  _buildStatItem('Following', '156'),
                  _buildStatItem('Followers', '1.2K'),
                ],
              ),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      'Recently Played',
                      Icons.history,
                      const Color(0xFF1DB954),
                      () => context.push('/recent-played'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      'Liked Songs',
                      Icons.favorite,
                      const Color(0xFFE91E63),
                      () => context.push('/liked-songs'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings Sections
          SliverToBoxAdapter(child: _buildSectionHeader('Account Settings')),

          SliverToBoxAdapter(
            child: _buildSettingsGroup([
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
          ),

          // Playback Settings
          SliverToBoxAdapter(child: _buildSectionHeader('Playback Settings')),

          SliverToBoxAdapter(
            child: _buildSettingsGroup([
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
          ),

          // Download Settings
          SliverToBoxAdapter(child: _buildSectionHeader('Download Settings')),

          SliverToBoxAdapter(
            child: _buildSettingsGroup([
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
          ),

          // Notifications & Privacy
          SliverToBoxAdapter(
            child: _buildSectionHeader('Notifications & Privacy'),
          ),

          SliverToBoxAdapter(
            child: _buildSettingsGroup([
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
          ),

          // Support & About
          SliverToBoxAdapter(child: _buildSectionHeader('Support & About')),

          SliverToBoxAdapter(
            child: _buildSettingsGroup([
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
          ),

          // Sign Out
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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

  void _showAudioQualityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              _buildQualityOption('Low (96 kbps)', '96'),
              _buildQualityOption('Normal (160 kbps)', '160'),
              _buildQualityOption('High (320 kbps)', '320'),
              _buildQualityOption('Very High (FLAC)', 'FLAC'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQualityOption(String title, String value) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: _audioQuality.toString(),
      onChanged: (String? value) {
        setState(() {
          if (value != null) {
            _audioQuality = double.tryParse(value) ?? 320;
          }
        });
      },
      activeColor: const Color(0xFF6366F1),
    );
  }
}

class ProfileWavePainter extends CustomPainter {
  final double animationValue;

  ProfileWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    final waveHeight = 15.0;
    final waveLength = size.width / 3;

    for (int i = 0; i < 4; i++) {
      path.reset();
      final yOffset = size.height * 0.2 + (i * 25);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            yOffset +
            waveHeight *
                math.sin(
                  (x / waveLength * 2 * math.pi) + animationValue + (i * 0.7),
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
