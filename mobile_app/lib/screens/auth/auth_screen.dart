import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/animated_theme_toggle.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  String? _loginEmailError;
  String? _loginPasswordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  void _prefillDemo() {
    setState(() {
      _loginEmailController.text = 'alexandra.vance@capitalgroup.com';
      _loginPasswordController.text = 'SecuredPass2026!';
      _loginEmailError = null;
      _loginPasswordError = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo investor credentials loaded.'),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loginEmailError = null;
      _loginPasswordError = null;
    });

    final email = _loginEmailController.text.trim();
    final pass = _loginPasswordController.text;

    bool valid = true;
    if (!email.contains('@') || !email.contains('.')) {
      _loginEmailError = 'Please enter a valid institutional email.';
      valid = false;
    }
    if (pass.length < 6) {
      _loginPasswordError = 'Password must be at least 6 characters.';
      valid = false;
    }

    if (!valid) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    final success = await AuthService().signIn(email, pass);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Terminal Access Granted. Welcome back.')),
            ],
          ),
          backgroundColor: AppColors.positive,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal Access'),
        actions: [
          TextButton.icon(
            onPressed: _prefillDemo,
            icon: const Icon(Icons.bolt_rounded, size: 18, color: AppColors.secondary),
            label: const Text('Demo', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
          ),
          const AnimatedThemeToggle(),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Logo Branding
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.candlestick_chart_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'MarketPulse Gateway',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Institutional access to global multi-market telemetry',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
            const SizedBox(height: 24),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                tabs: const [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Open Account (5 Steps)'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab Content
            SizedBox(
              height: 430,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ------------------------------------
                  // TAB 1: SIGN IN VIEW
                  // ------------------------------------
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _loginEmailController,
                        decoration: InputDecoration(
                          labelText: 'Institutional Email',
                          errorText: _loginEmailError,
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _loginPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: _loginPasswordError,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: AppColors.secondary,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Sign In to Terminal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset instructions sent to your registered email.')),
                          );
                        },
                        child: const Text('Forgot access credentials?'),
                      ),
                      const Spacer(),

                      // Switch to Multi-step signup promo
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_outlined, color: AppColors.secondary, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('New to global markets?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(
                                    'Complete KYC onboarding in 5 easy steps',
                                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.signupFlow),
                              child: const Text('Start &rarr;', style: TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ------------------------------------
                  // TAB 2: MULTI-STEP SIGNUP PROMO VIEW
                  // ------------------------------------
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Global Multi-Market Onboarding',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.secondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureBullet(Icons.check_circle_rounded, 'Step 1: Identity & Credentials Security'),
                            _buildFeatureBullet(Icons.check_circle_rounded, 'Step 2: Citizenship & W-8BEN Tax Declaration'),
                            _buildFeatureBullet(Icons.check_circle_rounded, 'Step 3: Financial Background & Suitability'),
                            _buildFeatureBullet(Icons.check_circle_rounded, 'Step 4: Investment Objectives & Risk Profile'),
                            _buildFeatureBullet(Icons.check_circle_rounded, 'Step 5: Review & Brokerage Agreement'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.signupFlow),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: AppColors.positive,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Start 5-Step Investor Flow',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Complies with FINRA, SEC, and MiFID II cross-border investor suitability mandates. Instant €100,000 demo trading allocation upon certification.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, height: 1.4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.positive),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
