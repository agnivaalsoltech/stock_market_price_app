import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class PriceBadge extends StatelessWidget {
  final double changePercent;
  final double? changeAmount;
  final bool showAmount;

  const PriceBadge({
    Key? key,
    required this.changePercent,
    this.changeAmount,
    this.showAmount = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPositive = changePercent >= 0;
    final Color color = isPositive ? AppColors.positive : AppColors.negative;
    final String sign = isPositive ? '+' : '';

    String text = '$sign${changePercent.toStringAsFixed(2)}%';
    if (showAmount && changeAmount != null) {
      text = '$sign${changeAmount!.toStringAsFixed(2)} ($sign${changePercent.toStringAsFixed(2)}%)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.32), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 1),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
