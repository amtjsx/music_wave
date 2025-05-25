import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LivePlayerWidget extends ConsumerStatefulWidget {
  final String streamUrl;
  final bool isAudioOnly;
  final String thumbnailUrl;
  
  const LivePlayerWidget({
    super.key,
    required this.streamUrl,
    required this.isAudioOnly,
    required this.thumbnailUrl,
  });

  @override
  ConsumerState<LivePlayerWidget> createState() => _LivePlayerWidgetState();
}

class _LivePlayerWidgetState extends ConsumerState<LivePlayerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  bool _isLoading = true;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _waveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorState();
    }
    
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (widget.isAudioOnly) {
      return _buildAudioPlayer();
    }
    
    return _buildVideoPlayer();
  }
  
  Widget _buildVideoPlayer() {
    return Container(
      height: 300,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player placeholder
          Image.network(
            widget.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
              );
            },
          ),
          
          // Play button overlay (for demo)
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAudioPlayer() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.8),
            const Color(0xFF8B5CF6).withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: WavePatternPainter(
                animation: _waveAnimationController,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated music icon
                AnimatedBuilder(
                  animation: _waveAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_waveAnimationController.value * 0.1),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Audio visualizer bars
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return AnimatedBuilder(
                        animation: _waveAnimationController,
                        builder: (context, child) {
                          final value = (_waveAnimationController.value + 
                              (index * 0.2)) % 1.0;
                          return Container(
                            width: 4,
                            height: 20 + (value * 20),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Container(
      height: 300,
      color: Colors.grey[900],
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Container(
      height: 300,
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load stream',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                // Retry loading
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class WavePatternPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  
  WavePatternPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final path = Path();
    final waveHeight = 20.0;
    final waveCount = 3;
    
    for (int i = 0; i < waveCount; i++) {
      path.reset();
      final phase = animation.value * 2 * 3.14159 + (i * 3.14159 / waveCount);
      
      for (double x = 0; x <= size.width; x++) {
        final y = size.height / 2 + 
            waveHeight * math.sin((x / size.width) * 4 * 3.14159 + phase);
        
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
