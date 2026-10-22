import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/stock.dart';
import '../../models/market_index.dart';
import '../../models/news.dart';
import '../../services/location_service.dart';
import '../../services/currency_service.dart';
import '../../services/stock_api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/market_card.dart';
import '../../widgets/stock_card.dart';
import '../../widgets/news_card.dart';
import '../../widgets/price_badge.dart';
import '../../widgets/pulsing_beacon.dart';
import '../../widgets/animated_ticker_text.dart';
import '../../widgets/futuristic_glass_card.dart';
import '../../widgets/animated_theme_toggle.dart';
import '../../widgets/floating_nav_bar.dart';
import '../main_navigation/main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;

  const HomeScreen({
    Key? key,
    this.showBottomNav = false,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final _apiService = StockApiService();
  final _locationService = LocationService();
  final _currencyService = CurrencyService();

  List<MarketIndex> _indices = [];
  List<Stock> _stocks = [];
  List<NewsArticle> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _locationService.addListener(_onStateChange);
    _currencyService.addListener(_onStateChange);
    AuthService().addListener(_onStateChange);
    _loadData();
  }

  @override
  void dispose() {
    _locationService.removeListener(_onStateChange);
    _currencyService.removeListener(_onStateChange);
    AuthService().removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final country = _locationService.currentCountry;
    
    final indices = await _apiService.getIndicesForCountry(country);
    final stocks = await _apiService.getStocksForCountry(country);
    final news = await _apiService.getNews();

    if (mounted) {
      setState(() {
        _indices = indices;
        _stocks = stocks;
        _news = news;
        _isLoading = false;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);
    MainNavigationScreen.switchTab(context, index);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showMarketPickerModal() {
    final isDark = AppColors.isDark(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Market Exchange',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...LocationService.countryMetadata.keys.map((c) {
                  final flag = LocationService.countryMetadata[c]!['flag']!;
                  final exchange = LocationService.countryMetadata[c]!['exchange']!;
                  final isSelected = _locationService.currentCountry == c;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
                      ),
                      child: Text(flag, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.secondary)),
                    ),
                    title: Text(
                      c,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.secondaryLight
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                    subtitle: Text(
                      exchange,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary)
                        : null,
                    onTap: () {
                      _locationService.setCountry(c);
                      Navigator.pop(ctx);
                      _loadData();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMarketStatusModal() {
    final isDark = AppColors.isDark(context);
    final country = _locationService.currentCountry;
    final exchange = _locationService.currentExchange;
    final flag = _locationService.countryFlag;

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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
                        ),
                        child: Text(flag, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.secondary)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Exchange Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.positive.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.positive.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const PulsingBeacon(color: AppColors.positive, size: 8),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$exchange • Continuous Open',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.positive),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Algorithmic order execution and price discovery active',
                            style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildSessionRow('Market Venue', '$country ($exchange)', isDark),
              _buildSessionRow('Trading Window', '09:30 - 16:00 Local Time', isDark),
              _buildSessionRow('Settlement Protocol', 'T + 1 Automated Delivery', isDark),
              _buildSessionRow('Feed Latency', '12 ms WebSocket stream', isDark),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showMarketPickerModal();
                  },
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Switch Market Exchange'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionRow(String label, String value, bool isDark) {
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

  void _showIndexDetailModal(MarketIndex idx) {
    final isDark = AppColors.isDark(context);
    final country = _locationService.currentCountry;
    final isPos = idx.isPositive;

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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          idx.symbol,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.secondaryLight),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        idx.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BENCHMARK VALUE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        const SizedBox(height: 4),
                        Text(
                          _currencyService.format(idx.price),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    PriceBadge(
                      changePercent: idx.changePercent,
                      changeAmount: idx.change,
                      showAmount: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildSessionRow('Index Sentiment', isPos ? 'Advancing / Bullish' : 'Declining / Consolidation', isDark),
              _buildSessionRow('Country Exchange', country, isDark),
              _buildSessionRow('Calculation', 'Capitalization-Weighted Index', isDark),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        MainNavigationScreen.switchTab(context, 1);
                      },
                      icon: const Icon(Icons.candlestick_chart_rounded, size: 18),
                      label: Text('View $country Equities'),
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

  @override
  Widget build(BuildContext context) {
    final country = _locationService.currentCountry;
    final flag = _locationService.countryFlag;
    final exchange = _locationService.currentExchange;
    final mainIndex = _indices.isNotEmpty ? _indices.first : null;
    final isDark = AppColors.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'MarketPulse',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          const AnimatedThemeToggle(),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search Markets',
            onPressed: () => MainNavigationScreen.switchTab(context, 1),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Investor Profile & Account',
            onPressed: () => Navigator.pushNamed(context, AuthService().isLoggedIn ? AppRoutes.profile : AppRoutes.auth),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                      : [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.secondaryLight.withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 28),
                      ),
                      const AnimatedThemeToggle(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (AuthService().isLoggedIn && AuthService().currentProfile != null) ...[
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            AuthService().currentProfile!.name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: AppColors.positive, size: 18),
                      ],
                    ),
                    Text(
                      '${AuthService().currentProfile!.accountId} • Tier 1 Verified',
                      style: const TextStyle(color: AppColors.positive, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ] else ...[
                    const Text('MarketPulse Pro', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const Text('Institutional Real-time Telemetry', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Home Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
              selected: true,
              selectedColor: AppColors.secondaryLight,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.candlestick_chart_rounded),
              title: const Text('Markets & Snapshot', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                MainNavigationScreen.switchTab(context, 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart_rounded),
              title: const Text('My Portfolio', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                MainNavigationScreen.switchTab(context, 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rounded, color: AppColors.proGold),
              title: const Text('MarketPulse Pro', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                MainNavigationScreen.switchTab(context, 3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: const Text('Settings & Live Backend', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
            if (AuthService().isLoggedIn) ...[
              ListTile(
                leading: const Icon(Icons.person_pin_rounded, color: AppColors.secondary),
                title: const Text('Investor Profile & Dossier', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.negative),
                title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.negative)),
                onTap: () async {
                  Navigator.pop(context);
                  await AuthService().signOut();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out of terminal.')),
                    );
                  }
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.lock_open_rounded),
                title: const Text('Sign In / Register', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.auth);
                },
              ),
            ],
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.secondaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Syncing Market Telemetry...',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90), // Spacing for floating dock
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Telemetry Bar with Pulsing Beacon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
                              ),
                              child: Text(
                                flag,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.secondary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              country,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _showMarketPickerModal,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(isDark ? 0.18 : 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Switch Market',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down_rounded,
                                  size: 16,
                                  color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        InkWell(
                          onTap: _showMarketStatusModal,
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                            child: PulsingBeacon(
                              color: AppColors.positive,
                              size: 7,
                              label: '$exchange • OPEN',
                              labelStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.positive,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Futuristic Responsive Image Banner with smooth gradient
                    OrientationBuilder(
                      builder: (context, orientation) {
                        final isLandscape = orientation == Orientation.landscape;
                        final bannerHeight = isLandscape ? 85.0 : 120.0;

                        return GestureDetector(
                          onTap: () => MainNavigationScreen.switchTab(context, 1),
                          child: Container(
                          height: bannerHeight,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/market_hero.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: AppColors.primary),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.85),
                                        Colors.black.withOpacity(0.35),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 18,
                                  top: isLandscape ? 14 : 22,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.positive,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '● QUANTITATIVE TELEMETRY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isLandscape ? 'Real-Time Financial Hub' : 'Global Market Terminal',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      if (!isLandscape) ...[
                                        const SizedBox(height: 3),
                                        const Text(
                                          'Live algorithmic quotes & historical volatility',
                                          style: TextStyle(
                                            color: Color(0xFFCBD5E1),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    ),

                    // Main Market Benchmark Card (Glassmorphic with subtle glow)
                    if (mainIndex != null) ...[
                      FuturisticGlassCard(
                        hasGlow: true,
                        glowColor: mainIndex.isPositive ? AppColors.positive : AppColors.negative,
                        onTap: () => _showIndexDetailModal(mainIndex),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        mainIndex.symbol,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      mainIndex.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                PriceBadge(
                                  changePercent: mainIndex.changePercent,
                                  changeAmount: mainIndex.change,
                                  showAmount: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _currencyService.currencySymbol,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                AnimatedTickerText(
                                  value: _currencyService.convertFromEur(mainIndex.price),
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  mainIndex.isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                  size: 18,
                                  color: mainIndex.isPositive ? AppColors.positive : AppColors.negative,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  mainIndex.isPositive ? 'Market momentum advancing' : 'Market momentum declining',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: mainIndex.isPositive ? AppColors.positive : AppColors.negative,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // Major Global Indices Horizontal Carousel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Global Indices',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Swipe for more',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 114,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _indices.length,
                        itemBuilder: (context, i) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 300 + (i * 100)),
                            curve: Curves.easeOutCubic,
                            builder: (context, val, child) {
                              return Opacity(
                                opacity: val,
                                child: Transform.translate(
                                  offset: Offset((1 - val) * 20, 0),
                                  child: child,
                                ),
                              );
                            },
                            child: MarketCard(
                              index: _indices[i],
                              onTap: () => _showIndexDetailModal(_indices[i]),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Top Movers Section with Staggered Entrance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Market Movers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        InkWell(
                          onTap: () => MainNavigationScreen.switchTab(context, 1),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._stocks.take(4).map((stk) => StockCard(
                          stock: stk,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.stockDetail,
                              arguments: stk.symbol,
                            );
                          },
                        )),
                    const SizedBox(height: 20),

                    // Real-Time Breaking Financial News
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Institutional Intelligence',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(isDark ? 0.2 : 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LIVE WIRE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._news.take(3).map((article) => NewsCard(article: article)),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: widget.showBottomNav
          ? FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: _onBottomNavTapped,
            )
          : null,
    );
  }
}
