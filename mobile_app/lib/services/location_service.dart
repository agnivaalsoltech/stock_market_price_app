import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  String _currentCountry = 'Germany';
  String _currentExchange = 'XETRA (Frankfurt)';
  String _countryFlag = 'DE';
  bool _isPermissionGranted = false;
  String? _errorMessage;

  String get currentCountry => _currentCountry;
  String get currentExchange => _currentExchange;
  String get countryFlag => _countryFlag;
  bool get isPermissionGranted => _isPermissionGranted;
  String? get errorMessage => _errorMessage;

  static const Map<String, Map<String, String>> countryMetadata = {
    'Germany': {'flag': 'DE', 'exchange': 'XETRA (Frankfurt)'},
    'USA': {'flag': 'US', 'exchange': 'NYSE / NASDAQ'},
    'United Kingdom': {'flag': 'GB', 'exchange': 'LSE (London)'},
    'India': {'flag': 'IN', 'exchange': 'NSE / BSE (Mumbai)'},
  };

  /// Determine user location via Geolocator according to exam requirements
  Future<void> detectLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled. Using fallback.';
        _setFallback('Germany');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied. Using fallback.';
          _setFallback('Germany');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions permanently denied. Using manual selection.';
        _setFallback('Germany');
        return;
      }

      _isPermissionGranted = true;
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 4),
      );

      // In production/exam environments, map coordinates to relevant market country
      if (position.latitude >= 47 && position.latitude <= 55) {
        setCountry('Germany');
      } else if (position.latitude >= 24 && position.latitude <= 49 && position.longitude < -60) {
        setCountry('USA');
      } else if (position.latitude >= 8 && position.latitude <= 37 && position.longitude >= 68 && position.longitude <= 97) {
        setCountry('India');
      } else if (position.latitude >= 50 && position.latitude <= 60 && position.longitude >= -10 && position.longitude <= 2) {
        setCountry('United Kingdom');
      } else {
        setCountry('Germany');
      }
    } catch (e) {
      _errorMessage = 'Geolocation exception: $e. Falling back to default.';
      _setFallback('Germany');
    }
  }

  void setCountry(String countryName) {
    if (!countryMetadata.containsKey(countryName)) return;
    _currentCountry = countryName;
    _currentExchange = countryMetadata[countryName]!['exchange']!;
    _countryFlag = countryMetadata[countryName]!['flag']!;
    _errorMessage = null;
    notifyListeners();
  }

  void _setFallback(String country) {
    _isPermissionGranted = false;
    setCountry(country);
  }
}
