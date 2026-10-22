class ApiConstants {
  /// Default Wi-Fi / LAN Endpoint (Works directly on physical phones, tablets & PC)
  static const String defaultWifiLanUrl = 'http://192.168.1.4:8000';
  static String _customBaseUrl = defaultWifiLanUrl;

  /// Dynamic base URL:
  /// Defaults to the Wi-Fi / LAN address (http://192.168.1.4:8000) so physical mobile
  /// devices and computers connect directly to the active PHP development server.
  static String get webBaseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    return defaultWifiLanUrl;
  }

  static set customBaseUrl(String url) {
    _customBaseUrl = url.trim().isEmpty ? defaultWifiLanUrl : url.trim();
  }

  static String get stockEndpoint => '$webBaseUrl/api/stock.php';
  static String get historyEndpoint => '$webBaseUrl/api/history.php';
  static String get searchEndpoint => '$webBaseUrl/api/search.php';
  static String get currencyEndpoint => '$webBaseUrl/api/currency.php';
  static String get newsEndpoint => '$webBaseUrl/api/news.php';

  static String webStockDetailUrl(String symbol) => '$webBaseUrl/stock.php?symbol=$symbol';
}
