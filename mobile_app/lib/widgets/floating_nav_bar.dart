import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FloatingNavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FloatingNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating frosted-glass dock navigation bar with smooth animated pill indicator
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavBarItem>? items;

  static const List<FloatingNavBarItem> defaultItems = [
    FloatingNavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    FloatingNavBarItem(
      icon: Icons.candlestick_chart_outlined,
      activeIcon: Icons.candlestick_chart_rounded,
      label: 'Markets',
    ),
    FloatingNavBarItem(
      icon: Icons.pie_chart_outline_rounded,
      activeIcon: Icons.pie_chart_rounded,
      label: 'Portfolio',
    ),
    FloatingNavBarItem(
      icon: Icons.star_outline_rounded,
      activeIcon: Icons.star_rounded,
      label: 'Pro',
    ),
  ];

  const FloatingNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveItems = items ?? defaultItems;
    final isDark = AppColors.isDark(context);
    final dockBg = isDark ? const Color(0xE60C121F) : const Color(0xF2FFFFFF);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      height: 64,
      decoration: BoxDecoration(
        color: dockBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(effectiveItems.length, (index) {
          final isSelected = index == currentIndex;
          final item = effectiveItems[index];
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 10 : 6,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary.withOpacity(isDark ? 0.22 : 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: AppColors.secondary.withOpacity(0.4), width: 1)
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? AppColors.secondaryLight
                              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          size: 19,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 5),
                          Text(
                            item.label,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.secondary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
