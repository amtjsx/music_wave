import 'dart:math';

import 'package:flutter/material.dart';

class MusicWaveAnimation extends StatefulWidget {
  final Color color;
  final int barCount;
  final double height;
  final bool isPlaying;

  const MusicWaveAnimation({
    Key? key,
    this.color = Colors.blue,
    this.barCount = 5,
    this.height = 30,
    this.isPlaying = false,
  }) : super(key: key);

  @override
  State<MusicWaveAnimation> createState() => _MusicWaveAnimationState();
}

class _MusicWaveAnimationState extends State<MusicWaveAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + _random.nextInt(400)),
      ),
    );

    _animations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0.3, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (var controller in _controllers) {
      controller.forward().then((_) {
        controller.reverse().then((_) {
          if (widget.isPlaying && mounted) {
            controller.repeat(reverse: true);
          }
        });
      });
      // Stagger the start of each animation
      Future.delayed(Duration(milliseconds: _random.nextInt(200)));
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
    }
  }

  @override
  void didUpdateWidget(MusicWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.barCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 3,
              height: widget.height * _animations[index].value,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          },
        );
      }),
    );
  }
}
