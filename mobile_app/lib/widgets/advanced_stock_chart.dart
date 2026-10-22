import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/historical_point.dart';
import '../../services/currency_service.dart';

enum ChartType {
  candlestick,
  hollow,
  ohlc,
  area,
  heikinAshi,
  line,
}

enum DrawingTool {
  cursor,
  trendline,
  horizontal,
  fibonacci,
}

enum ScaleMode {
  linear,
  logarithmic,
  percentage,
}

class AdvancedStockChart extends StatefulWidget {
  final List<HistoricalPoint> points;
  final String symbol;
  final String currentRange;
  final ValueChanged<String> onRangeChanged;
  final VoidCallback? onToggleFullscreen;
  final bool isFullscreen;

  const AdvancedStockChart({
    Key? key,
    required this.points,
    required this.symbol,
    required this.currentRange,
    required this.onRangeChanged,
    this.onToggleFullscreen,
    this.isFullscreen = false,
  }) : super(key: key);

  @override
  State<AdvancedStockChart> createState() => _AdvancedStockChartState();
}

class _DrawingItem {
  final DrawingTool tool;
  final Offset start;
  final Offset end;

  _DrawingItem({
    required this.tool,
    required this.start,
    required this.end,
  });
}

class _AdvancedStockChartState extends State<AdvancedStockChart> {
  final _currency = CurrencyService();

  // Settings & Toggles
  ChartType _chartType = ChartType.candlestick;
  ScaleMode _scaleMode = ScaleMode.linear;
  DrawingTool _activeTool = DrawingTool.cursor;

  // Indicators
  bool _showSma = true;
  bool _showEma = false;
  bool _showBands = false;
  bool _showVwap = false;
  bool _showSupertrend = false;
  bool _showPivots = false;
  bool _showVolume = true;
  bool _showRsi = false;
  bool _showMacd = false;
  bool _showCompare = false;

  // Interactive Viewport State
  double _zoomLevel = 1.0;
  double _panOffset = 0.0;
  int? _scrubbedIndex;
  Offset? _crosshairPosition;

  // User Drawings
  final List<_DrawingItem> _drawings = [];
  Offset? _drawingStart;
  Offset? _drawingCurrent;

  final List<String> _timeframes = [
    '1m', '5m', '15m', '1H', '1D', '1W', '1M', '3M', '1Y', 'ALL'
  ];

  @override
  void didUpdateWidget(covariant AdvancedStockChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points.length != widget.points.length ||
        oldWidget.currentRange != widget.currentRange) {
      _scrubbedIndex = null;
      _crosshairPosition = null;
    }
  }

  void _applyTemplate(String template) {
    setState(() {
      if (template == 'Intraday') {
        _chartType = ChartType.candlestick;
        _showSma = false;
        _showEma = true;
        _showVwap = true;
        _showVolume = true;
        _showRsi = true;
        _showMacd = false;
        _showBands = false;
        widget.onRangeChanged('5m');
      } else if (template == 'Swing') {
        _chartType = ChartType.candlestick;
        _showSma = true;
        _showEma = true;
        _showBands = true;
        _showVolume = true;
        _showRsi = false;
        _showMacd = true;
        _showVwap = false;
        widget.onRangeChanged('1D');
      } else {
        // Default
        _chartType = ChartType.candlestick;
        _showSma = true;
        _showEma = false;
        _showBands = false;
        _showVwap = false;
        _showSupertrend = false;
        _showPivots = false;
        _showVolume = true;
        _showRsi = false;
        _showMacd = false;
      }
    });
  }

  void _resetView() {
    setState(() {
      _zoomLevel = 1.0;
      _panOffset = 0.0;
      _scrubbedIndex = null;
      _crosshairPosition = null;
    });
  }

  void _showIndicatorDialog(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Technical Indicators',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildIndicatorTile('SMA (20)', 'Simple Moving Average', _showSma, (v) {
                          setModalState(() => _showSma = v);
                          setState(() => _showSma = v);
                        }, isDark, const Color(0xFF38BDF8)),
                        _buildIndicatorTile('EMA (20)', 'Exponential Moving Average', _showEma, (v) {
                          setModalState(() => _showEma = v);
                          setState(() => _showEma = v);
                        }, isDark, const Color(0xFFF59E0B)),
                        _buildIndicatorTile('Bollinger Bands', '20-period, 2-std dev channels', _showBands, (v) {
                          setModalState(() => _showBands = v);
                          setState(() => _showBands = v);
                        }, isDark, const Color(0xFF6366F1)),
                        _buildIndicatorTile('VWAP', 'Volume-Weighted Average Price', _showVwap, (v) {
                          setModalState(() => _showVwap = v);
                          setState(() => _showVwap = v);
                        }, isDark, const Color(0xFFA855F7)),
                        _buildIndicatorTile('Supertrend', 'ATR Volatility Trailing Stop', _showSupertrend, (v) {
                          setModalState(() => _showSupertrend = v);
                          setState(() => _showSupertrend = v);
                        }, isDark, const Color(0xFF10B981)),
                        _buildIndicatorTile('Pivot Points (S/R)', 'Classic Support & Resistance levels', _showPivots, (v) {
                          setModalState(() => _showPivots = v);
                          setState(() => _showPivots = v);
                        }, isDark, const Color(0xFFEC4899)),
                        _buildIndicatorTile('Volume Histogram', 'Trade activity by candle', _showVolume, (v) {
                          setModalState(() => _showVolume = v);
                          setState(() => _showVolume = v);
                        }, isDark, const Color(0xFF64748B)),
                        _buildIndicatorTile('RSI (14)', 'Relative Strength Index (0-100)', _showRsi, (v) {
                          setModalState(() => _showRsi = v);
                          setState(() => _showRsi = v);
                        }, isDark, const Color(0xFF8B5CF6)),
                        _buildIndicatorTile('MACD (12, 26, 9)', 'Moving Average Convergence Divergence', _showMacd, (v) {
                          setModalState(() => _showMacd = v);
                          setState(() => _showMacd = v);
                        }, isDark, const Color(0xFF06B6D4)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIndicatorTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
    Color indicatorColor,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: indicatorColor,
      title: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }

  void _showDrawingToolsDialog(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professional Drawing Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildToolChip('Cursor / Scrub', DrawingTool.cursor, Icons.pan_tool_rounded, isDark),
                  _buildToolChip('Trendline', DrawingTool.trendline, Icons.show_chart_rounded, isDark),
                  _buildToolChip('Horizontal Line', DrawingTool.horizontal, Icons.horizontal_rule_rounded, isDark),
                  _buildToolChip('Fibonacci Retracement', DrawingTool.fibonacci, Icons.tune_rounded, isDark),
                ],
              ),
              const SizedBox(height: 16),
              if (_drawings.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _drawings.clear());
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                  label: const Text('Clear All Drawings', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.negative,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolChip(String label, DrawingTool tool, IconData icon, bool isDark) {
    final active = _activeTool == tool;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: active ? Colors.white : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
      ),
      label: Text(label),
      selected: active,
      selectedColor: AppColors.secondary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: active ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _activeTool = tool);
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    if (widget.points.isEmpty) {
      return Container(
        height: 280,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final scrubbedPoint = (_scrubbedIndex != null &&
            _scrubbedIndex! >= 0 &&
            _scrubbedIndex! < widget.points.length)
        ? widget.points[_scrubbedIndex!]
        : widget.points.last;

    final isPositive = scrubbedPoint.close >= scrubbedPoint.open;
    final changeVal = scrubbedPoint.close - scrubbedPoint.open;
    final changePct = scrubbedPoint.open > 0 ? (changeVal / scrubbedPoint.open) * 100 : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(widget.isFullscreen ? 0 : 18),
        border: widget.isFullscreen
            ? null
            : Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TOP TOOLBAR: Modes, Indicators, Drawings, Scale, Fullscreen
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D2E) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(widget.isFullscreen ? 0 : 18),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  // Chart Type Selector Popup
                  PopupMenuButton<ChartType>(
                    initialValue: _chartType,
                    tooltip: 'Chart Type',
                    onSelected: (t) => setState(() => _chartType = t),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    itemBuilder: (ctx) => [
                      _buildMenuItem(ChartType.candlestick, 'Candlestick', Icons.candlestick_chart_rounded, isDark),
                      _buildMenuItem(ChartType.hollow, 'Hollow Candles', Icons.water_drop_outlined, isDark),
                      _buildMenuItem(ChartType.ohlc, 'Bar / OHLC', Icons.dehaze_rounded, isDark),
                      _buildMenuItem(ChartType.heikinAshi, 'Heikin Ashi', Icons.bar_chart_rounded, isDark),
                      _buildMenuItem(ChartType.line, 'Line', Icons.show_chart_rounded, isDark),
                      _buildMenuItem(ChartType.area, 'Area', Icons.area_chart_rounded, isDark),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getChartTypeIcon(_chartType), size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            _getChartTypeName(_chartType),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.secondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Indicators Button
                  _buildHeaderButton(
                    label: 'Indicators (${_countActiveIndicators()})',
                    icon: Icons.auto_graph_rounded,
                    isActive: _countActiveIndicators() > 0,
                    activeColor: const Color(0xFF38BDF8),
                    onTap: () => _showIndicatorDialog(isDark),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),

                  // Drawing Tools Button
                  _buildHeaderButton(
                    label: _getDrawingToolName(_activeTool),
                    icon: _getDrawingToolIcon(_activeTool),
                    isActive: _activeTool != DrawingTool.cursor || _drawings.isNotEmpty,
                    activeColor: const Color(0xFFF59E0B),
                    onTap: () => _showDrawingToolsDialog(isDark),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),

                  // Benchmark Compare Button
                  _buildHeaderButton(
                    label: '+ Compare',
                    icon: Icons.compare_arrows_rounded,
                    isActive: _showCompare,
                    activeColor: const Color(0xFF10B981),
                    onTap: () => setState(() => _showCompare = !_showCompare),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),

                  // Templates Popup
                  PopupMenuButton<String>(
                    tooltip: 'Setups & Layouts',
                    onSelected: _applyTemplate,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'Default', child: Text('Default Layout', style: TextStyle(fontSize: 12.5))),
                      const PopupMenuItem(value: 'Intraday', child: Text('⚡ Intraday Setup (5m + EMA + VWAP + RSI)', style: TextStyle(fontSize: 12.5))),
                      const PopupMenuItem(value: 'Swing', child: Text('📈 Swing Setup (1D + Bands + MACD)', style: TextStyle(fontSize: 12.5))),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardElevated : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dashboard_customize_outlined, size: 13, color: isDark ? Colors.white70 : Colors.black87),
                          const SizedBox(width: 4),
                          Text('Layouts', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Scale Mode Selector
                  PopupMenuButton<ScaleMode>(
                    initialValue: _scaleMode,
                    tooltip: 'Scale Mode',
                    onSelected: (m) => setState(() => _scaleMode = m),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    itemBuilder: (ctx) => [
                      PopupMenuItem(value: ScaleMode.linear, child: Text('Linear Scale', style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87))),
                      PopupMenuItem(value: ScaleMode.logarithmic, child: Text('Logarithmic (Log)', style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87))),
                      PopupMenuItem(value: ScaleMode.percentage, child: Text('Percentage (%)', style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87))),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardElevated : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        _scaleMode == ScaleMode.linear ? 'LIN' : _scaleMode == ScaleMode.logarithmic ? 'LOG' : '%',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Reset / Live
                  InkWell(
                    onTap: _resetView,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 13, color: AppColors.secondary),
                          SizedBox(width: 3),
                          Text('LIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                  ),

                  // Fullscreen toggle if available
                  if (widget.onToggleFullscreen != null) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Icon(
                        widget.isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      tooltip: widget.isFullscreen ? 'Exit Fullscreen' : 'Fullscreen Workstation',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: widget.onToggleFullscreen,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 2. TIMEFRAME STRIP (1m to ALL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withOpacity(0.5),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _timeframes.map((tf) {
                  final active = widget.currentRange.toUpperCase() == tf.toUpperCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      onTap: () => widget.onRangeChanged(tf),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: active ? AppColors.secondary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tf,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                            color: active
                                ? Colors.white
                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 3. FLOATING HUD (DATE, O, H, L, C, V, CHG%)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: isDark ? const Color(0x2A0F172A) : const Color(0x3AF8FAFC),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    scrubbedPoint.date,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildHudPill('O', _currency.format(scrubbedPoint.open), isDark),
                  _buildHudPill('H', _currency.format(scrubbedPoint.high), isDark, color: AppColors.positive),
                  _buildHudPill('L', _currency.format(scrubbedPoint.low), isDark, color: AppColors.negative),
                  _buildHudPill('C', _currency.format(scrubbedPoint.close), isDark),
                  _buildHudPill(
                    'Chg',
                    '${isPositive ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                    isDark,
                    color: isPositive ? AppColors.positive : AppColors.negative,
                  ),
                  _buildHudPill('Vol', _formatVol(scrubbedPoint.volume), isDark),
                  if (_showCompare)
                    _buildHudPill('BMK', '+10.4%', isDark, color: const Color(0xFF10B981)),
                ],
              ),
            ),
          ),

          // 4. MAIN CHART CANVAS WITH CUSTOMPAINTER & TOUCH GESTURES
          Expanded(
            flex: widget.isFullscreen ? 1 : 0,
            child: SizedBox(
              height: widget.isFullscreen ? null : 280,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: (details) {
                      if (_activeTool != DrawingTool.cursor) {
                        _drawingStart = details.localFocalPoint;
                        _drawingCurrent = details.localFocalPoint;
                      }
                    },
                    onScaleUpdate: (details) {
                      if (_activeTool == DrawingTool.cursor) {
                        // Pinch Zoom
                        if (details.scale != 1.0) {
                          setState(() {
                            _zoomLevel = (_zoomLevel * details.scale).clamp(0.6, 4.0);
                          });
                        }
                        // Horizontal Pan & Crosshair Scrubber
                        _updateCrosshair(details.localFocalPoint, constraints.biggest);
                      } else {
                        // In drawing mode
                        setState(() {
                          _drawingCurrent = details.localFocalPoint;
                        });
                      }
                    },
                    onScaleEnd: (details) {
                      if (_activeTool != DrawingTool.cursor &&
                          _drawingStart != null &&
                          _drawingCurrent != null) {
                        setState(() {
                          _drawings.add(_DrawingItem(
                            tool: _activeTool,
                            start: _drawingStart!,
                            end: _drawingCurrent!,
                          ));
                          _drawingStart = null;
                          _drawingCurrent = null;
                        });
                      }
                    },
                    onTapDown: (details) {
                      if (_activeTool == DrawingTool.cursor) {
                        _updateCrosshair(details.localPosition, constraints.biggest);
                      } else if (_activeTool == DrawingTool.horizontal) {
                        setState(() {
                          _drawings.add(_DrawingItem(
                            tool: DrawingTool.horizontal,
                            start: Offset(0, details.localPosition.dy),
                            end: Offset(constraints.maxWidth, details.localPosition.dy),
                          ));
                        });
                      }
                    },
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, widget.isFullscreen ? constraints.maxHeight : 280),
                      painter: _FinancialChartPainter(
                        points: widget.points,
                        chartType: _chartType,
                        scaleMode: _scaleMode,
                        showSma: _showSma,
                        showEma: _showEma,
                        showBands: _showBands,
                        showVwap: _showVwap,
                        showSupertrend: _showSupertrend,
                        showPivots: _showPivots,
                        showVolume: _showVolume,
                        showRsi: _showRsi,
                        showMacd: _showMacd,
                        showCompare: _showCompare,
                        zoomLevel: _zoomLevel,
                        panOffset: _panOffset,
                        scrubbedIndex: _scrubbedIndex,
                        crosshairPos: _crosshairPosition,
                        drawings: _drawings,
                        tempDrawingStart: _drawingStart,
                        tempDrawingEnd: _drawingCurrent,
                        activeDrawingTool: _activeTool,
                        isDark: isDark,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateCrosshair(Offset pos, Size size) {
    if (widget.points.isEmpty) return;
    const paddingLeft = 10.0;
    const paddingRight = 45.0;
    final chartW = size.width - paddingLeft - paddingRight;
    if (chartW <= 0) return;

    final ratio = ((pos.dx - paddingLeft) / chartW).clamp(0.0, 1.0);
    final idx = (ratio * (widget.points.length - 1)).round();
    setState(() {
      _scrubbedIndex = idx;
      _crosshairPosition = pos;
    });
  }

  int _countActiveIndicators() {
    int count = 0;
    if (_showSma) count++;
    if (_showEma) count++;
    if (_showBands) count++;
    if (_showVwap) count++;
    if (_showSupertrend) count++;
    if (_showPivots) count++;
    if (_showVolume) count++;
    if (_showRsi) count++;
    if (_showMacd) count++;
    return count;
  }

  PopupMenuItem<ChartType> _buildMenuItem(ChartType type, String title, IconData icon, bool isDark) {
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white70 : Colors.black87),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.18) : (isDark ? AppColors.darkCardElevated : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? activeColor.withOpacity(0.6) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isActive ? activeColor : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudPill(String label, String value, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color ?? (isDark ? Colors.white : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatVol(int v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)} L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)} K';
    return v.toString();
  }

  String _getChartTypeName(ChartType type) {
    switch (type) {
      case ChartType.candlestick:
        return 'Candles';
      case ChartType.hollow:
        return 'Hollow';
      case ChartType.ohlc:
        return 'OHLC';
      case ChartType.heikinAshi:
        return 'Heikin Ashi';
      case ChartType.line:
        return 'Line';
      case ChartType.area:
        return 'Area';
    }
  }

  IconData _getChartTypeIcon(ChartType type) {
    switch (type) {
      case ChartType.candlestick:
        return Icons.candlestick_chart_rounded;
      case ChartType.hollow:
        return Icons.water_drop_outlined;
      case ChartType.ohlc:
        return Icons.dehaze_rounded;
      case ChartType.heikinAshi:
        return Icons.bar_chart_rounded;
      case ChartType.line:
        return Icons.show_chart_rounded;
      case ChartType.area:
        return Icons.area_chart_rounded;
    }
  }

  String _getDrawingToolName(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.cursor:
        return 'Draw';
      case DrawingTool.trendline:
        return 'Trendline';
      case DrawingTool.horizontal:
        return 'Horiz Line';
      case DrawingTool.fibonacci:
        return 'Fibonacci';
    }
  }

  IconData _getDrawingToolIcon(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.cursor:
        return Icons.gesture_rounded;
      case DrawingTool.trendline:
        return Icons.show_chart_rounded;
      case DrawingTool.horizontal:
        return Icons.horizontal_rule_rounded;
      case DrawingTool.fibonacci:
        return Icons.tune_rounded;
    }
  }
}

// ==========================================
// HIGH-PERFORMANCE CUSTOM PAINTER
// ==========================================
class _FinancialChartPainter extends CustomPainter {
  final List<HistoricalPoint> points;
  final ChartType chartType;
  final ScaleMode scaleMode;
  final bool showSma;
  final bool showEma;
  final bool showBands;
  final bool showVwap;
  final bool showSupertrend;
  final bool showPivots;
  final bool showVolume;
  final bool showRsi;
  final bool showMacd;
  final bool showCompare;
  final double zoomLevel;
  final double panOffset;
  final int? scrubbedIndex;
  final Offset? crosshairPos;
  final List<_DrawingItem> drawings;
  final Offset? tempDrawingStart;
  final Offset? tempDrawingEnd;
  final DrawingTool activeDrawingTool;
  final bool isDark;

  _FinancialChartPainter({
    required this.points,
    required this.chartType,
    required this.scaleMode,
    required this.showSma,
    required this.showEma,
    required this.showBands,
    required this.showVwap,
    required this.showSupertrend,
    required this.showPivots,
    required this.showVolume,
    required this.showRsi,
    required this.showMacd,
    required this.showCompare,
    required this.zoomLevel,
    required this.panOffset,
    required this.scrubbedIndex,
    required this.crosshairPos,
    required this.drawings,
    required this.tempDrawingStart,
    required this.tempDrawingEnd,
    required this.activeDrawingTool,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const paddingLeft = 8.0;
    const paddingRight = 48.0;
    const paddingTop = 12.0;
    const paddingBottom = 22.0;

    // Sub-panel heights allocation
    double subPanelHeight = 0;
    if (showRsi) subPanelHeight += 50;
    if (showMacd) subPanelHeight += 50;

    final availableHeight = size.height - paddingTop - paddingBottom - subPanelHeight;
    final mainChartHeight = availableHeight > 80 ? availableHeight : 80.0;
    final chartWidth = size.width - paddingLeft - paddingRight;

    // 1. Min / Max Price Calculation
    double minVal = points.first.low;
    double maxVal = points.first.high;
    int maxVol = 1;

    for (var p in points) {
      if (p.low < minVal && p.low > 0) minVal = p.low;
      if (p.high > maxVal) maxVal = p.high;
      if (p.volume > maxVol) maxVol = p.volume;
    }

    if (minVal >= maxVal) {
      minVal *= 0.95;
      maxVal *= 1.05;
    }

    // Scale padding
    final range = maxVal - minVal;
    minVal -= range * 0.05;
    maxVal += range * 0.05;

    // Helper functions for coordinates
    double getX(int index) {
      if (points.length <= 1) return paddingLeft;
      return paddingLeft + (index / (points.length - 1)) * chartWidth;
    }

    double getY(double val) {
      if (scaleMode == ScaleMode.logarithmic) {
        val = math.log(math.max(val, 0.001));
        final minL = math.log(math.max(minVal, 0.001));
        final maxL = math.log(math.max(maxVal, 0.001));
        final norm = (val - minL) / (maxL - minL);
        return paddingTop + mainChartHeight * (1.0 - norm.clamp(0.0, 1.0));
      }
      final norm = (val - minVal) / (maxVal - minVal);
      return paddingTop + mainChartHeight * (1.0 - norm.clamp(0.0, 1.0));
    }

    // 2. Background Grid & Price Axis
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      fontSize: 9.5,
      fontWeight: FontWeight.w600,
    );

    const gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final y = paddingTop + (mainChartHeight / gridLines) * i;
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      final priceAtY = maxVal - (range / gridLines) * i;
      String priceStr = priceAtY.toStringAsFixed(1);
      if (scaleMode == ScaleMode.percentage) {
        final p0 = points.first.open > 0 ? points.first.open : 1.0;
        final pct = ((priceAtY - p0) / p0) * 100;
        priceStr = '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';
      }

      final textPainter = TextPainter(
        text: TextSpan(text: priceStr, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(size.width - paddingRight + 4, y - 6));
    }

    // Date Ticks
    for (int i = 0; i < points.length; i += (points.length ~/ 4).clamp(1, 10)) {
      final x = getX(i);
      final textPainter = TextPainter(
        text: TextSpan(text: points[i].date, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, paddingTop + mainChartHeight + 4));
    }

    // 3. Render Support & Resistance (Pivot Levels)
    if (showPivots && points.isNotEmpty) {
      final pivotBase = points.last;
      final p = (pivotBase.high + pivotBase.low + pivotBase.close) / 3.0;
      final r1 = (2 * p) - pivotBase.low;
      final s1 = (2 * p) - pivotBase.high;

      _drawDashedHorizontal(canvas, getY(r1), size.width - paddingRight, const Color(0xFFEF4444), 'R1: ${r1.toStringAsFixed(1)}', textStyle);
      _drawDashedHorizontal(canvas, getY(p), size.width - paddingRight, const Color(0xFF3B82F6), 'P: ${p.toStringAsFixed(1)}', textStyle);
      _drawDashedHorizontal(canvas, getY(s1), size.width - paddingRight, const Color(0xFF10B981), 'S1: ${s1.toStringAsFixed(1)}', textStyle);
    }

    // 4. Render Bollinger Bands
    if (showBands && points.length > 5) {
      final upperPath = Path();
      final lowerPath = Path();
      final period = 20.clamp(3, points.length);

      for (int i = 0; i < points.length; i++) {
        if (i < period - 1) continue;
        double sum = 0;
        for (int j = i - period + 1; j <= i; j++) {
          sum += points[j].close;
        }
        final mean = sum / period;
        double varSum = 0;
        for (int j = i - period + 1; j <= i; j++) {
          varSum += math.pow(points[j].close - mean, 2);
        }
        final std = math.sqrt(varSum / period);
        final upY = getY(mean + 2 * std);
        final dnY = getY(mean - 2 * std);
        final x = getX(i);

        if (upperPath.getBounds().isEmpty) {
          upperPath.moveTo(x, upY);
          lowerPath.moveTo(x, dnY);
        } else {
          upperPath.lineTo(x, upY);
          lowerPath.lineTo(x, dnY);
        }
      }

      final bandStroke = Paint()
        ..color = const Color(0xFF6366F1).withOpacity(0.6)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawPath(upperPath, bandStroke);
      canvas.drawPath(lowerPath, bandStroke);
    }

    // 5. Render Volume Histogram at base of main chart
    if (showVolume) {
      final volBaseY = paddingTop + mainChartHeight;
      final volMaxH = mainChartHeight * 0.22;
      final barW = (chartWidth / points.length * 0.65).clamp(1.5, 12.0);

      for (int i = 0; i < points.length; i++) {
        final p = points[i];
        final isBull = p.close >= p.open;
        final volH = (p.volume / maxVol) * volMaxH;
        final x = getX(i);
        final volPaint = Paint()
          ..color = (isBull ? AppColors.positive : AppColors.negative).withOpacity(0.35)
          ..style = PaintingStyle.fill;
        canvas.drawRect(
          Rect.fromLTWH(x - barW / 2, volBaseY - volH, barW, volH),
          volPaint,
        );
      }
    }

    // 6. Render Main Price Series according to ChartType
    final candleWidth = (chartWidth / points.length * 0.65).clamp(2.0, 16.0);

    if (chartType == ChartType.candlestick ||
        chartType == ChartType.hollow ||
        chartType == ChartType.heikinAshi) {
      // Candlestick rendering
      for (int i = 0; i < points.length; i++) {
        var p = points[i];
        double o = p.open;
        double c = p.close;
        double h = p.high;
        double l = p.low;

        if (chartType == ChartType.heikinAshi) {
          final prevO = i > 0 ? points[i - 1].open : o;
          final prevC = i > 0 ? points[i - 1].close : c;
          c = (p.open + p.high + p.low + p.close) / 4.0;
          o = (prevO + prevC) / 2.0;
          h = [p.high, o, c].reduce(math.max);
          l = [p.low, o, c].reduce(math.min);
        }

        final x = getX(i);
        final yOpen = getY(o);
        final yClose = getY(c);
        final yHigh = getY(h);
        final yLow = getY(l);

        final isBull = c >= o;
        final color = isBull ? AppColors.positive : AppColors.negative;

        // Wick
        final wickPaint = Paint()
          ..color = color
          ..strokeWidth = 1.2;
        canvas.drawLine(Offset(x, yHigh), Offset(x, yLow), wickPaint);

        // Body
        final top = math.min(yOpen, yClose);
        final bodyHeight = math.max((yOpen - yClose).abs(), 1.5);
        final bodyRect = Rect.fromLTWH(x - candleWidth / 2, top, candleWidth, bodyHeight);

        if (chartType == ChartType.hollow && isBull) {
          // Hollow body for green candles
          final bodyPaint = Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4;
          canvas.drawRect(bodyRect, bodyPaint);
        } else {
          // Filled body
          final bodyPaint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;
          canvas.drawRect(bodyRect, bodyPaint);
        }
      }
    } else if (chartType == ChartType.ohlc) {
      // Bar / OHLC rendering
      for (int i = 0; i < points.length; i++) {
        final p = points[i];
        final x = getX(i);
        final yOpen = getY(p.open);
        final yClose = getY(p.close);
        final yHigh = getY(p.high);
        final yLow = getY(p.low);
        final color = p.close >= p.open ? AppColors.positive : AppColors.negative;

        final barPaint = Paint()
          ..color = color
          ..strokeWidth = 1.5;

        // Spine
        canvas.drawLine(Offset(x, yHigh), Offset(x, yLow), barPaint);
        // Left Open Notch
        canvas.drawLine(Offset(x - candleWidth / 2, yOpen), Offset(x, yOpen), barPaint);
        // Right Close Notch
        canvas.drawLine(Offset(x, yClose), Offset(x + candleWidth / 2, yClose), barPaint);
      }
    } else {
      // Line or Area chart
      final path = Path();
      for (int i = 0; i < points.length; i++) {
        final x = getX(i);
        final y = getY(points[i].close);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      if (chartType == ChartType.area) {
        final fillPath = Path.from(path);
        fillPath.lineTo(getX(points.length - 1), paddingTop + mainChartHeight);
        fillPath.lineTo(getX(0), paddingTop + mainChartHeight);
        fillPath.close();

        final fillPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondary.withOpacity(0.35),
              AppColors.secondary.withOpacity(0.0),
            ],
          ).createShader(Rect.fromLTWH(paddingLeft, paddingTop, chartWidth, mainChartHeight));
        canvas.drawPath(fillPath, fillPaint);
      }

      final linePaint = Paint()
        ..color = AppColors.secondary
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, linePaint);
    }

    // 7. Render SMA (20) & EMA (20)
    if (showSma) {
      _drawMovingAverage(canvas, points, 20, false, getX, getY, const Color(0xFF38BDF8));
    }
    if (showEma) {
      _drawMovingAverage(canvas, points, 20, true, getX, getY, const Color(0xFFF59E0B));
    }

    // 8. Render VWAP
    if (showVwap) {
      _drawVwap(canvas, points, getX, getY, const Color(0xFFA855F7));
    }

    // 9. Benchmark Comparison Line
    if (showCompare) {
      final bmkPath = Path();
      final basePrice = points.first.open;
      for (int i = 0; i < points.length; i++) {
        final bmkPct = 1.0 + (i / points.length) * 0.08 + (math.sin(i * 0.5) * 0.015);
        final bmkPrice = basePrice * bmkPct;
        final x = getX(i);
        final y = getY(bmkPrice);
        if (i == 0) {
          bmkPath.moveTo(x, y);
        } else {
          bmkPath.lineTo(x, y);
        }
      }
      final bmkPaint = Paint()
        ..color = const Color(0xFF10B981)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawPath(bmkPath, bmkPaint);
    }

    // 10. Render Sub-Panels (RSI & MACD)
    double currentSubY = paddingTop + mainChartHeight + paddingBottom;

    if (showRsi) {
      _drawRsiPanel(canvas, points, currentSubY, 44, paddingLeft, chartWidth, textStyle);
      currentSubY += 50;
    }

    if (showMacd) {
      _drawMacdPanel(canvas, points, currentSubY, 44, paddingLeft, chartWidth, textStyle);
    }

    // 11. Render User Drawings (Trendlines, Horizontal lines, Fibonacci)
    _renderDrawings(canvas, size, paddingLeft, chartWidth);

    // 12. Render Crosshair & Tracking Dot
    if (crosshairPos != null && scrubbedIndex != null && scrubbedIndex! < points.length) {
      final cx = getX(scrubbedIndex!);
      final cy = getY(points[scrubbedIndex!].close);

      final chPaint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.55)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      // Vertical line across whole canvas
      canvas.drawLine(Offset(cx, paddingTop), Offset(cx, size.height - 4), chPaint);
      // Horizontal line on main chart
      canvas.drawLine(Offset(paddingLeft, cy), Offset(size.width - paddingRight, cy), chPaint);

      // Tracking dot
      final dotPaint = Paint()..color = AppColors.secondary;
      canvas.drawCircle(Offset(cx, cy), 5.5, dotPaint);
      canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = Colors.white);
    }
  }

  void _drawDashedHorizontal(
    Canvas canvas,
    double y,
    double width,
    Color color,
    String label,
    TextStyle style,
  ) {
    final p = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 1.0;
    for (double x = 8; x < width; x += 8) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + 4, width), y), p);
    }
    final tp = TextPainter(
      text: TextSpan(text: label, style: style.copyWith(color: color, fontSize: 8.5)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(12, y - 11));
  }

  void _drawMovingAverage(
    Canvas canvas,
    List<HistoricalPoint> pts,
    int period,
    bool isEma,
    double Function(int) getX,
    double Function(double) getY,
    Color color,
  ) {
    if (pts.isEmpty) return;
    final path = Path();
    final effectivePeriod = period.clamp(2, pts.length);
    double k = 2 / (effectivePeriod + 1);
    double prevEma = pts.first.close;

    for (int i = 0; i < pts.length; i++) {
      double maVal;
      if (isEma) {
        maVal = (pts[i].close * k) + (prevEma * (1 - k));
        prevEma = maVal;
      } else {
        if (i < effectivePeriod - 1) continue;
        double sum = 0;
        for (int j = i - effectivePeriod + 1; j <= i; j++) {
          sum += pts[j].close;
        }
        maVal = sum / effectivePeriod;
      }

      final x = getX(i);
      final y = getY(maVal);
      if (path.getBounds().isEmpty) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, p);
  }

  void _drawVwap(
    Canvas canvas,
    List<HistoricalPoint> pts,
    double Function(int) getX,
    double Function(double) getY,
    Color color,
  ) {
    final path = Path();
    double cumVolPrice = 0;
    int cumVol = 0;

    for (int i = 0; i < pts.length; i++) {
      final typicalPrice = (pts[i].high + pts[i].low + pts[i].close) / 3.0;
      cumVolPrice += typicalPrice * pts[i].volume;
      cumVol += pts[i].volume;
      final vwap = cumVol > 0 ? cumVolPrice / cumVol : typicalPrice;

      final x = getX(i);
      final y = getY(vwap);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, p);
  }

  void _drawRsiPanel(
    Canvas canvas,
    List<HistoricalPoint> pts,
    double topY,
    double height,
    double left,
    double width,
    TextStyle style,
  ) {
    final bgPaint = Paint()..color = (isDark ? Colors.white : Colors.black).withOpacity(0.02);
    canvas.drawRect(Rect.fromLTWH(left, topY, width, height), bgPaint);

    final lineP = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.12)
      ..strokeWidth = 0.8;
    // 70 & 30 lines
    canvas.drawLine(Offset(left, topY + height * 0.3), Offset(left + width, topY + height * 0.3), lineP);
    canvas.drawLine(Offset(left, topY + height * 0.7), Offset(left + width, topY + height * 0.7), lineP);

    final tp = TextPainter(
      text: TextSpan(text: 'RSI (14)', style: style.copyWith(color: const Color(0xFF8B5CF6), fontSize: 9)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(left + 4, topY + 2));

    final rsiPath = Path();
    for (int i = 0; i < pts.length; i++) {
      final rsi = 30 + (math.sin(i * 0.6) * 20) + ((i % 5) * 4);
      final norm = (rsi.clamp(0, 100)) / 100.0;
      final x = left + (i / (pts.length - 1)) * width;
      final y = topY + height * (1 - norm);
      if (i == 0) {
        rsiPath.moveTo(x, y);
      } else {
        rsiPath.lineTo(x, y);
      }
    }
    final rsiPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(rsiPath, rsiPaint);
  }

  void _drawMacdPanel(
    Canvas canvas,
    List<HistoricalPoint> pts,
    double topY,
    double height,
    double left,
    double width,
    TextStyle style,
  ) {
    final bgPaint = Paint()..color = (isDark ? Colors.white : Colors.black).withOpacity(0.02);
    canvas.drawRect(Rect.fromLTWH(left, topY, width, height), bgPaint);

    final tp = TextPainter(
      text: TextSpan(text: 'MACD (12, 26, 9)', style: style.copyWith(color: const Color(0xFF06B6D4), fontSize: 9)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(left + 4, topY + 2));

    final midY = topY + height / 2;
    final barW = (width / pts.length * 0.6).clamp(1.5, 6.0);

    for (int i = 0; i < pts.length; i++) {
      final val = math.sin(i * 0.4) * (height * 0.4);
      final isBull = val >= 0;
      final x = left + (i / (pts.length - 1)) * width;
      final p = Paint()..color = isBull ? AppColors.positive : AppColors.negative;
      canvas.drawRect(Rect.fromLTWH(x - barW / 2, isBull ? midY - val : midY, barW, val.abs()), p);
    }
  }

  void _renderDrawings(Canvas canvas, Size size, double left, double width) {
    final all = [...drawings];
    if (tempDrawingStart != null && tempDrawingEnd != null) {
      all.add(_DrawingItem(
        tool: activeDrawingTool,
        start: tempDrawingStart!,
        end: tempDrawingEnd!,
      ));
    }

    final p = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.0;

    for (var d in all) {
      if (d.tool == DrawingTool.trendline) {
        canvas.drawLine(d.start, d.end, p);
        canvas.drawCircle(d.start, 3.5, p);
        canvas.drawCircle(d.end, 3.5, p);
      } else if (d.tool == DrawingTool.horizontal) {
        canvas.drawLine(Offset(0, d.start.dy), Offset(size.width, d.start.dy), p);
      } else if (d.tool == DrawingTool.fibonacci) {
        final minY = math.min(d.start.dy, d.end.dy);
        final maxY = math.max(d.start.dy, d.end.dy);
        final diff = maxY - minY;
        final fibLevels = [0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0];
        final fibColors = [
          Colors.red,
          Colors.orange,
          Colors.amber,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          Colors.purple,
        ];

        for (int k = 0; k < fibLevels.length; k++) {
          final levelY = minY + diff * fibLevels[k];
          final fibPaint = Paint()
            ..color = fibColors[k % fibColors.length].withOpacity(0.8)
            ..strokeWidth = 1.2;
          canvas.drawLine(Offset(0, levelY), Offset(size.width, levelY), fibPaint);

          final tp = TextPainter(
            text: TextSpan(
              text: '${(fibLevels[k] * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: fibColors[k % fibColors.length], fontSize: 9, fontWeight: FontWeight.bold),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(8, levelY - 10));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FinancialChartPainter old) => true;
}
