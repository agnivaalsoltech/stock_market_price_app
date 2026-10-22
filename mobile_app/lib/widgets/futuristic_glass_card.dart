import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Ultra-modern glassmorphic card container with 1px hairline gradient border
class FuturisticGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool hasGlow;
  final Color? glowColor;
  final Gradient? customGradient;

  const FuturisticGlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 16.0,
    this.onTap,
    this.hasGlow = false,
    this.glowColor,
    this.customGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final effectiveGlow = hasGlow
        ? [
            BoxShadow(
              color: (glowColor ?? AppColors.secondary).withOpacity(isDark ? 0.25 : 0.12),
              blurRadius: 16,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            )
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ];

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
        gradient: customGradient,
        boxShadow: effectiveGlow,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
