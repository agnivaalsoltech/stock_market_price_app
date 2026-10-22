import 'package:flutter/material.dart';

/// Smooth animated numerical ticker that animates value changes with high-FPS interpolation
class AnimatedTickerText extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final int fractionDigits;
  final TextStyle style;
  final Duration duration;

  const AnimatedTickerText({
    Key? key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 2,
    required this.style,
    this.duration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value * 0.98, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        final formatted = animatedValue.toStringAsFixed(fractionDigits);
        return Text(
          '$prefix$formatted$suffix',
          style: style,
        );
      },
    );
  }
}
