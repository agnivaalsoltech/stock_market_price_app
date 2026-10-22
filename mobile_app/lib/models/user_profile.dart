import 'dart:convert';

/// Complete model representing an institutional or retail investor profile
/// for global stock market onboarding and regulatory compliance.
class UserProfile {
  final String accountId;
  final String name;
  final String email;
  final String phone;
  final String citizenship;
  final String taxResidency;
  final String dob;
  final String taxId;
  final String employmentStatus;
  final String industry;
  final String annualIncome;
  final String netWorth;
  final String fundSource;
  final String tradingExperience;
  final String investmentObjective;
  final String riskTolerance;
  final List<String> preferredMarkets;
  final bool isVerified;
  final double virtualBalance;
  final DateTime createdAt;

  UserProfile({
    required this.accountId,
    required this.name,
    required this.email,
    required this.phone,
    required this.citizenship,
    required this.taxResidency,
    required this.dob,
    required this.taxId,
    required this.employmentStatus,
    required this.industry,
    required this.annualIncome,
    required this.netWorth,
    required this.fundSource,
    required this.tradingExperience,
    required this.investmentObjective,
    required this.riskTolerance,
    required this.preferredMarkets,
    this.isVerified = true,
    this.virtualBalance = 100000.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'name': name,
      'email': email,
      'phone': phone,
      'citizenship': citizenship,
      'taxResidency': taxResidency,
      'dob': dob,
      'taxId': taxId,
      'employmentStatus': employmentStatus,
      'industry': industry,
      'annualIncome': annualIncome,
      'netWorth': netWorth,
      'fundSource': fundSource,
      'tradingExperience': tradingExperience,
      'investmentObjective': investmentObjective,
      'riskTolerance': riskTolerance,
      'preferredMarkets': preferredMarkets,
      'isVerified': isVerified,
      'virtualBalance': virtualBalance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      accountId: map['accountId'] ?? 'MP-DEMO-01',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      citizenship: map['citizenship'] ?? 'United States',
      taxResidency: map['taxResidency'] ?? 'United States',
      dob: map['dob'] ?? '',
      taxId: map['taxId'] ?? '',
      employmentStatus: map['employmentStatus'] ?? 'Employed',
      industry: map['industry'] ?? 'Technology',
      annualIncome: map['annualIncome'] ?? '\$50,000 - \$100,000',
      netWorth: map['netWorth'] ?? '\$150,000 - \$500,000',
      fundSource: map['fundSource'] ?? 'Employment Income',
      tradingExperience: map['tradingExperience'] ?? 'Intermediate',
      investmentObjective: map['investmentObjective'] ?? 'Capital Growth',
      riskTolerance: map['riskTolerance'] ?? 'Moderate',
      preferredMarkets: List<String>.from(map['preferredMarkets'] ?? ['US Equities', 'European Markets']),
      isVerified: map['isVerified'] ?? true,
      virtualBalance: (map['virtualBalance'] as num?)?.toDouble() ?? 100000.0,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) ?? DateTime.now() : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));

  /// Static sample demo profile for presentation and quick testing
  factory UserProfile.sampleDemo() {
    return UserProfile(
      accountId: 'MP-892410-GL',
      name: 'Alexandra Vance',
      email: 'a.vance@capitalgroup.com',
      phone: '+1 212-555-0149',
      citizenship: 'United States',
      taxResidency: 'United States',
      dob: '1992-04-18',
      taxId: 'US-928-11-4091',
      employmentStatus: 'Employed',
      industry: 'Banking & Financial Services',
      annualIncome: '\$100,000 - \$250,000',
      netWorth: '\$150,000 - \$500,000',
      fundSource: 'Employment Income',
      tradingExperience: 'Intermediate (1-3 yrs)',
      investmentObjective: 'Long-term Capital Growth',
      riskTolerance: 'Moderate',
      preferredMarkets: ['US Equities', 'European Markets', 'Global ETFs'],
      isVerified: true,
      virtualBalance: 100000.0,
    );
  }
}
