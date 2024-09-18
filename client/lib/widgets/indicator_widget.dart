import 'package:flutter/material.dart';

class RecordingIndicator extends StatefulWidget {
  final double size;
  final Duration pulseDuration;

  const RecordingIndicator({
    super.key,
    this.size = 20,
    this.pulseDuration = const Duration(seconds: 1),
  });

  @override
  State<RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 1.0, end: 0.5).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(_animation.value * 0.5),
                blurRadius: widget.size / 2,
                spreadRadius: widget.size / 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CircleWidget extends StatelessWidget {
  final double diameter;
  final Color color;

  const CircleWidget({
    super.key,
    this.diameter = 100.0,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
