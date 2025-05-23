// TODO Implement this library.
import 'dart:math';

import 'package:flutter/material.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double height;
  final int barCount;
  final double
  activeBarRatio; // Percentage of bars that should be active (0.0 to 1.0)

  const AudioVisualizer({
    Key? key,
    required this.isPlaying,
    this.color = Colors.purple,
    this.height = 40.0,
    this.barCount = 30,
    this.activeBarRatio = 0.8,
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
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
      duration: const Duration(milliseconds: 250),
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
  void didUpdateWidget(AudioVisualizer oldWidget) {
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
      (index) => _random.nextDouble() * 0.8 + 0.2, // Between 0.2 and 1.0
    );
  }

  void _updateBars() {
    if (!mounted) return;

    setState(() {
      // Only update a subset of bars each frame for a more natural look
      final activeBarCount = (widget.barCount * widget.activeBarRatio).round();
      for (int i = 0; i < activeBarCount; i++) {
        final barIndex = _random.nextInt(widget.barCount);
        final newHeight =
            _random.nextDouble() * 0.8 + 0.2; // Between 0.2 and 1.0

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
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.barCount, (index) => _buildBar(index)),
      ),
    );
  }

  Widget _buildBar(int index) {
    final double barHeight = widget.height * _barHeights[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 3,
      height: widget.isPlaying ? barHeight : widget.height * 0.1,
      decoration: BoxDecoration(
        color: widget.color.withOpacity(widget.isPlaying ? 0.8 : 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
