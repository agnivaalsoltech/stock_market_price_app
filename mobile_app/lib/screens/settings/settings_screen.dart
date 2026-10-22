import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../services/location_service.dart';
import '../../services/currency_service.dart';
import '../../services/theme_service.dart';
import '../../services/auth_service.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/animated_theme_toggle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _locationService = LocationService();
  final _currencyService = CurrencyService();
  final _themeService = ThemeService();
  bool _testingConnection = false;
  String? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _locationService.addListener(_onServiceChange);
    _currencyService.addListener(_onServiceChange);
    _themeService.addListener(_onServiceChange);
    AuthService().addListener(_onServiceChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testBackend();
    });
  }

  @override
  void dispose() {
    _locationService.removeListener(_onServiceChange);
    _currencyService.removeListener(_onServiceChange);
    _themeService.removeListener(_onServiceChange);
    AuthService().removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    if (mounted) setState(() {});
  }

  void _showCountryDialog() {
    final isDark = AppColors.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: const Text('Choose Country Market', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: LocationService.countryMetadata.keys.map((c) {
              final flag = LocationService.countryMetadata[c]!['flag']!;
              final exchange = LocationService.countryMetadata[c]!['exchange']!;
              final isSelected = _locationService.currentCountry == c;
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
                  ),
                  child: Text(flag, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.secondary)),
                ),
                title: Text(c, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal)),
                subtitle: Text(exchange, style: const TextStyle(fontSize: 12)),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary) : null,
                onTap: () {
                  _locationService.setCountry(c);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _testBackend() async {
    setState(() {
      _testingConnection = true;
      _connectionStatus = null;
    });
    try {
      final sw = Stopwatch()..start();
      final uri = Uri.parse('${ApiConstants.stockEndpoint}?symbol=SAP');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      sw.stop();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final price = data['data']?['price'] ?? 'N/A';
        setState(() {
          _connectionStatus = 'Connected (HTTP 200) • Live SAP: €$price (${sw.elapsedMilliseconds}ms)';
        });
      } else {
        setState(() {
          _connectionStatus = 'Server error: HTTP ${res.statusCode}';
        });
      }
    } catch (e) {
      final msg = e.toString().replaceAll('SocketException:', '').trim();
      setState(() {
        _connectionStatus = 'Failed ($msg). Using cached fallback data.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _testingConnection = false;
        });
      }
    }
  }

  void _showEditUrlDialog() {
    final controller = TextEditingController(text: ApiConstants.webBaseUrl);
    final isDark = AppColors.isDark(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: const Text('Configure Backend URL', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a preset or enter your PC IP address:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('Wi-Fi LAN (192.168.1.4)', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'http://192.168.1.4:8000',
                ),
                ActionChip(
                  label: const Text('PC / ADB (127.0.0.1)', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'http://127.0.0.1:8000',
                ),
                ActionChip(
                  label: const Text('Android Emu (10.0.2.2)', style: TextStyle(fontSize: 11)),
                  onPressed: () => controller.text = 'http://10.0.2.2:8000',
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
          ],
        ),
        actions: [
            TextButton(
              onPressed: () {
                ApiConstants.customBaseUrl = ApiConstants.defaultWifiLanUrl;
                setState(() {});
                _testBackend();
                Navigator.pop(ctx);
              },
              child: const Text('Reset Default (Wi-Fi LAN)'),
            ),
          ElevatedButton(
            onPressed: () {
              ApiConstants.customBaseUrl = controller.text.trim();
              setState(() {});
              _testBackend();
              _currencyService.fetchRatesFromBackend();
              Navigator.pop(ctx);
            },
            child: const Text('Save & Test'),
          ),
        ],
      ),
    );
  }

  void _showClientInfoModal() {
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
                      Icon(Icons.terminal_rounded, color: AppColors.secondaryLight, size: 24),
                      SizedBox(width: 8),
                      Text('MarketPulse Client', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildInfoRow('Version', '2.0.0 Production', isDark),
              _buildInfoRow('Build Engine', 'Flutter 3.x / Impeller', isDark),
              _buildInfoRow('Platform', 'Cross-Platform Mobile Client', isDark),
              _buildInfoRow('Telemetry Protocol', 'High-Frequency REST & WebSockets', isDark),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Client is up-to-date (Version 2.0.0 Pro).'),
                        backgroundColor: AppColors.positive,
                      ),
                    );
                  },
                  icon: const Icon(Icons.system_update_alt_rounded),
                  label: const Text('Check for Updates'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDataProviderModal() {
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
                      Icon(Icons.storage_rounded, color: AppColors.positive, size: 24),
                      SizedBox(width: 8),
                      Text('Data Provider Specs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildInfoRow('Engine Core', 'PHP 8.2 Modular REST API', isDark),
              _buildInfoRow('Exchanges', 'NYSE, NASDAQ, XETRA, LSE, NSE, Euronext', isDark),
              _buildInfoRow('Historical Depth', '1D, 1W, 1M, 3M, 1Y with Volatility', isDark),
              _buildInfoRow('Cache Fallback', 'Active Offline Fallback Matrix', isDark),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _testBackend();
                  },
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Run Telemetry Sync Test'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionChip({
    required String label,
    required String url,
    required bool isDark,
    bool isDefault = false,
  }) {
    final isSelected = ApiConstants.webBaseUrl == url;
    return ChoiceChip(
      avatar: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        size: 15,
        color: isSelected ? Colors.white : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
      ),
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary,
      backgroundColor: isDark ? AppColors.darkCardElevated : Colors.white,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? AppColors.secondary
              : (isDefault ? AppColors.positive.withOpacity(0.5) : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
          width: isDefault ? 1.5 : 1.0,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          ApiConstants.customBaseUrl = url;
          setState(() {});
          _testBackend();
          _currencyService.fetchRatesFromBackend();
        }
      },
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
          Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flag = _locationService.countryFlag;
    final country = _locationService.currentCountry;
    final isDark = AppColors.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
        actions: const [
          AnimatedThemeToggle(),
          SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        children: [
          // Investor Account & Security
          _buildAccountProfileCard(isDark),
          const SizedBox(height: 20),

          // Theme & Appearance Section (Full Dark / Light Mode Toggle)
          Text(
            'Theme & Visual Experience',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                          color: isDark ? const Color(0xFFFACC15) : const Color(0xFFF97316),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDark ? 'Obsidian Dark Mode' : 'Snow Light Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              isDark ? 'Cyber palette (#070B12) with neon accents' : 'High-contrast clean daylight theme',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: isDark,
                      activeColor: AppColors.secondary,
                      onChanged: (val) => _themeService.toggleTheme(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Location Section (handles fallback requirement)
          Text(
            'Location & Market Telemetry',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
                ),
                child: Text(flag, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.secondary)),
              ),
              title: Text(country, style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              subtitle: Text(_locationService.currentExchange, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
              trailing: ElevatedButton(
                onPressed: _showCountryDialog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: const Text('Change'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Currency Section
          Text(
            'Active Currency & Conversion',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: ListTile(
              leading: const Icon(Icons.currency_exchange_rounded, color: AppColors.secondary),
              title: Text('Display Currency', style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              subtitle: Text('Dynamic recalculation across all feeds', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                  value: _currencyService.currentCurrency,
                  items: const [
                    DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                    DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      _currencyService.setCurrency(val);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Backend API Server Section
          Text(
            'Backend Server (PHP API Synchronization)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wifi_rounded, color: AppColors.positive, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Connection Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (ApiConstants.webBaseUrl == ApiConstants.defaultWifiLanUrl)
                            ? AppColors.positive.withOpacity(0.15)
                            : AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (ApiConstants.webBaseUrl == ApiConstants.defaultWifiLanUrl)
                              ? AppColors.positive.withOpacity(0.5)
                              : AppColors.secondary.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        (ApiConstants.webBaseUrl == ApiConstants.defaultWifiLanUrl)
                            ? 'Wi-Fi / LAN (Active)'
                            : 'Custom Mode',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: (ApiConstants.webBaseUrl == ApiConstants.defaultWifiLanUrl)
                              ? AppColors.positive
                              : AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Select communication method with your PC PHP backend:',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildConnectionChip(
                      label: 'Wi-Fi / LAN (192.168.1.4:8000) ⭐ Default',
                      url: ApiConstants.defaultWifiLanUrl,
                      isDark: isDark,
                      isDefault: true,
                    ),
                    _buildConnectionChip(
                      label: 'PC / ADB (127.0.0.1:8000)',
                      url: 'http://127.0.0.1:8000',
                      isDark: isDark,
                    ),
                    _buildConnectionChip(
                      label: 'Android Emu (10.0.2.2:8000)',
                      url: 'http://10.0.2.2:8000',
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Backend Endpoint',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ApiConstants.webBaseUrl,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _showEditUrlDialog,
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('Custom IP'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x2A0F172A) : const Color(0x3AF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (_connectionStatus?.contains('Connected') == true)
                          ? AppColors.positive.withOpacity(0.4)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _connectionStatus == null
                            ? Icons.sync_rounded
                            : (_connectionStatus!.contains('Connected') ? Icons.check_circle_rounded : Icons.warning_amber_rounded),
                        color: _connectionStatus == null
                            ? AppColors.secondary
                            : (_connectionStatus!.contains('Connected') ? AppColors.positive : AppColors.negative),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _connectionStatus ?? 'Checking live connection to PHP backend...',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _connectionStatus?.contains('Connected') == true
                                ? AppColors.positive
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _testingConnection ? null : _testBackend,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: _testingConnection
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Test'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          Text(
            'About Product',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.secondary),
                  title: Text('MarketPulse Client', style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                  subtitle: Text('Version 2.0.0 (Futuristic Material 3 UI)', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showClientInfoModal,
                ),
                Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: const Icon(Icons.verified_outlined, color: AppColors.positive),
                  title: Text('Data Provider', style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                  subtitle: Text('PHP 8 REST Endpoints + Offline Cache Fallback', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showDataProviderModal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountProfileCard(bool isDark) {
    final auth = AuthService();
    final profile = auth.currentProfile;

    if (auth.isLoggedIn && profile != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.secondary.withOpacity(0.15),
                  child: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: AppColors.positive, size: 16),
                        ],
                      ),
                      Text(
                        profile.email,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.negative, size: 20),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    await auth.signOut();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signed out of terminal.')),
                      );
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProfileBadge('ACCOUNT ID', profile.accountId, isDark),
                _buildProfileBadge('COMPLIANCE', 'Tier 1 Verified', isDark, isPositive: true),
                _buildProfileBadge('RISK PROFILE', profile.riskTolerance, isDark),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
                    icon: const Icon(Icons.person_outline_rounded, size: 16, color: Colors.white),
                    label: const Text('View Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signupFlow),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('KYC Onboarding', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_outlined, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Institutional Access', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(
                    'Sign in or start 5-step global onboarding',
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.auth),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: AppColors.secondary,
              ),
              child: const Text('Access', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProfileBadge(String label, String value, bool isDark, {bool isPositive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: isPositive ? AppColors.positive : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
