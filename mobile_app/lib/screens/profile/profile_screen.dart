import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../widgets/animated_theme_toggle.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _copyAccountId(String accountId) {
    Clipboard.setData(ClipboardData(text: accountId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account ID $accountId copied to clipboard.'),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditProfileDialog(UserProfile profile, bool isDark) {
    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone);
    String selectedRisk = profile.riskTolerance;
    String selectedIncome = profile.annualIncome;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Update Profile Details', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Legal Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRisk,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Risk Tolerance'),
                  items: const [
                    DropdownMenuItem(value: 'Conservative', child: Text('Conservative (Low Risk)')),
                    DropdownMenuItem(value: 'Moderate', child: Text('Moderate (Balanced)')),
                    DropdownMenuItem(value: 'Aggressive', child: Text('Aggressive (High Alpha)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedRisk = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedIncome,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Annual Income Bracket'),
                  items: const [
                    DropdownMenuItem(value: 'Under \$25,000', child: Text('Under \$25,000')),
                    DropdownMenuItem(value: '\$25,000 - \$50,000', child: Text('\$25,000 - \$50,000')),
                    DropdownMenuItem(value: '\$50,000 - \$100,000', child: Text('\$50,000 - \$100,000')),
                    DropdownMenuItem(value: '\$100,000 - \$250,000', child: Text('\$100,000 - \$250,000')),
                    DropdownMenuItem(value: 'Over \$250,000', child: Text('Over \$250,000')),
                  ],
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedIncome = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = UserProfile(
                  accountId: profile.accountId,
                  name: nameController.text.trim(),
                  email: profile.email,
                  phone: phoneController.text.trim(),
                  citizenship: profile.citizenship,
                  taxResidency: profile.taxResidency,
                  dob: profile.dob,
                  taxId: profile.taxId,
                  employmentStatus: profile.employmentStatus,
                  industry: profile.industry,
                  annualIncome: selectedIncome,
                  netWorth: profile.netWorth,
                  fundSource: profile.fundSource,
                  tradingExperience: profile.tradingExperience,
                  investmentObjective: profile.investmentObjective,
                  riskTolerance: selectedRisk,
                  preferredMarkets: profile.preferredMarkets,
                  isVerified: profile.isVerified,
                  virtualBalance: profile.virtualBalance,
                  createdAt: profile.createdAt,
                );

                await _authService.signUp(updated);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile information updated successfully.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final profile = _authService.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investor Profile & Dossier'),
        actions: [
          if (profile != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Edit Profile',
              onPressed: () => _showEditProfileDialog(profile, isDark),
            ),
          const AnimatedThemeToggle(),
          const SizedBox(width: 4),
        ],
      ),
      body: profile == null ? _buildGuestView(isDark) : _buildActiveProfileView(profile, isDark),
    );
  }

  // --------------------------------------------------------------------------
  // GUEST VIEW (When Not Signed In)
  // --------------------------------------------------------------------------
  Widget _buildGuestView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded, color: AppColors.secondary, size: 44),
            ),
            const SizedBox(height: 20),

            const Text(
              'Investor Profile Access',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),

            Text(
              'Sign in or start the 5-step global onboarding flow to access your institutional dossier, verified credentials, and cross-border brokerage clearing.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, height: 1.4),
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.auth),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: AppColors.secondary,
              ),
              child: const Text('Sign In to Terminal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
            ),
            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.signupFlow),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Open Global Account (5-Step KYC)', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: () async {
                await _authService.quickDemoLogin();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo investor session activated.')),
                  );
                }
              },
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text('Load Demo Investor Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ACTIVE PROFILE VIEW
  // --------------------------------------------------------------------------
  Widget _buildActiveProfileView(UserProfile profile, bool isDark) {
    final initials = profile.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join('').toUpperCase();
    final displayInitials = initials.isNotEmpty ? (initials.length > 2 ? initials.substring(0, 2) : initials) : 'IV';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFEFF6FF), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.secondary,
                      child: Text(
                        displayInitials,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile.name,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: AppColors.positive, size: 20),
                            ],
                          ),
                          Text(
                            profile.email,
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.positive.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Tier 1 Verified Investor',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.positive),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Account ID: ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        Text(
                          profile.accountId,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: AppColors.secondary),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.secondary),
                      tooltip: 'Copy Account ID',
                      onPressed: () => _copyAccountId(profile.accountId),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Horizontal Summary Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Buying Power',
                  value: '€100,000',
                  subtitle: 'Demo Clearing',
                  color: AppColors.positive,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Compliance',
                  value: 'Cleared',
                  subtitle: 'W-8BEN Active',
                  color: AppColors.secondary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Risk Profile',
                  value: profile.riskTolerance,
                  subtitle: 'Balanced',
                  color: profile.riskTolerance == 'Aggressive' ? AppColors.negative : (profile.riskTolerance == 'Moderate' ? AppColors.warning : AppColors.positive),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 1: Legal Identity & Communication
          _buildSectionHeader('Legal Identity & Contact', Icons.badge_outlined, isDark),
          _buildInfoCard(
            isDark: isDark,
            rows: [
              _buildCardRow('Official Name', profile.name),
              _buildCardRow('Primary Email', profile.email),
              _buildCardRow('Registered Phone', profile.phone),
              _buildCardRow('Date of Birth', profile.dob),
              _buildCardRow('2FA Protection', 'Enforced (SMS & Workstation)', isBadge: true, badgeColor: AppColors.positive),
            ],
          ),
          const SizedBox(height: 20),

          // Section 2: Citizenship & Tax Compliance
          _buildSectionHeader('Citizenship & Cross-Border Tax', Icons.public_rounded, isDark),
          _buildInfoCard(
            isDark: isDark,
            rows: [
              _buildCardRow('Citizenship', profile.citizenship),
              _buildCardRow('Tax Residency', profile.taxResidency),
              _buildCardRow('Tax ID / SSN', profile.taxId.isNotEmpty ? (profile.taxId.length > 4 ? '••••-••-${profile.taxId.substring(profile.taxId.length - 4)}' : profile.taxId) : 'US-••••-4091'),
              _buildCardRow('IRS Form W-8BEN', 'Executed & Certified', isBadge: true, badgeColor: AppColors.positive),
              _buildCardRow('Clearing Accord', 'FINRA / SEC & MiFID II Compliant'),
            ],
          ),
          const SizedBox(height: 20),

          // Section 3: Financial Suitability & Employment
          _buildSectionHeader('Financial Background & Suitability', Icons.account_balance_wallet_outlined, isDark),
          _buildInfoCard(
            isDark: isDark,
            rows: [
              _buildCardRow('Employment Status', profile.employmentStatus),
              _buildCardRow('Industry Sector', profile.industry),
              _buildCardRow('Annual Income', profile.annualIncome),
              _buildCardRow('Liquid Net Worth', profile.netWorth),
              _buildCardRow('Source of Capital', profile.fundSource),
            ],
          ),
          const SizedBox(height: 20),

          // Section 4: Investment Objectives & Multi-Market Coverage
          _buildSectionHeader('Trading Profile & Markets', Icons.candlestick_chart_rounded, isDark),
          _buildInfoCard(
            isDark: isDark,
            rows: [
              _buildCardRow('Experience Level', profile.tradingExperience),
              _buildCardRow('Primary Objective', profile.investmentObjective),
              _buildCardRow('Risk Tolerance', profile.riskTolerance, isBadge: true, badgeColor: profile.riskTolerance == 'Aggressive' ? AppColors.negative : AppColors.warning),
              _buildCardRow('DMA Execution', 'Enabled (Real-time Telemetry)', isBadge: true, badgeColor: AppColors.positive),
            ],
          ),
          const SizedBox(height: 12),

          // Preferred Markets Chips
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Approved Market Exchanges', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.preferredMarkets.map((m) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
                      ),
                      child: Text(
                        m,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.signupFlow),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Re-complete 5-Step KYC Onboarding', style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully signed out of terminal.')),
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
            label: const Text('Sign Out of Terminal', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: AppColors.negative,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // HELPER WIDGETS
  // --------------------------------------------------------------------------
  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required bool isDark, required List<Widget> rows}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget _buildCardRow(String label, String value, {bool isBadge = false, Color? badgeColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.secondary).withOpacity(0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: badgeColor ?? AppColors.secondary),
              ),
            )
          else
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
