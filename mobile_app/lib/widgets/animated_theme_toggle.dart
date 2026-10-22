import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Animated Sun / Moon toggle button with smooth 360-degree rotation and icon morph
class AnimatedThemeToggle extends StatefulWidget {
  const AnimatedThemeToggle({Key? key}) : super(key: key);

  @override
  State<AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<AnimatedThemeToggle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    final isDark = ThemeService().isDarkMode;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: isDark ? 1.0 : 0.0,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onToggle() {
    final themeService = ThemeService();
    if (themeService.isDarkMode) {
      _controller.reverse();
      themeService.toggleTheme();
    } else {
      _controller.forward();
      themeService.toggleTheme();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, child) {
        final isDark = ThemeService().isDarkMode;
        return IconButton(
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          onPressed: _onToggle,
          icon: RotationTransition(
            turns: _rotationAnimation,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: isDark
                  ? const Icon(
                      Icons.nightlight_round,
                      key: ValueKey('moon'),
                      color: Color(0xFFFACC15), // Amber moon glow
                      size: 20,
                    )
                  : const Icon(
                      Icons.wb_sunny_rounded,
                      key: ValueKey('sun'),
                      color: Color(0xFFF97316), // Warm radiant sun
                      size: 20,
                    ),
            ),
          ),
        );
      },
    );
  }
}
