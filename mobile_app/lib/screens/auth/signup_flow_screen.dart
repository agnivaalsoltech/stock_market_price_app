import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../widgets/animated_theme_toggle.dart';

class SignupFlowScreen extends StatefulWidget {
  const SignupFlowScreen({Key? key}) : super(key: key);

  @override
  State<SignupFlowScreen> createState() => _SignupFlowScreenState();
}

class _SignupFlowScreenState extends State<SignupFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form Controllers - Step 1: Account
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedCountryCode = '+1';

  // Step 2: Citizenship & Tax
  String _selectedCitizenship = 'United States';
  String _selectedTaxResidency = 'United States';
  DateTime _selectedDob = DateTime(1995, 6, 15);
  final _taxIdController = TextEditingController(text: 'US-928-11-4091');

  // Step 3: Financial Background
  String _selectedEmployment = 'Employed';
  String _selectedIndustry = 'Technology & Software';
  String _selectedIncome = '\$50,000 - \$100,000';
  String _selectedNetWorth = '\$150,000 - \$500,000';
  String _selectedFundSource = 'Employment Income';

  // Step 4: Investment Objectives & Risk
  String _selectedExperience = 'Intermediate';
  String _selectedObjective = 'Capital Growth';
  String _selectedRisk = 'Moderate';
  final List<String> _selectedMarkets = [
    'US Equities (NASDAQ/NYSE)',
    'European Blue Chips (DAX/LSE)',
    'Global ETFs',
  ];

  // Step 5: Compliance Disclosures
  bool _w8BenAgreed = true;
  bool _riskAgreed = true;
  bool _termsAgreed = true;

  // State
  bool _isSubmitting = false;
  bool _isCompleted = false;
  String _generatedAccountId = '';

  @override
  void initState() {
    super.initState();
    final current = AuthService().currentProfile;
    if (current != null) {
      _nameController.text = current.name;
      _emailController.text = current.email;
      if (current.phone.isNotEmpty) {
        final parts = current.phone.split(' ');
        if (parts.length > 1) {
          _selectedCountryCode = parts[0];
          _phoneController.text = parts.sublist(1).join(' ');
        } else {
          _phoneController.text = current.phone;
        }
      }
      _selectedCitizenship = current.citizenship;
      _selectedTaxResidency = current.taxResidency;
      if (current.taxId.isNotEmpty) {
        _taxIdController.text = current.taxId;
      }
      _selectedEmployment = current.employmentStatus;
      _selectedIndustry = current.industry;
      _selectedIncome = current.annualIncome;
      _selectedNetWorth = current.netWorth;
      _selectedFundSource = current.fundSource;
      _selectedExperience = current.tradingExperience;
      _selectedObjective = current.investmentObjective;
      _selectedRisk = current.riskTolerance;
      if (current.preferredMarkets.isNotEmpty) {
        _selectedMarkets.clear();
        _selectedMarkets.addAll(current.preferredMarkets);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  void _prefillSampleData() {
    setState(() {
      _nameController.text = 'Alexandra Vance';
      _emailController.text = 'a.vance@capitalgroup.com';
      _phoneController.text = '212-555-0149';
      _selectedCountryCode = '+1';
      _passwordController.text = 'MarketTrader2026!';
      _confirmPasswordController.text = 'MarketTrader2026!';
      _selectedCitizenship = 'United States';
      _selectedTaxResidency = 'United States';
      _selectedDob = DateTime(1992, 4, 18);
      _taxIdController.text = 'US-928-11-4091';
      _selectedEmployment = 'Employed';
      _selectedIndustry = 'Banking & Financial Services';
      _selectedIncome = '\$100,000 - \$250,000';
      _selectedNetWorth = '\$150,000 - \$500,000';
      _selectedFundSource = 'Employment Income';
      _selectedExperience = 'Intermediate';
      _selectedObjective = 'Capital Growth';
      _selectedRisk = 'Moderate';
      _w8BenAgreed = true;
      _riskAgreed = true;
      _termsAgreed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample KYC investor profile prefilled for testing.'),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your legal full name.');
        return false;
      }
      final email = _emailController.text.trim();
      if (!email.contains('@') || !email.contains('.')) {
        _showError('Please provide a valid email address.');
        return false;
      }
      if (_phoneController.text.trim().isEmpty) {
        _showError('Please enter your mobile phone number for 2FA.');
        return false;
      }
      if (_passwordController.text.length < 6) {
        _showError('Password must contain at least 6 characters.');
        return false;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match.');
        return false;
      }
    } else if (step == 1) {
      final age = DateTime.now().year - _selectedDob.year;
      if (age < 18) {
        _showError('International brokerage compliance requires age 18+.');
        return false;
      }
      if (_taxIdController.text.trim().isEmpty) {
        _showError('Tax ID / SSN is mandatory for tax treaty compliance.');
        return false;
      }
    } else if (step == 4) {
      if (!_w8BenAgreed || !_riskAgreed || !_termsAgreed) {
        _showError('Please acknowledge all regulatory disclosures.');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.negative,
      ),
    );
  }

  void _onNext() {
    if (!_validateStep(_currentStep)) return;

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSignup();
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _completeSignup() async {
    setState(() => _isSubmitting = true);

    final accId = 'MP-${100000 + (DateTime.now().millisecondsSinceEpoch % 899999)}-GL';

    final profile = UserProfile(
      accountId: accId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: '$_selectedCountryCode ${_phoneController.text.trim()}',
      citizenship: _selectedCitizenship,
      taxResidency: _selectedTaxResidency,
      dob: '${_selectedDob.year}-${_selectedDob.month.toString().padLeft(2, '0')}-${_selectedDob.day.toString().padLeft(2, '0')}',
      taxId: _taxIdController.text.trim(),
      employmentStatus: _selectedEmployment,
      industry: _selectedIndustry,
      annualIncome: _selectedIncome,
      netWorth: _selectedNetWorth,
      fundSource: _selectedFundSource,
      tradingExperience: _selectedExperience,
      investmentObjective: _selectedObjective,
      riskTolerance: _selectedRisk,
      preferredMarkets: _selectedMarkets,
      isVerified: true,
      virtualBalance: 100000.0,
    );

    await AuthService().signUp(profile);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isCompleted = true;
        _generatedAccountId = accId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    if (_isCompleted) {
      return _buildSuccessScreen(isDark);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Investor Onboarding', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(
              'Step ${_currentStep + 1} of $_totalSteps • ${_getStepTitle(_currentStep)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _prefillSampleData,
            icon: const Icon(Icons.auto_fix_high_rounded, size: 16, color: AppColors.secondary),
            label: const Text('Prefill', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
          ),
          const AnimatedThemeToggle(),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Linear Progress Indicator
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            tween: Tween<double>(begin: 0, end: (_currentStep + 1) / _totalSteps),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 4,
            ),
          ),

          // Stepper Pills Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(_totalSteps, (index) {
                final isDone = index < _currentStep;
                final isActive = index == _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isDone
                          ? AppColors.positive
                          : (isActive ? AppColors.secondary : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                    ),
                  ),
                );
              }),
            ),
          ),

          // PageView with Step Screens
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (idx) => setState(() => _currentStep = idx),
              children: [
                _buildStep1Account(isDark),
                _buildStep2Citizenship(isDark),
                _buildStep3Financials(isDark),
                _buildStep4Objectives(isDark),
                _buildStep5Review(isDark),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    OutlinedButton(
                      onPressed: _onBack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _onNext,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: (_currentStep == _totalSteps - 1) ? AppColors.positive : AppColors.secondary,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep == _totalSteps - 1 ? 'Activate Global Account' : 'Continue',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep == _totalSteps - 1 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Identity & Security';
      case 1:
        return 'Citizenship & Tax';
      case 2:
        return 'Financial Suitability';
      case 3:
        return 'Experience & Risk';
      case 4:
        return 'Regulatory Review';
      default:
        return '';
    }
  }

  // --------------------------------------------------------------------------
  // STEP 1: IDENTITY & CREDENTIALS
  // --------------------------------------------------------------------------
  Widget _buildStep1Account(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderPill(
            icon: Icons.shield_outlined,
            title: 'Account & Security Identity',
            subtitle: 'Provide legal identity credentials for regulatory KYC verification',
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Legal Full Name',
              hintText: 'e.g. Alexandra Vance',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Institutional or Personal Email',
              hintText: 'investor@firm.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              SizedBox(
                width: 112,
                child: DropdownButtonFormField<String>(
                  value: _selectedCountryCode,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: '+49', child: Text('🇩🇪 +49', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: '+81', child: Text('🇯🇵 +81', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: '+33', child: Text('🇫🇷 +33', style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: (v) => setState(() => _selectedCountryCode = v ?? '+1'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Phone (2FA SMS)',
                    hintText: '555-019-2834',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Security Password',
              hintText: 'Min 6 characters',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Repeat password',
              prefixIcon: Icon(Icons.verified_user_outlined),
            ),
          ),
          const SizedBox(height: 14),

          _buildSecurityNote(
            'Institutional encryption: Passwords are salt-hashed client side and protected with 256-bit TLS.',
            isDark,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STEP 2: CITIZENSHIP & TAX RESIDENCY
  // --------------------------------------------------------------------------
  Widget _buildStep2Citizenship(bool isDark) {
    final countries = [
      'United States',
      'Germany',
      'United Kingdom',
      'India',
      'Japan',
      'Switzerland',
      'France',
      'Singapore',
      'Canada',
      'Australia',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderPill(
            icon: Icons.public_rounded,
            title: 'Citizenship & Tax Jurisdiction',
            subtitle: 'International treaties (MiFID II, SEC, W-8BEN) require tax residency declaration',
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: _selectedCitizenship,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Country of Citizenship',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedCitizenship = v ?? 'United States'),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedTaxResidency,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Primary Tax Residency Country',
              prefixIcon: Icon(Icons.account_balance_outlined),
            ),
            items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedTaxResidency = v ?? 'United States'),
          ),
          const SizedBox(height: 16),

          // Date of Birth
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDob,
                firstDate: DateTime(1930),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              );
              if (picked != null) {
                setState(() => _selectedDob = picked);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                borderRadius: BorderRadius.circular(12),
                color: isDark ? AppColors.darkCard : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cake_outlined, color: AppColors.secondary, size: 22),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date of Birth (18+ Required)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          Text(
                            '${_selectedDob.day}/${_selectedDob.month}/${_selectedDob.year}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.secondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _taxIdController,
            decoration: const InputDecoration(
              labelText: 'Tax Identification Number (TIN / SSN / PAN)',
              hintText: 'US-928-11-4091',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 14),

          _buildSecurityNote(
            'Foreign Tax Treaty Compliance: Tax IDs are encrypted and submitted to custodian clearing houses under the US-OECD reciprocal tax agreement.',
            isDark,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STEP 3: FINANCIAL SUITABILITY & EMPLOYMENT
  // --------------------------------------------------------------------------
  Widget _buildStep3Financials(bool isDark) {
    final employmentTypes = [
      {'val': 'Employed', 'label': 'Employed', 'sub': 'Salaried Corporate', 'icon': Icons.business_center_rounded},
      {'val': 'Self-Employed', 'label': 'Self-Employed', 'sub': 'Business Owner', 'icon': Icons.storefront_rounded},
      {'val': 'Professional Trader', 'label': 'Pro Trader', 'sub': 'Full-time Markets', 'icon': Icons.trending_up_rounded},
      {'val': 'Investor', 'label': 'Investor', 'sub': 'Private Capital', 'icon': Icons.diamond_outlined},
      {'val': 'Retired', 'label': 'Retired', 'sub': 'Pensions & Wealth', 'icon': Icons.beach_access_rounded},
      {'val': 'Student', 'label': 'Student', 'sub': 'Academic Finance', 'icon': Icons.school_rounded},
    ];

    final incomes = [
      'Under \$25,000',
      '\$25,000 - \$50,000',
      '\$50,000 - \$100,000',
      '\$100,000 - \$250,000',
      'Over \$250,000',
    ];

    final netWorths = [
      'Under \$50,000',
      '\$50,000 - \$150,000',
      '\$150,000 - \$500,000',
      '\$500,000 - \$1,000,000',
      'Over \$1,000,000',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderPill(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Financial Background & Suitability',
            subtitle: 'Evaluates investor suitability under global brokerage exchange standards',
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          const Text('Employment Status', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.1,
            children: employmentTypes.map((item) {
              final isSelected = _selectedEmployment == item['val'];
              return InkWell(
                onTap: () => setState(() => _selectedEmployment = item['val'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary.withOpacity(0.12) : (isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData, color: isSelected ? AppColors.secondary : AppColors.textMuted, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 13,
                                color: isSelected ? AppColors.secondary : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              ),
                            ),
                            Text(
                              item['sub'] as String,
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: _selectedIncome,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Gross Annual Income Range',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
            items: incomes.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: (v) => setState(() => _selectedIncome = v ?? '\$50,000 - \$100,000'),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedNetWorth,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Estimated Liquid Net Worth',
              prefixIcon: Icon(Icons.savings_outlined),
            ),
            items: netWorths.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
            onChanged: (v) => setState(() => _selectedNetWorth = v ?? '\$150,000 - \$500,000'),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedFundSource,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Primary Source of Trading Funds',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'Employment Income', child: Text('Employment Income / Salary')),
              DropdownMenuItem(value: 'Business Profits', child: Text('Business Profits & Dividends')),
              DropdownMenuItem(value: 'Personal Savings', child: Text('Personal Savings & Capital')),
              DropdownMenuItem(value: 'Inheritance & Wealth', child: Text('Inheritance & Family Trust')),
            ],
            onChanged: (v) => setState(() => _selectedFundSource = v ?? 'Employment Income'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STEP 4: EXPERIENCE & OBJECTIVES
  // --------------------------------------------------------------------------
  Widget _buildStep4Objectives(bool isDark) {
    final experiences = [
      {'val': 'Beginner', 'label': 'Beginner', 'desc': '< 1 year trading equities', 'icon': Icons.eco_outlined},
      {'val': 'Intermediate', 'label': 'Intermediate', 'desc': '1 - 3 years active trading', 'icon': Icons.bar_chart_rounded},
      {'val': 'Advanced', 'label': 'Advanced', 'desc': '3+ years / Institutional', 'icon': Icons.military_tech_rounded},
    ];

    final riskTolerances = [
      {'val': 'Conservative', 'badge': 'Low Risk', 'color': AppColors.positive, 'sub': 'Capital preservation & dividends'},
      {'val': 'Moderate', 'badge': 'Balanced', 'color': AppColors.warning, 'sub': 'Steady long-term index growth'},
      {'val': 'Aggressive', 'badge': 'High Alpha', 'color': AppColors.negative, 'sub': 'Max capital growth with volatility'},
    ];

    final availableMarkets = [
      'US Equities (NASDAQ/NYSE)',
      'European Blue Chips (DAX/LSE)',
      'Asian Markets (Nikkei/Nifty)',
      'Global ETFs',
      'Forex & Commodities',
      'Digital Assets & Web3',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderPill(
            icon: Icons.track_changes_rounded,
            title: 'Experience, Objectives & Risk',
            subtitle: 'Calibrates portfolio risk guards, order routing, and asset recommendations',
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          const Text('Equities Trading Experience', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: 8),

          Row(
            children: experiences.map((item) {
              final isSelected = _selectedExperience == item['val'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _selectedExperience = item['val'] as String),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary.withOpacity(0.12) : (isDark ? AppColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(item['icon'] as IconData, color: isSelected ? AppColors.secondary : AppColors.textMuted, size: 24),
                          const SizedBox(height: 6),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12.5,
                              color: isSelected ? AppColors.secondary : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['desc'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          const Text('Risk Tolerance Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: 8),

          Column(
            children: riskTolerances.map((item) {
              final isSelected = _selectedRisk == item['val'];
              final color = item['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedRisk = item['val'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['val'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(item['sub'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          const Text('Preferred Markets & Assets', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableMarkets.map((market) {
              final isSelected = _selectedMarkets.contains(market);
              return FilterChip(
                label: Text(market, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal)),
                selected: isSelected,
                selectedColor: AppColors.secondary.withOpacity(0.18),
                checkmarkColor: AppColors.secondary,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedMarkets.add(market);
                    } else {
                      _selectedMarkets.remove(market);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STEP 5: REGULATORY REVIEW & LEGAL DISCLOSURES
  // --------------------------------------------------------------------------
  Widget _buildStep5Review(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderPill(
            icon: Icons.assignment_turned_in_outlined,
            title: 'Review Dossier & Legal Agreements',
            subtitle: 'Verify your submitted investor information and certify mandatory compliance disclosures',
            isDark: isDark,
          ),
          const SizedBox(height: 18),

          // Dossier Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('INVESTOR PROFILE SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.secondary, letterSpacing: 0.8)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.positive.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Ready for Clearance', style: TextStyle(color: AppColors.positive, fontWeight: FontWeight.w800, fontSize: 10.5)),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildReviewRow('Full Legal Name', _nameController.text.isNotEmpty ? _nameController.text : 'Alexandra Vance'),
                _buildReviewRow('Email Address', _emailController.text.isNotEmpty ? _emailController.text : 'a.vance@capitalgroup.com'),
                _buildReviewRow('Citizenship & Tax', '$_selectedCitizenship / $_selectedTaxResidency'),
                _buildReviewRow('Tax Identification', _taxIdController.text.isNotEmpty ? '••••-••-${_taxIdController.text.substring(_taxIdController.text.length - 4)}' : 'US-***-4091'),
                _buildReviewRow('Employment', '$_selectedEmployment • $_selectedIndustry'),
                _buildReviewRow('Financial Profile', '$_selectedIncome • Net: $_selectedNetWorth'),
                _buildReviewRow('Trading Profile', '$_selectedExperience Experience • $_selectedRisk Risk'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Disclosures
          const Text('Mandatory Certifications', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: 8),

          _buildCheckboxTile(
            title: 'Form W-8BEN / FATCA Tax Declaration',
            subtitle: 'I certify that the beneficial owner is the person indicated and declare non-US treaty benefits where applicable under penalties of perjury.',
            value: _w8BenAgreed,
            onChanged: (v) => setState(() => _w8BenAgreed = v ?? false),
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          _buildCheckboxTile(
            title: 'Global Securities Risk Disclosure',
            subtitle: 'I acknowledge that trading global equities, ADRs, and ETFs carries risk of principal loss, currency risk, and market volatility.',
            value: _riskAgreed,
            onChanged: (v) => setState(() => _riskAgreed = v ?? false),
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          _buildCheckboxTile(
            title: 'Customer Agreement & Electronic Signature',
            subtitle: 'I consent to electronic delivery of statements, trade confirmations, and accept the MarketPulse Master Brokerage Terms.',
            value: _termsAgreed,
            onChanged: (v) => setState(() => _termsAgreed = v ?? false),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SUCCESS / ACTIVATION SCREEN
  // --------------------------------------------------------------------------
  Widget _buildSuccessScreen(bool isDark) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.positive.withOpacity(0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.positive.withOpacity(0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.verified_rounded, color: AppColors.positive, size: 54),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Global Account Activated!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),

                Text(
                  'Welcome to MarketPulse. Your multi-market institutional profile is fully certified and funded.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
                const SizedBox(height: 28),

                // Credentials summary card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      _buildReviewRow('Account Number', _generatedAccountId, isHighlight: true),
                      _buildReviewRow('Account Holder', _nameController.text.isNotEmpty ? _nameController.text : 'Alexandra Vance'),
                      _buildReviewRow('Compliance Status', 'Tier 1 Verified Investor'),
                      _buildReviewRow('Virtual Buying Power', '€100,000.00 / \$109,000.00'),
                      _buildReviewRow('Risk Safeguards', '$_selectedRisk Profile Active'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: AppColors.secondary,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.candlestick_chart_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Enter MarketPulse Terminal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.portfolio, (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Open Portfolio Workstation', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // HELPER WIDGETS
  // --------------------------------------------------------------------------
  Widget _buildHeaderPill({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_rounded, size: 16, color: AppColors.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
                color: isHighlight ? AppColors.secondary : null,
                fontFamily: isHighlight ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.secondary,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ),
    );
  }
}
