import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../models/stock.dart';
import '../../services/portfolio_service.dart';
import '../../services/stock_api_service.dart';
import '../../services/currency_service.dart';
import '../../widgets/animated_theme_toggle.dart';
import '../../widgets/animated_ticker_text.dart';
import '../../widgets/futuristic_glass_card.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _portfolioService = PortfolioService();
  final _apiService = StockApiService();
  final _currencyService = CurrencyService();

  Map<String, Stock> _quotes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _portfolioService.addListener(_onPortfolioChanged);
    _currencyService.addListener(_onPortfolioChanged);
    _loadPrices();
  }

  @override
  void dispose() {
    _portfolioService.removeListener(_onPortfolioChanged);
    _currencyService.removeListener(_onPortfolioChanged);
    super.dispose();
  }

  void _onPortfolioChanged() {
    if (mounted) _loadPrices();
  }

  Future<void> _loadPrices() async {
    setState(() => _isLoading = true);
    final items = _portfolioService.items;
    final map = <String, Stock>{};

    for (final item in items) {
      final stock = await _apiService.getStockDetail(item.symbol);
      map[item.symbol] = stock;
    }

    if (mounted) {
      setState(() {
        _quotes = map;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshQuotes() async => _loadPrices();

  void _showPortfolioSummaryModal(double totalVal, double investedVal, double pl, double plPct) {
    final isDark = AppColors.isDark(context);
    final isPos = pl >= 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Portfolio Performance Audit',
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Valuation:', style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        Text(_currencyService.format(totalVal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cumulative Invested:', style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        Text(_currencyService.format(investedVal), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Profit / Loss:', style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        Text(
                          '${isPos ? '+' : ''}${_currencyService.format(pl)} (${isPos ? '+' : ''}${plPct.toStringAsFixed(2)}%)',
                          style: TextStyle(fontWeight: FontWeight.w800, color: isPos ? AppColors.positive : AppColors.negative),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showAddHoldingDialog();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Another Equity Position'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTradeHoldingDialog(dynamic item) {
    final qtyController = TextEditingController(text: '5');
    final isDark = AppColors.isDark(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text('Buy More ${item.symbol}', style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: ${item.quantity} shares @ ${_currencyService.format(item.purchasePrice)} avg',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Additional Shares to Buy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_shopping_cart_rounded),
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
            onPressed: () {
              final addQty = int.tryParse(qtyController.text.trim()) ?? 5;
              if (addQty > 0) {
                final currentPrice = _quotes[item.symbol]?.price ?? item.purchasePrice;
                _portfolioService.addHolding(item.symbol, addQty, currentPrice);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchased $addQty more shares of ${item.symbol}!'),
                    backgroundColor: AppColors.positive,
                  ),
                );
              }
            },
            child: const Text('Execute Trade'),
          ),
        ],
      ),
    );
  }

  void _showAddHoldingDialog() {
    final symbolController = TextEditingController(text: 'SAP');
    final qtyController = TextEditingController(text: '10');
    final priceController = TextEditingController(text: '195.00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Investment Position', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: symbolController,
              decoration: const InputDecoration(labelText: 'Stock Symbol (e.g. SAP, BMW, SIE)'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity (shares)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Purchase Price (€ EUR)'),
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
              final symbol = symbolController.text.trim().toUpperCase();
              final qty = int.tryParse(qtyController.text) ?? 1;
              final price = double.tryParse(priceController.text) ?? 100.0;

              _portfolioService.addHolding(symbol, qty, price);
              Navigator.pop(ctx);
            },
            child: const Text('Save Position'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _portfolioService.items;
    final isDark = AppColors.isDark(context);

    // Calculate totals
    double totalPortfolioValue = 0;
    double totalInvestedValue = 0;

    for (final item in items) {
      final quote = _quotes[item.symbol];
      final currentPrice = quote?.price ?? item.purchasePrice;
      totalPortfolioValue += item.calculateCurrentValue(currentPrice);
      totalInvestedValue += item.investedValue;
    }

    final totalProfitLoss = totalPortfolioValue - totalInvestedValue;
    final totalProfitLossPercent = totalInvestedValue > 0 ? (totalProfitLoss / totalInvestedValue) * 100 : 0.0;
    final isOverallPositive = totalProfitLoss >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Institutional Portfolio'),
        actions: [
          const AnimatedThemeToggle(),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset Demo Holdings',
            onPressed: () async {
              await _portfolioService.resetToDemo();
              await _refreshQuotes();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Portfolio reset to default demo positions')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Investment',
            onPressed: _showAddHoldingDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.secondaryLight,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Holographic Net Worth Hero Card
                  FuturisticGlassCard(
                    hasGlow: true,
                    glowColor: isOverallPositive ? AppColors.positive : AppColors.negative,
                    onTap: () => _showPortfolioSummaryModal(
                      totalPortfolioValue,
                      totalInvestedValue,
                      totalProfitLoss,
                      totalProfitLossPercent,
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL ASSET VALUATION',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isOverallPositive ? AppColors.positive : AppColors.negative).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: (isOverallPositive ? AppColors.positive : AppColors.negative).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${isOverallPositive ? '+' : ''}${totalProfitLossPercent.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: isOverallPositive ? AppColors.positive : AppColors.negative,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _currencyService.currencySymbol,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedTickerText(
                              value: _currencyService.convertFromEur(totalPortfolioValue),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                letterSpacing: -1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(
                              isOverallPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              size: 15,
                              color: isOverallPositive ? AppColors.positive : AppColors.negative,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Total P/L: ${isOverallPositive ? '+' : ''}${_currencyService.format(totalProfitLoss)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isOverallPositive ? AppColors.positive : AppColors.negative,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Cost Basis: ${_currencyService.format(totalInvestedValue)}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Asset Allocation Breakdown (Visual Segmented Bar)
                  if (items.isNotEmpty && totalPortfolioValue > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Asset Distribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${items.length} Equities',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: items.asMap().entries.map((e) {
                            final idx = e.key;
                            final item = e.value;
                            final quote = _quotes[item.symbol];
                            final val = item.calculateCurrentValue(quote?.price ?? item.purchasePrice);
                            final fraction = (val / totalPortfolioValue).clamp(0.01, 1.0);
                            final colors = [
                              AppColors.secondary,
                              AppColors.positive,
                              const Color(0xFF8B5CF6),
                              AppColors.warning,
                              const Color(0xFFEC4899),
                            ];
                            return Expanded(
                              flex: (fraction * 100).toInt(),
                              child: Container(color: colors[idx % colors.length]),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: items.asMap().entries.map((e) {
                        final idx = e.key;
                        final item = e.value;
                        final quote = _quotes[item.symbol];
                        final val = item.calculateCurrentValue(quote?.price ?? item.purchasePrice);
                        final pct = totalPortfolioValue > 0 ? (val / totalPortfolioValue) * 100 : 0.0;
                        final colors = [
                          AppColors.secondary,
                          AppColors.positive,
                          const Color(0xFF8B5CF6),
                          AppColors.warning,
                          const Color(0xFFEC4899),
                        ];
                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.stockDetail,
                              arguments: item.symbol,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(radius: 4, backgroundColor: colors[idx % colors.length]),
                                const SizedBox(width: 5),
                                Text(
                                  '${item.symbol} (${pct.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Holdings List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tracked Holdings (${items.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              await _portfolioService.resetToDemo();
                              await _refreshQuotes();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reset to demo positions')),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: _showAddHoldingDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(isDark ? 0.2 : 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+ Add Position',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (items.isEmpty)
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
                            Icons.pie_chart_outline_rounded,
                            size: 44,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Holdings Tracked Yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + Add Position to begin tracking your portfolio',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...items.map((item) {
                      final quote = _quotes[item.symbol];
                      final currentPrice = quote?.price ?? item.purchasePrice;
                      final currentValue = item.calculateCurrentValue(currentPrice);
                      final profitLoss = item.calculateProfitLoss(currentPrice);
                      final profitLossPercent = item.calculateProfitLossPercent(currentPrice);
                      final isPos = profitLoss >= 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.stockDetail,
                                arguments: item.symbol,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary.withOpacity(isDark ? 0.2 : 0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.symbol,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                                color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '${item.quantity} shares',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.add_shopping_cart_rounded, size: 19, color: AppColors.secondaryLight),
                                            onPressed: () => _showTradeHoldingDialog(item),
                                            tooltip: 'Buy More Shares',
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close_rounded, size: 18, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                            onPressed: () => _portfolioService.removeHolding(item.id),
                                            tooltip: 'Remove Position',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Market Value',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _currencyService.format(currentValue),
                                            style: TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Unrealized Return',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${isPos ? '+' : ''}${_currencyService.format(profitLoss)} (${isPos ? '+' : ''}${profitLossPercent.toStringAsFixed(2)}%)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: isPos ? AppColors.positive : AppColors.negative,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
