import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/animated_theme_toggle.dart';
import '../../widgets/futuristic_glass_card.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({Key? key}) : super(key: key);

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  bool _isProActive = false;

  @override
  void initState() {
    super.initState();
    _loadProStatus();
  }

  Future<void> _loadProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isProActive = prefs.getBool('mp_is_pro') ?? false;
      });
    }
  }

  Future<void> _setProStatus(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mp_is_pro', active);
    if (mounted) {
      setState(() {
        _isProActive = active;
      });
    }
  }

  void _showCheckoutDialog() {
    final isDark = AppColors.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: const Text('Confirm Pro Subscription', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan: MarketPulse Quantitative Pro', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Price: €9.99 / month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.secondary)),
            SizedBox(height: 12),
            Text(
              'Instant access to real-time order books, sub-second telemetry, and unlimited institutional portfolio models.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _setProStatus(true);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('MarketPulse Pro successfully activated!'),
                  backgroundColor: AppColors.positive,
                ),
              );
            },
            child: const Text('Activate Pro Access'),
          ),
        ],
      ),
    );
  }

  void _showManageProModal() {
    final isDark = AppColors.isDark(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_rounded, color: AppColors.positive, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Pro Subscription',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    _manageRow('Active Plan', 'MarketPulse Institutional Pro', isDark),
                    const Divider(height: 16),
                    _manageRow('Billing Rate', '€9.99 / month', isDark),
                    const Divider(height: 16),
                    _manageRow('Status', 'Active & Verified', isDark),
                    const Divider(height: 16),
                    _manageRow('Telemetry Rate', '100ms sub-second', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _setProStatus(false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Subscription downgraded to Free Standard Tier.'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.negative,
                        side: const BorderSide(color: AppColors.negative),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Downgrade to Free'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Keep Active'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _manageRow(String title, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
        Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
      ],
    );
  }

  void _showFeatureDetailsDialog(String feature) {
    final isDark = AppColors.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(feature, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Included in MarketPulse Pro Tier. Provides continuous algorithmic synchronization across both web dashboard and mobile app with priority execution.',
              style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.positive.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.positive, size: 16),
                  SizedBox(width: 6),
                  Text('Active in Pro Tier', style: TextStyle(color: AppColors.positive, fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MarketPulse Pro'),
        actions: const [
          AnimatedThemeToggle(),
          SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Pro Crown / Star Badge
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 18),
            Text(
              'Institutional Tier',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Engineered for algorithmic traders and high-conviction portfolios.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 24),

            // Futuristic Glass Pricing Card
            FuturisticGlassCard(
              hasGlow: true,
              glowColor: AppColors.secondary,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '€9.99',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ month',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cancel anytime • Instant activation',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  const SizedBox(height: 14),
                  _featureRow('Sub-second institutional streaming telemetry', isDark),
                  _featureRow('Interactive multi-range technical charts (1D to 1Y)', isDark),
                  _featureRow('5-Year deep historical price archive', isDark),
                  _featureRow('Unlimited equity portfolio models & analytics', isDark),
                  _featureRow('Custom dynamic multi-currency converter', isDark),
                  _featureRow('Real-time priority financial wire news', isDark),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProActive ? _showManageProModal : _showCheckoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isProActive ? AppColors.positive : AppColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isProActive ? Icons.verified_rounded : Icons.bolt_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isProActive ? 'Manage Pro Subscription (Active)' : 'Unlock Pro Access Now',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(String text, bool isDark) {
    return InkWell(
      onTap: () => _showFeatureDetailsDialog(text),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.positive.withOpacity(0.18),
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.positive, size: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}
