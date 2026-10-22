<?php
require_once __DIR__ . '/config/config.php';

$symbol = isset($_GET['symbol']) ? strtoupper(trim($_GET['symbol'])) : 'SAP';

$stock = getStockData($symbol);

$CURRENCY_SYMBOLS = ['EUR' => '€', 'USD' => '$', 'GBP' => '£', 'INR' => '₹'];
$stockCurrency = $stock['currency'] ?? 'EUR';
$stockCurrencySymbol = $CURRENCY_SYMBOLS[$stockCurrency] ?? '€';

$pageTitle = $stock['symbol'] . ' - ' . $stock['companyName'] . ' | MarketPulse';
$currentPage = 'markets';
require_once __DIR__ . '/includes/header.php';

$isPos = $stock['change'] >= 0;
?>

<div class="container-fluid px-lg-4 py-4">
    <!-- Breadcrumb & Back -->
    <div class="d-flex align-items-center gap-2 mb-3">
        <a href="markets.php" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i> Back to Markets</a>
        <span class="text-muted small">/</span>
        <a href="markets.php?country=<?php echo urlencode($stock['country']); ?>" class="text-muted small text-decoration-none">
            <?php echo htmlspecialchars($stock['country']); ?>
        </a>
        <span class="text-muted small">/</span>
        <span class="fw-bold small"><?php echo htmlspecialchars($stock['symbol']); ?></span>
    </div>

    <!-- Stock Header & Live Price Bar -->
    <div class="mp-card mb-4">
        <div class="row align-items-center g-3">
            <div class="col-12 col-md-6">
                <div class="d-flex align-items-center gap-2 mb-1">
                    <span class="badge bg-dark fs-5 px-3 py-2"><?php echo htmlspecialchars($stock['symbol']); ?></span>
                    <div>
                        <h1 class="h3 fw-bold mb-0"><?php echo htmlspecialchars($stock['companyName']); ?></h1>
                        <span class="text-muted small"><?php echo htmlspecialchars($stock['exchange']); ?> • <?php echo htmlspecialchars($stock['sector']); ?></span>
                    </div>
                </div>
            </div>
            <div class="col-12 col-md-6 text-md-end">
                <div class="d-flex flex-column align-items-md-end">
                    <div class="d-flex align-items-baseline gap-2">
                        <span class="mp-price-large" id="detailPrice" data-base-price="<?php echo $stock['price']; ?>">
                            <?php echo $stockCurrencySymbol . number_format($stock['price'], 2); ?>
                        </span>
                        <span class="<?php echo $isPos ? 'mp-badge-positive' : 'mp-badge-negative'; ?> fs-6" id="detailBadge">
                            <?php echo $isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>'; ?><?php echo number_format($stock['change'], 2); ?> (<?php echo number_format($stock['changePercent'], 2); ?>%)
                        </span>
                    </div>
                    <div class="d-flex align-items-center gap-2 mt-2 flex-wrap justify-content-md-end">
                        <span class="mp-status-live"><i class="bi bi-broadcast me-1"></i> Market Open</span>
                        <button id="stockWatchlistBtn" class="btn btn-sm btn-outline-warning" onclick="toggleStockWatchlist()" title="Save to Watchlist">
                            <i class="bi bi-star me-1"></i> Watchlist
                        </button>
                        <button class="btn btn-sm btn-outline-primary" onclick="quickAddToPortfolio('<?php echo $stock['symbol']; ?>', <?php echo $stock['price']; ?>)" title="Quick Add 10 Shares">
                            <i class="bi bi-plus-lg me-1"></i> Add to Portfolio
                        </button>
                        <button class="btn btn-sm mp-btn-primary" data-bs-toggle="modal" data-bs-target="#buyOrderModal" title="Execute Simulated Trade">
                            <i class="bi bi-lightning-charge-fill me-1"></i> Trade / Buy
                        </button>
                        <button class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#priceAlertModal" title="Configure Price Notification">
                            <i class="bi bi-bell-fill me-1"></i> Alert
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Chart & Key Stats Row -->
    <div class="row g-4 mb-4">
        <!-- Interactive Chart.js Area (Expanded 75% width) -->
        <div class="col-12 col-lg-9">
            <div class="mp-card h-100" id="mainChartCard">
                <!-- Dedicated Fullscreen Header (Active in Fullscreen Mode) -->
                <div class="mp-fs-header d-none align-items-center justify-content-between p-2 mb-2 rounded border" id="fsWorkstationHeader">
                    <div class="d-flex align-items-center gap-3">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge bg-primary fs-6 px-2 py-1"><?php echo $stock['symbol']; ?></span>
                            <div>
                                <strong class="d-block text-body fs-6 lh-1"><?php echo $stock['companyName']; ?></strong>
                                <small class="text-muted" style="font-size: 0.72rem;"><?php echo $stock['exchange']; ?> • <?php echo $stock['country']; ?> • <?php echo $stock['sector']; ?></small>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-2 border-start ps-3">
                            <span class="fs-5 fw-bold text-body" id="fsHeroPrice"><?php echo $stock['currency'] . ' ' . number_format($stock['price'], 2); ?></span>
                            <span class="<?php echo $isPos ? 'mp-badge-positive' : 'mp-badge-negative'; ?> small px-2 py-0" id="fsHeroBadge">
                                <?php echo $isPos ? '+' : ''; ?><?php echo number_format($stock['changePercent'], 2); ?>%
                            </span>
                            <span class="badge bg-success-subtle text-success border border-success-subtle small ms-1"><i class="bi bi-broadcast me-1"></i> LIVE</span>
                        </div>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <button class="btn btn-sm btn-outline-warning px-2 py-1" onclick="toggleStockWatchlist()" title="Save to Watchlist">
                            <i class="bi bi-star me-1"></i> Watchlist
                        </button>
                        <button class="btn btn-sm btn-success px-3 py-1" data-bs-toggle="modal" data-bs-target="#buyOrderModal" style="font-size: 0.8rem; font-weight: 600;">
                            <i class="bi bi-lightning-charge-fill me-1"></i> Trade
                        </button>
                        <button class="btn btn-sm btn-danger px-3 py-1 fw-bold" onclick="toggleFullscreenChart()" style="font-size: 0.8rem;" title="Exit Fullscreen (Esc)">
                            <i class="bi bi-fullscreen-exit me-1"></i> Exit Fullscreen (Esc)
                        </button>
                    </div>
                </div>

                <!-- Top Toolbar: Title, Fullscreen, Templates & Timeframes -->
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-2 pb-2 border-bottom">
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <h3 class="h5 fw-bold mb-0">TradingView & Technical Workstation</h3>
                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle small px-2 py-0">Pro Multi-Mode</span>
                        
                        <!-- Layout Templates -->
                        <div class="dropdown d-inline-block">
                            <button class="btn btn-sm btn-outline-secondary dropdown-toggle py-0 px-2" type="button" data-bs-toggle="dropdown" style="font-size: 0.78rem;">
                                <i class="bi bi-layout-wtf me-1"></i> <span id="currentTemplateLabel">Default Layout</span>
                            </button>
                            <ul class="dropdown-menu shadow-sm" style="font-size: 0.82rem;">
                                <li><a class="dropdown-item active" href="javascript:void(0)" onclick="applyChartTemplate('default')">Default (Candles + Volume)</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="applyChartTemplate('intraday')">Intraday Setup (EMA + VWAP + RSI + Vol)</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="applyChartTemplate('swing')">Swing Setup (SMA + Bollinger + MACD)</a></li>
                            </ul>
                        </div>
                    </div>

                    <!-- Right actions: Fullscreen & Auto Live -->
                    <div class="d-flex align-items-center gap-1">
                        <button class="btn btn-sm btn-outline-primary py-0 px-2" id="btnResetLive" title="Snap to latest market tick" style="font-size: 0.78rem;">
                            <i class="bi bi-broadcast me-1"></i> Live
                        </button>
                        <button class="btn btn-sm btn-outline-secondary py-0 px-2" id="btnFullscreenToggle" title="Toggle Fullscreen Canvas" style="font-size: 0.78rem;">
                            <i class="bi bi-arrows-fullscreen me-1"></i> Fullscreen
                        </button>
                    </div>
                </div>

                <!-- Secondary Control Strip: Chart Types, Timeframe Presets, Indicators, Drawings, Compare, Scale -->
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-2 pb-2 border-bottom">
                    <!-- Left: Chart Types & Timeframes -->
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <!-- Chart Mode Dropdown -->
                        <div class="dropdown">
                            <button class="btn btn-sm mp-chart-toggle-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" id="chartTypeDropdownBtn">
                                <i class="bi bi-bar-chart-steps text-primary"></i> <span id="chartTypeLabel">Candlestick</span>
                            </button>
                            <ul class="dropdown-menu shadow-sm" id="chartTypeMenu" style="font-size: 0.82rem;">
                                <li><a class="dropdown-item active" href="javascript:void(0)" data-type="candlestick"><i class="bi bi-bar-chart-steps me-2 text-success"></i>Candlestick ⭐</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" data-type="hollow_candles"><i class="bi bi-square me-2 text-primary"></i>Hollow Candles</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" data-type="ohlc"><i class="bi bi-reception-3 me-2 text-info"></i>Bar / OHLC</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" data-type="heikin_ashi"><i class="bi bi-activity me-2 text-warning"></i>Heikin Ashi</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" data-type="line"><i class="bi bi-graph-up me-2 text-primary"></i>Line Chart</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" data-type="area"><i class="bi bi-water me-2 text-info"></i>Area Chart</a></li>
                            </ul>
                        </div>

                        <!-- Timeframe Presets -->
                        <div class="d-flex gap-1" id="chartRangeButtons">
                            <button class="mp-range-btn" data-range="1m">1m</button>
                            <button class="mp-range-btn" data-range="5m">5m</button>
                            <button class="mp-range-btn" data-range="15m">15m</button>
                            <button class="mp-range-btn" data-range="1H">1H</button>
                            <button class="mp-range-btn active" data-range="1D">1D</button>
                            <button class="mp-range-btn" data-range="1W">1W</button>
                            <button class="mp-range-btn" data-range="1M">1M</button>
                            <button class="mp-range-btn" data-range="3M">3M</button>
                            <button class="mp-range-btn" data-range="1Y">1Y</button>
                            <button class="mp-range-btn" data-range="ALL">ALL</button>
                        </div>
                    </div>

                    <!-- Right: Technical Indicators & Tools -->
                    <div class="d-flex align-items-center gap-1 flex-wrap">
                        <!-- Indicators Dropdown -->
                        <div class="dropdown">
                            <button class="btn btn-sm mp-chart-toggle-btn dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                <i class="bi bi-sliders text-secondary"></i> Indicators
                            </button>
                            <div class="dropdown-menu p-2 shadow-sm" style="min-width: 220px; font-size: 0.82rem;">
                                <h6 class="dropdown-header px-1 py-1 small fw-bold text-uppercase text-muted">Trend & Volatility</h6>
                                <div class="form-check py-1">
                                    <input class="form-check-input" type="checkbox" id="chkIndSma" checked>
                                    <label class="form-check-label" for="chkIndSma">SMA (20)</label>
                                </div>
                                <div class="form-check py-1">
                                    <input class="form-check-input" type="checkbox" id="chkIndEma">
                                    <label class="form-check-label" for="chkIndEma">EMA (20)</label>
                                </div>
                                <div class="form-check py-1">
                                    <input class="form-check-input" type="checkbox" id="chkIndBollinger">
                                    <label class="form-check-label" for="chkIndBollinger">Bollinger Bands (20, 2)</label>
                                </div>
                                <div class="form-check py-1">
                                    <input class="form-check-input" type="checkbox" id="chkIndSupertrend">
                                    <label class="form-check-label" for="chkIndSupertrend">Supertrend</label>
                                </div>
                                <div class="form-check py-1">
                                    <input class="form-check-input" type="checkbox" id="chkIndVwap">
                                    <label class="form-check-label" for="chkIndVwap">VWAP</label>
                                </div>
                                <div class="form-check py-1">
                                    <input class="form-check-input" type="checkbox" id="chkIndPivots">
                                    <label class="form-check-label" for="chkIndPivots">Pivot Levels (S/R)</label>
                                </div>
                                <div class="dropdown-divider my-1"></div>
                                <h6 class="dropdown-header px-1 py-1 small fw-bold text-uppercase text-muted">Sub-Chart Panels</h6>
                                <div class="form-check py-1">
                                    <input class="form-check-input" type="checkbox" id="chkIndVolume" checked>
                                    <label class="form-check-label" for="chkIndVolume">Volume Histogram</label>
                                </div>
                                <div class="form-check py-1">
                                    <input class="form-check-input" type="checkbox" id="chkIndRsi">
                                    <label class="form-check-label" for="chkIndRsi">RSI (14) Momentum</label>
                                </div>
                                <div class="form-check py-1">
                                    <input class="form-check-input" type="checkbox" id="chkIndMacd">
                                    <label class="form-check-label" for="chkIndMacd">MACD (12, 26, 9)</label>
                                </div>
                            </div>
                        </div>

                        <!-- Drawing Tools Dropdown -->
                        <div class="dropdown">
                            <button class="btn btn-sm mp-chart-toggle-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" id="drawingToolBtn">
                                <i class="bi bi-pencil-square text-info"></i> <span id="activeDrawingToolLabel">Draw</span>
                            </button>
                            <ul class="dropdown-menu shadow-sm" style="font-size: 0.82rem;">
                                <li><a class="dropdown-item active" href="javascript:void(0)" onclick="setDrawingTool('cursor')"><i class="bi bi-cursor me-2"></i>Pointer / Crosshair</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="setDrawingTool('trendline')"><i class="bi bi-slash-lg me-2"></i>Trend Line</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="setDrawingTool('horizontal')"><i class="bi bi-dash-lg me-2"></i>Horizontal Support/Resistance</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="setDrawingTool('fibonacci')"><i class="bi bi-reception-4 me-2"></i>Fibonacci Retracement</a></li>
                                <li><hr class="dropdown-divider my-1"></li>
                                <li><a class="dropdown-item text-danger" href="javascript:void(0)" onclick="clearAllDrawings()"><i class="bi bi-trash me-2"></i>Clear Drawings</a></li>
                            </ul>
                        </div>

                        <!-- Compare Stock / Benchmark -->
                        <button type="button" class="btn btn-sm mp-chart-toggle-btn" id="btnToggleCompare" onclick="toggleComparisonMode()">
                            <i class="bi bi-plus-circle text-primary"></i> <span id="compareBtnLabel">Compare</span>
                        </button>

                        <!-- Scale Mode Toggle -->
                        <div class="dropdown">
                            <button class="btn btn-sm mp-chart-toggle-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" style="font-size: 0.78rem;">
                                <i class="bi bi-aspect-ratio text-warning"></i> <span id="scaleModeLabel">Linear</span>
                            </button>
                            <ul class="dropdown-menu shadow-sm" style="font-size: 0.82rem;">
                                <li><a class="dropdown-item active" href="javascript:void(0)" onclick="setScaleMode('linear')">Linear Scale</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="setScaleMode('log')">Logarithmic (Log)</a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="setScaleMode('percentage')">Percentage (%)</a></li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Comprehensive Crosshair + OHLC Floating Telemetry HUD -->
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-2 p-2 rounded bg-body-tertiary border" id="ohlcHudBar" style="font-size: 0.8rem; font-family: monospace;">
                    <div class="d-flex align-items-center gap-3 flex-wrap">
                        <span class="text-muted"><i class="bi bi-clock me-1"></i><span id="hudDate">--</span></span>
                        <span>O: <strong id="hudOpen" class="text-body">--</strong></span>
                        <span>H: <strong id="hudHigh" class="text-success">--</strong></span>
                        <span>L: <strong id="hudLow" class="text-danger">--</strong></span>
                        <span>C: <strong id="hudClose" class="text-body">--</strong></span>
                        <span>Vol: <strong id="hudVolume" class="text-info">--</strong></span>
                        <span>Chg: <strong id="hudChgPct" class="text-success">--</strong></span>
                    </div>
                    <div class="d-flex align-items-center gap-2" id="hudIndicatorsBar" style="font-size: 0.78rem;">
                        <span id="hudSmaVal" class="text-primary d-none">SMA: --</span>
                        <span id="hudEmaVal" class="text-warning d-none">EMA: --</span>
                        <span id="hudRsiVal" class="text-purple d-none">RSI: --</span>
                    </div>
                </div>

                <!-- Main Chart Canvas Container -->
                <div class="mp-chart-container" id="chartCanvasWrapper" style="position: relative; width: 100%;">
                    <canvas id="stockChartCanvas" style="display: block; width: 100%; height: 100%; cursor: crosshair;"></canvas>
                </div>
                
                <!-- Chart Summary Metric Pills -->
                <div class="d-flex justify-content-between flex-wrap gap-2 text-muted small mt-2 pt-2 border-top">
                    <div class="mp-stat-pill">
                        <span class="text-muted">Currency:</span>
                        <strong id="chartCurrCode" class="text-body">EUR</strong>
                    </div>
                    <div class="mp-stat-pill">
                        <span class="text-muted">Period High:</span>
                        <strong id="chartHigh" class="text-success">--</strong>
                    </div>
                    <div class="mp-stat-pill">
                        <span class="text-muted">Period Low:</span>
                        <strong id="chartLow" class="text-danger">--</strong>
                    </div>
                    <div class="mp-stat-pill">
                        <span class="text-muted">Period Avg:</span>
                        <strong id="chartAvg" class="text-primary">--</strong>
                    </div>
                    <div class="mp-stat-pill">
                        <span class="text-muted">Period Volume:</span>
                        <strong id="chartVol" class="text-body">--</strong>
                    </div>
                </div>
            </div>
        </div>

        <!-- Key Information Grid (Reduced 25% width) -->
        <div class="col-12 col-lg-3">
            <div class="mp-card h-100">
                <h3 class="h5 fw-bold mb-3">Key Statistics</h3>
                <div class="list-group list-group-flush small">
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">Open</span>
                        <strong data-base-price="<?php echo $stock['open']; ?>"><?php echo $stockCurrencySymbol . number_format($stock['open'], 2); ?></strong>
                    </div>
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">Previous Close</span>
                        <strong data-base-price="<?php echo $stock['previousClose']; ?>"><?php echo $stockCurrencySymbol . number_format($stock['previousClose'], 2); ?></strong>
                    </div>
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">Day High</span>
                        <strong class="text-success" data-base-price="<?php echo $stock['high']; ?>"><?php echo $stockCurrencySymbol . number_format($stock['high'], 2); ?></strong>
                    </div>
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">Day Low</span>
                        <strong class="text-danger" data-base-price="<?php echo $stock['low']; ?>"><?php echo $stockCurrencySymbol . number_format($stock['low'], 2); ?></strong>
                    </div>
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">52-Week High</span>
                        <strong data-base-price="<?php echo $stock['week52High']; ?>"><?php echo $stockCurrencySymbol . number_format($stock['week52High'], 2); ?></strong>
                    </div>
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">52-Week Low</span>
                        <strong data-base-price="<?php echo $stock['week52Low']; ?>"><?php echo $stockCurrencySymbol . number_format($stock['week52Low'], 2); ?></strong>
                    </div>
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">Trading Volume</span>
                        <strong><?php echo number_format($stock['volume']); ?></strong>
                    </div>
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">Market Capitalization</span>
                        <strong><?php echo htmlspecialchars($stock['marketCap']); ?></strong>
                    </div>
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">P/E Ratio</span>
                        <strong><?php echo htmlspecialchars($stock['peRatio']); ?></strong>
                    </div>
                    <div class="list-group-item d-flex justify-content-between px-0 py-2">
                        <span class="text-muted">Exchange</span>
                        <strong><?php echo htmlspecialchars($stock['exchange']); ?></strong>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Historical Data Table & News Row -->
    <div class="row g-4">
        <!-- Historical Table Column -->
        <div class="col-12 col-lg-7">
            <div class="mp-card">
                <div class="mp-card-header">
                    <h3 class="h5 fw-bold mb-0">Historical Price Table</h3>
                    <span class="badge bg-light text-dark border">Recent Sessions</span>
                </div>
                <div class="table-responsive">
                    <table class="mp-table" id="stockHistoryTable">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Open</th>
                                <th>High</th>
                                <th>Low</th>
                                <th>Close</th>
                                <th>Volume</th>
                            </tr>
                        </thead>
                        <tbody id="historyTableBody">
                            <!-- Populated via API -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- News Links Column -->
        <div class="col-12 col-lg-5">
            <div class="mp-card">
                <div class="mp-card-header">
                    <h3 class="h5 fw-bold mb-0">Related News & Insights</h3>
                    <span class="small text-muted">Direct Press Coverage</span>
                </div>
                <div class="d-flex flex-column" id="stockNewsContainer">
                    <!-- Populated via API -->
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Execute Buy Order -->
<div class="modal fade" id="buyOrderModal" tabindex="-1" aria-labelledby="buyOrderModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form id="stockBuyOrderForm" onsubmit="executeStockBuyOrder(event)">
                <div class="modal-header">
                    <div>
                        <h5 class="modal-title fw-bold mb-0" id="buyOrderModalLabel">Execute Buy Order</h5>
                        <span class="small text-muted"><?php echo htmlspecialchars($stock['companyName']); ?> (<?php echo htmlspecialchars($stock['symbol']); ?>)</span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="p-3 bg-light rounded-3 mb-3">
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted small">Current Market Quote</span>
                            <strong data-base-price="<?php echo $stock['price']; ?>"><?php echo $stockCurrencySymbol . number_format($stock['price'], 2); ?></strong>
                        </div>
                        <div class="d-flex justify-content-between mb-1">
                            <span class="text-muted small">Execution Type</span>
                            <span class="badge bg-success-subtle text-success"><i class="bi bi-lightning-fill me-1"></i> Instant Market Order</span>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="buyOrderQty" class="form-label small fw-semibold">Quantity of Shares</label>
                        <input type="number" class="form-control form-control-lg" id="buyOrderQty" value="10" min="1" step="1" required oninput="updateBuyOrderTotal()">
                    </div>
                    <div class="p-3 border rounded-3 bg-white mb-2">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="fw-semibold">Estimated Order Total:</span>
                            <span class="fs-4 fw-bold text-primary" id="buyOrderEstimatedTotal">
                                €<?php echo number_format($stock['price'] * 10, 2); ?>
                            </span>
                        </div>
                        <span class="small text-muted">Automatically converted in active application currency.</span>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn mp-btn-primary btn-sm px-4"><i class="bi bi-check-lg me-1"></i> Execute Purchase</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Price Alert -->
<div class="modal fade" id="priceAlertModal" tabindex="-1" aria-labelledby="priceAlertModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form onsubmit="setStockPriceAlert(event)">
                <div class="modal-header">
                    <div>
                        <h5 class="modal-title fw-bold mb-0" id="priceAlertModalLabel"><i class="bi bi-bell-fill text-primary me-2"></i> Set Price Alert</h5>
                        <span class="small text-muted">Get notified when <?php echo htmlspecialchars($stock['symbol']); ?> crosses your target</span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Target Price (€ EUR)</label>
                        <input type="number" class="form-control" id="targetPriceInput" step="0.01" value="<?php echo round($stock['price'] * 1.05, 2); ?>" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Alert Condition</label>
                        <select class="form-select" id="alertConditionSelect">
                            <option value="above">Price rises above target</option>
                            <option value="below">Price drops below target</option>
                        </select>
                    </div>
                    <div class="alert alert-info small mb-0">
                        <i class="bi bi-bell-fill text-primary me-1"></i> We will simulate a browser push notification when market telemetry crosses this threshold.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm px-4"><i class="bi bi-check-lg me-1"></i> Create Alert</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
  window.CURRENT_SYMBOL = "<?php echo $stock['symbol']; ?>";
  window.CURRENT_BASE_PRICE = <?php echo $stock['price']; ?>;
  window.IS_POSITIVE = <?php echo $isPos ? 'true' : 'false'; ?>;
</script>
<script src="assets/js/stock.js"></script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
