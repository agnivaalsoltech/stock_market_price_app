import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Central authentication and investor profile management service.
/// Persists verified investor dossiers across app restarts and notifies listeners.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _profileKey = 'mp_mobile_user_profile';
  UserProfile? _currentProfile;
  bool _initialized = false;

  bool get isLoggedIn => _currentProfile != null;
  UserProfile? get currentProfile => _currentProfile;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profileKey);
      if (raw != null && raw.isNotEmpty) {
        _currentProfile = UserProfile.fromJson(raw);
      }
    } catch (e) {
      debugPrint('AuthService init error: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Sign In with existing credentials
  Future<bool> signIn(String email, String password) async {
    // Demo validation
    if (!email.contains('@') || password.length < 6) {
      return false;
    }

    final name = email.split('@').first.replaceAll('.', ' ');
    final profile = UserProfile(
      accountId: 'MP-${(100000 + (DateTime.now().millisecondsSinceEpoch % 899999))}-GL',
      name: name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : 'Investor',
      email: email,
      phone: '+1 555-019-2834',
      citizenship: 'United States',
      taxResidency: 'United States',
      dob: '1995-06-15',
      taxId: 'US-***-**-4912',
      employmentStatus: 'Employed',
      industry: 'Technology & Finance',
      annualIncome: '\$100,000 - \$250,000',
      netWorth: '\$150,000 - \$500,000',
      fundSource: 'Employment Income',
      tradingExperience: 'Intermediate (1-3 yrs)',
      investmentObjective: 'Capital Growth',
      riskTolerance: 'Moderate',
      preferredMarkets: ['US Equities (NASDAQ/NYSE)', 'European Blue Chips'],
      isVerified: true,
      virtualBalance: 100000.0,
    );

    return await signUp(profile);
  }

  /// Complete multi-step onboarding registration
  Future<bool> signUp(UserProfile profile) async {
    try {
      _currentProfile = profile;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, profile.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AuthService signUp error: $e');
      return false;
    }
  }

  /// Quick Demo Login for testing and demos
  Future<void> quickDemoLogin() async {
    final demo = UserProfile.sampleDemo();
    await signUp(demo);
  }

  /// Sign out and clear stored session
  Future<void> signOut() async {
    try {
      _currentProfile = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService signOut error: $e');
    }
  }
}
