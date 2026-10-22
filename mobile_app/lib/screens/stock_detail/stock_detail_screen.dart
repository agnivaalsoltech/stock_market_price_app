import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../models/stock.dart';
import '../../models/historical_point.dart';
import '../../models/news.dart';
import '../../services/currency_service.dart';
import '../../services/stock_api_service.dart';
import '../../services/portfolio_service.dart';
import '../../services/watchlist_service.dart';
import '../../widgets/price_badge.dart';
import '../../widgets/news_card.dart';
import '../../widgets/pulsing_beacon.dart';
import '../../widgets/animated_ticker_text.dart';
import '../../widgets/animated_theme_toggle.dart';
import '../../widgets/advanced_stock_chart.dart';

class StockDetailScreen extends StatefulWidget {
  final String? symbol;

  const StockDetailScreen({Key? key, this.symbol}) : super(key: key);

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final _apiService = StockApiService();
  final _currencyService = CurrencyService();
  final _portfolioService = PortfolioService();
  final _watchlistService = WatchlistService();

  String _currentSymbol = 'SAP';
  Stock? _stock;
  String _currentRange = '1D';
  List<HistoricalPoint> _chartPoints = [];
  List<HistoricalTableRow> _tableRows = [];
  List<NewsArticle> _news = [];
  bool _isLoading = true;

  // Interactive Chart State
  int? _scrubbedIndex;

  Map<String, dynamic> _calculatePeriodMetrics() {
    if (_chartPoints.isEmpty) {
      return {'high': 0.0, 'low': 0.0, 'avg': 0.0, 'volume': 0};
    }
    double high = _chartPoints.first.high;
    double low = _chartPoints.first.low;
    double sum = 0;
    int totalVol = 0;
    for (var p in _chartPoints) {
      if (p.high > high) high = p.high;
      if (p.low < low && p.low > 0) low = p.low;
      sum += p.close;
      totalVol += p.volume;
    }
    return {
      'high': high,
      'low': low,
      'avg': sum / _chartPoints.length,
      'volume': totalVol,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _currentSymbol = args;
    } else if (widget.symbol != null) {
      _currentSymbol = widget.symbol!;
    }
    _loadAllStockData();
  }

  Future<void> _loadAllStockData() async {
    setState(() => _isLoading = true);
    final stock = await _apiService.getStockDetail(_currentSymbol);
    final points = await _apiService.getHistoryPoints(_currentSymbol, _currentRange);
    final table = await _apiService.getHistoricalTable(_currentSymbol);
    final news = await _apiService.getNews(symbol: _currentSymbol);

    if (mounted) {
      setState(() {
        _stock = stock;
        _chartPoints = points;
        _tableRows = table;
        _news = news;
        _isLoading = false;
        _scrubbedIndex = null;
      });
    }
  }

  Future<void> _changeRange(String range) async {
    setState(() {
      _currentRange = range;
      _scrubbedIndex = null;
    });
    final points = await _apiService.getHistoryPoints(_currentSymbol, range);
    if (mounted) {
      setState(() => _chartPoints = points);
    }
  }

  void _openFullscreenChart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: AppColors.isDark(ctx) ? AppColors.darkBg : AppColors.lightBg,
          appBar: AppBar(
            backgroundColor: AppColors.isDark(ctx) ? AppColors.darkCard : AppColors.lightCard,
            title: Text(
              '${_stock?.symbol ?? _currentSymbol} Fullscreen Workstation',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
          body: SafeArea(
            child: AdvancedStockChart(
              points: _chartPoints,
              symbol: _stock?.symbol ?? _currentSymbol,
              currentRange: _currentRange,
              onRangeChanged: (r) {
                _changeRange(r);
              },
              isFullscreen: true,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openWebDetail() async {
    final url = ApiConstants.webStockDetailUrl(_currentSymbol);
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Target URL: $url (Run PHP server on port 8000 to view on Web)')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch: $url')),
      );
    }
  }

  void _showAddHoldingDialog() {
    if (_stock == null) return;
    final qtyController = TextEditingController(text: '10');
    final isDark = AppColors.isDark(context);

    showDialog(
      context: context,
      builder: (ctx) {
        int qty = 10;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final estCost = _currencyService.format(_stock!.price * qty);
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              title: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.secondary, size: 24),
                  const SizedBox(width: 8),
                  Text('Execute Order (${_stock!.symbol})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_stock!.companyName} • ${_currencyService.format(_stock!.price)} / share',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    onChanged: (val) {
                      setDialogState(() {
                        qty = int.tryParse(val.trim()) ?? 0;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Number of Shares to Buy',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimated Cost:', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        Text(
                          estCost,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: qty > 0 ? () {
                    _portfolioService.addHolding(_stock!.symbol, qty, _stock!.price);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully bought $qty shares of ${_stock!.symbol} for $estCost!'),
                        backgroundColor: AppColors.positive,
                      ),
                    );
                  } : null,
                  child: const Text('Confirm Trade'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPriceAlertModal() {
    if (_stock == null) return;
    final isDark = AppColors.isDark(context);
    final targetController = TextEditingController(text: (_stock!.price * 1.05).toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: AppColors.secondaryLight, size: 22),
            const SizedBox(width: 8),
            Text('Price Alert (${_stock!.symbol})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: ${_currencyService.format(_stock!.price)}',
              style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: targetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Target Price (${_currencyService.currencySymbol})',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.trending_up_rounded),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We will notify you instantly when the market reaches this threshold.',
              style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Alert set: Notify when ${_stock!.symbol} reaches ${_currencyService.currencySymbol}${targetController.text}!'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            child: const Text('Set Alert'),
          ),
        ],
      ),
    );
  }

  void _showMetricExplanationDialog(String label, String value) {
    final isDark = AppColors.isDark(context);
    String desc = 'Real-time telemetry metric calculated from active market feeds.';
    switch (label) {
      case 'Open':
        desc = 'The price at which ${_stock!.symbol} executed its first auction match at the start of today\'s trading session.';
        break;
      case 'Previous Close':
        desc = 'The official settlement price recorded at the final bell of the preceding regular market trading day.';
        break;
      case 'Day High':
        desc = 'The absolute highest trade price recorded during today\'s continuous intraday session.';
        break;
      case 'Day Low':
        desc = 'The absolute lowest execution price touched during today\'s intraday trading range.';
        break;
      case 'Market Cap':
        desc = 'Total market valuation of ${_stock!.companyName}, determined by multiplying total outstanding shares by current stock price.';
        break;
      case 'P/E Ratio':
        desc = 'Price-to-Earnings valuation multiple comparing current market share price against company earnings per share (EPS).';
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text('$label: $value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              desc,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ticker: ${_stock!.symbol} • Verified Feed',
              style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(String label, String value, BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showMetricExplanationDialog(label, value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodPill(String label, String value, Color valueColor, BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: valueColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 24,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  String _formatCompactVolume(int volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(0)}K';
    }
    return volume.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    if (_isLoading || _stock == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_currentSymbol)),
        body: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.secondaryLight,
          ),
        ),
      );
    }

    final stock = _stock!;

    // Interactive Scrubbing & Period Telemetry
    final scrubbedPoint = (_scrubbedIndex != null && _scrubbedIndex! < _chartPoints.length)
        ? _chartPoints[_scrubbedIndex!]
        : null;
    final displayPrice = scrubbedPoint != null ? scrubbedPoint.close : stock.price;
    final baselinePrice = _chartPoints.isNotEmpty ? _chartPoints.first.close : stock.previousClose;
    final displayDiff = scrubbedPoint != null ? (scrubbedPoint.close - baselinePrice) : stock.change;
    final displayPct = scrubbedPoint != null
        ? (baselinePrice != 0 ? (displayDiff / baselinePrice) * 100 : 0.0)
        : stock.changePercent;
    final periodMetrics = _calculatePeriodMetrics();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          stock.symbol,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          const AnimatedThemeToggle(),
          IconButton(
            icon: Icon(
              _watchlistService.isWatched(stock.symbol) ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _watchlistService.isWatched(stock.symbol) ? Colors.amber : (isDark ? Colors.white : AppColors.primary),
            ),
            tooltip: 'Toggle Watchlist',
            onPressed: () {
              setState(() {
                _watchlistService.toggle(stock.symbol);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _watchlistService.isWatched(stock.symbol)
                        ? '${stock.symbol} added to Watchlist'
                        : '${stock.symbol} removed from Watchlist',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_chart_rounded),
            tooltip: 'Add to Portfolio',
            onPressed: _showAddHoldingDialog,
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen_rounded),
            tooltip: 'Fullscreen Workstation',
            onPressed: _openFullscreenChart,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: 'View on Web',
            onPressed: _openWebDetail,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header & Market Status / Scrub Reset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.companyName,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${stock.exchange} • ${stock.country} • ${stock.sector}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (scrubbedPoint != null)
                  GestureDetector(
                    onTap: () => setState(() => _scrubbedIndex = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, size: 13, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            '${scrubbedPoint.date} • Reset',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const PulsingBeacon(
                    color: AppColors.positive,
                    size: 6.5,
                    label: 'OPEN',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Real-Time / Scrubbed Animated Price Hero Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _currencyService.currencySymbol,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 2),
                if (scrubbedPoint != null)
                  Text(
                    _currencyService.convertFromEur(displayPrice).toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      letterSpacing: -1.2,
                    ),
                  )
                else
                  AnimatedTickerText(
                    value: _currencyService.convertFromEur(displayPrice),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      letterSpacing: -1.2,
                    ),
                  ),
                const SizedBox(width: 12),
                PriceBadge(
                  changePercent: displayPct,
                  changeAmount: displayDiff,
                  showAmount: true,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Advanced TradingView / Groww / Upstox Style Technical Chart Workstation
            AdvancedStockChart(
              points: _chartPoints,
              symbol: _stock?.symbol ?? _currentSymbol,
              currentRange: _currentRange,
              onRangeChanged: _changeRange,
              onToggleFullscreen: _openFullscreenChart,
              isFullscreen: false,
            ),
            const SizedBox(height: 12),

            // Period Metrics Dashboard Pills (High, Low, Period Avg, Volume)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPeriodPill('High', _currencyService.format(periodMetrics['high'] as double), AppColors.positive, context),
                  _buildDivider(isDark),
                  _buildPeriodPill('Low', _currencyService.format(periodMetrics['low'] as double), AppColors.negative, context),
                  _buildDivider(isDark),
                  _buildPeriodPill('Period Avg', _currencyService.format(periodMetrics['avg'] as double), AppColors.secondary, context),
                  _buildDivider(isDark),
                  _buildPeriodPill('Volume', _formatCompactVolume(periodMetrics['volume'] as int), isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, context),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions Bar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddHoldingDialog,
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: const Text('Trade / Buy'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _showPriceAlertModal,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                  ),
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text('Alert'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _openWebDetail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                  ),
                  icon: const Icon(Icons.language_rounded, size: 18),
                  label: const Text('Web'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2x3 Bento Grid: Key Statistics
            Text(
              'Key Financial Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildBentoCard('Open', _currencyService.format(stock.open), context),
                _buildBentoCard('Previous Close', _currencyService.format(stock.previousClose), context),
                _buildBentoCard('Day High', _currencyService.format(stock.high), context),
                _buildBentoCard('Day Low', _currencyService.format(stock.low), context),
                _buildBentoCard('Market Cap', stock.marketCap, context),
                _buildBentoCard('P/E Ratio', '${stock.peRatio.toStringAsFixed(1)}x', context),
              ],
            ),
            const SizedBox(height: 24),

            // 5-Day Historical Price Data Table
            Text(
              '5-Day Trading History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  horizontalMargin: 16,
                  columnSpacing: 18,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                  ),
                  dataTextStyle: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Open')),
                    DataColumn(label: Text('High')),
                    DataColumn(label: Text('Low')),
                    DataColumn(label: Text('Close')),
                    DataColumn(label: Text('Volume')),
                  ],
                  rows: _tableRows.map((row) {
                    return DataRow(
                      onSelectChanged: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${row.date} • High: ${_currencyService.format(row.high)} • Low: ${_currencyService.format(row.low)} • Vol: ${row.volume}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      cells: [
                        DataCell(Text(row.date, style: const TextStyle(fontWeight: FontWeight.w700))),
                        DataCell(Text(row.open.toStringAsFixed(2))),
                        DataCell(Text(row.high.toStringAsFixed(2))),
                        DataCell(Text(row.low.toStringAsFixed(2))),
                        DataCell(Text(row.close.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w700))),
                        DataCell(Text(row.volume)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Related Financial Intelligence
            Text(
              'Related Intelligence',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            if (_news.isEmpty)
              Text(
                'No recent articles for this equity.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              )
            else
              ..._news.map((n) => NewsCard(article: n)),
          ],
        ),
      ),
    );
  }
}
