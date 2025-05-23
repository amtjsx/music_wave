// TODO Implement this library.
import 'dart:math';

import 'package:flutter/material.dart';

class CircularVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double size;
  final int barCount;

  const CircularVisualizer({
    Key? key,
    required this.isPlaying,
    this.color = Colors.purple,
    this.size = 300.0,
    this.barCount = 60,
  }) : super(key: key);

  @override
  State<CircularVisualizer> createState() => _CircularVisualizerState();
}

class _CircularVisualizerState extends State<CircularVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<double> _barHeights;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Initialize bar heights
    _initializeBarHeights();

    // Start animation if playing
    if (widget.isPlaying) {
      _animationController.repeat(reverse: true);
    }

    // Set up listener to update bars
    _animationController.addListener(_updateBars);
  }

  @override
  void didUpdateWidget(CircularVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle play/pause state changes
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }

    // Handle bar count changes
    if (widget.barCount != oldWidget.barCount) {
      _initializeBarHeights();
    }
  }

  void _initializeBarHeights() {
    // Create initial bar heights with some randomness
    _barHeights = List.generate(
      widget.barCount,
      (index) => _random.nextDouble() * 0.5 + 0.2, // Between 0.2 and 0.7
    );
  }

  void _updateBars() {
    if (!mounted) return;

    setState(() {
      // Update a subset of bars each frame for a more natural look
      final updateCount = (widget.barCount * 0.3).round();
      for (int i = 0; i < updateCount; i++) {
        final barIndex = _random.nextInt(widget.barCount);
        final newHeight =
            _random.nextDouble() * 0.5 + 0.2; // Between 0.2 and 0.7

        // Smooth transition between heights
        _barHeights[barIndex] = _barHeights[barIndex] * 0.7 + newHeight * 0.3;
      }
    });
  }

  @override
  void dispose() {
    _animationController.removeListener(_updateBars);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: CircularVisualizerPainter(
          barHeights: _barHeights,
          color: widget.color,
          isPlaying: widget.isPlaying,
        ),
      ),
    );
  }
}

class CircularVisualizerPainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;
  final bool isPlaying;

  CircularVisualizerPainter({
    required this.barHeights,
    required this.color,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final barWidth = 3.0;
    final maxBarLength = radius * 0.3; // 30% of radius

    // Draw outer circle
    final outerCirclePaint =
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius * 0.85, outerCirclePaint);

    // Draw bars
    final barPaint =
        Paint()
          ..color = color.withOpacity(isPlaying ? 0.7 : 0.3)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = barWidth;

    final angleStep = 2 * pi / barHeights.length;

    for (int i = 0; i < barHeights.length; i++) {
      final angle = i * angleStep;
      final barHeight =
          isPlaying ? barHeights[i] * maxBarLength : maxBarLength * 0.1;

      final innerPoint = Offset(
        center.dx + (radius - barHeight) * cos(angle),
        center.dy + (radius - barHeight) * sin(angle),
      );

      final outerPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, barPaint);
    }
  }

  @override
  bool shouldRepaint(CircularVisualizerPainter oldDelegate) {
    return oldDelegate.isPlaying != isPlaying ||
        oldDelegate.color != color ||
        oldDelegate.barHeights != barHeights;
  }
}
