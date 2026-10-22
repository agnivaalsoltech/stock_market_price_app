import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/stock.dart';
import '../../models/market_index.dart';
import '../../services/location_service.dart';
import '../../services/currency_service.dart';
import '../../services/stock_api_service.dart';
import '../../services/watchlist_service.dart';
import '../../widgets/stock_card.dart';
import '../../widgets/market_card.dart';
import '../../widgets/pulsing_beacon.dart';
import '../../widgets/animated_theme_toggle.dart';
import '../../widgets/price_badge.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({Key? key}) : super(key: key);

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  final _apiService = StockApiService();
  final _locationService = LocationService();
  final _currencyService = CurrencyService();
  final _watchlistService = WatchlistService();
  final _searchController = TextEditingController();

  List<MarketIndex> _indices = [];
  List<Stock> _allStocks = [];
  List<Stock> _filteredStocks = [];
  bool _isLoading = true;
  String _activeFilter = 'all'; // 'all', 'watchlist', 'gainers', 'losers'

  @override
  void initState() {
    super.initState();
    _locationService.addListener(_onStateChange);
    _currencyService.addListener(_onStateChange);
    _watchlistService.addListener(_onStateChange);
    _loadMarketData();
  }

  @override
  void dispose() {
    _locationService.removeListener(_onStateChange);
    _currencyService.removeListener(_onStateChange);
    _watchlistService.removeListener(_onStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadMarketData() async {
    setState(() => _isLoading = true);
    final country = _locationService.currentCountry;
    
    final indices = await _apiService.getIndicesForCountry(country);
    final stocks = await _apiService.getStocksForCountry(country);

    if (mounted) {
      setState(() {
        _indices = indices;
        _allStocks = stocks;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredStocks = _allStocks.where((s) {
        final matchesSearch = q.isEmpty ||
            s.symbol.toLowerCase().contains(q) ||
            s.companyName.toLowerCase().contains(q) ||
            s.sector.toLowerCase().contains(q);

        bool matchesFilter = true;
        if (_activeFilter == 'watchlist') {
          matchesFilter = _watchlistService.isWatched(s.symbol);
        } else if (_activeFilter == 'gainers') {
          matchesFilter = s.changePercent >= 0;
        } else if (_activeFilter == 'losers') {
          matchesFilter = s.changePercent < 0;
        }

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Widget _buildFilterChip(String key, String label, {IconData? icon}) {
    final isSelected = _activeFilter == key;
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: () {
        setState(() => _activeFilter = key);
        _applyFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.secondary : AppColors.secondary)
              : (isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.secondaryLight
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
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
                        Text('BENCHMARK QUOTE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
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
              _buildDetailRow('Index Sentiment', isPos ? 'Advancing / Bullish momentum' : 'Declining / Bearish pressure', isDark),
              _buildDetailRow('Exchange Hub', '$country (${_locationService.currentExchange})', isDark),
              _buildDetailRow('Weighting Matrix', 'Real-time Capitalization Index', isDark),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _activeFilter = 'all');
                    _searchController.clear();
                    _applyFilters();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset All Equity Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
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
    final isDark = AppColors.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets & Telemetry'),
        actions: [
          const AnimatedThemeToggle(),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Settings & Backend',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.secondaryLight,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMarketData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country Switcher & Market Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                            value: _locationService.currentCountry,
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.secondaryLight),
                            items: LocationService.countryMetadata.keys.map((c) {
                              final flag = LocationService.countryMetadata[c]!['flag']!;
                              return DropdownMenuItem<String>(
                                value: c,
                                child: Text(
                                  '$flag $c Exchange',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _locationService.setCountry(val);
                                _loadMarketData();
                              }
                            },
                          ),
                        ),
                        const PulsingBeacon(
                          color: AppColors.positive,
                          size: 6.5,
                          label: 'LIVE',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Modern Glowing Search Input
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyFilters(),
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search ticker, company or sector...',
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _applyFilters();
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Pill Badges Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'All Equities (${_allStocks.length})'),
                          const SizedBox(width: 8),
                          _buildFilterChip('watchlist', 'Watchlist', icon: Icons.star_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('gainers', 'Gainers', icon: Icons.trending_up_rounded),
                          const SizedBox(width: 8),
                          _buildFilterChip('losers', 'Losers', icon: Icons.trending_down_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Exchange Indices Horizontal Carousel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exchange Indices',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Real-time',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 114,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _indices.length,
                        itemBuilder: (context, i) {
                          final idx = _indices[i];
                          return MarketCard(
                            index: idx,
                            onTap: () => _showIndexDetailModal(idx),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Market Breadth Mini Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.candlestick_chart_rounded, size: 16, color: AppColors.secondaryLight),
                          const SizedBox(width: 8),
                          Text(
                            'Market Breadth:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() => _activeFilter = 'gainers');
                              _applyFilters();
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _activeFilter == 'gainers' ? AppColors.positive.withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _activeFilter == 'gainers' ? AppColors.positive : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_allStocks.where((s) => s.changePercent >= 0).length} Advancing',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.positive),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_up_rounded, size: 16, color: AppColors.positive),
                                ],
                              ),
                            ),
                          ),
                          const Text('  •  ', style: TextStyle(color: Colors.grey)),
                          InkWell(
                            onTap: () {
                              setState(() => _activeFilter = 'losers');
                              _applyFilters();
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _activeFilter == 'losers' ? AppColors.negative.withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _activeFilter == 'losers' ? AppColors.negative : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_allStocks.where((s) => s.changePercent < 0).length} Declining',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.negative),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.negative),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Listed Equities Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Equities (${_filteredStocks.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Tap row for charts',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Listed Equities
                    if (_filteredStocks.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _activeFilter == 'watchlist'
                                  ? 'Your Watchlist is empty'
                                  : 'No equities matching filter',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeFilter == 'watchlist'
                                  ? 'Star any stock to follow its performance'
                                  : 'Try adjusting your search keywords',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._filteredStocks.map((stk) => StockCard(
                            stock: stk,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.stockDetail,
                                arguments: stk.symbol,
                              );
                            },
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}
