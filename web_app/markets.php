<?php
$pageTitle = 'Markets Snapshot - MarketPulse';
$currentPage = 'markets';
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/includes/header.php';

$selectedCountry = isset($_GET['country']) && isset($MARKET_COUNTRIES[$_GET['country']]) 
    ? $_GET['country'] 
    : 'Germany';

$countryInfo = $MARKET_COUNTRIES[$selectedCountry];
$CURRENCY_SYMBOLS = ['EUR' => '€', 'USD' => '$', 'GBP' => '£', 'INR' => '₹'];
$countryCurrency = $countryInfo['currency'] ?? 'EUR';
$countryCurrencySymbol = $CURRENCY_SYMBOLS[$countryCurrency] ?? '€';

// Filter stocks by country
$countryStocks = array_filter($STOCKS, function($s) use ($selectedCountry) {
    return $s['country'] === $selectedCountry;
});
if (empty($countryStocks)) {
    $countryStocks = $STOCKS;
}
?>

<div class="container-fluid px-lg-4 py-4">
    <!-- Header Controls -->
    <div class="mp-card mb-4">
        <div class="row align-items-center g-3">
            <div class="col-12 col-md-4">
                <h1 class="h3 fw-bold mb-1">Global Markets Snapshot</h1>
                <p class="text-muted small mb-0">Live exchange telemetry, indices movement & equities list</p>
            </div>
            <div class="col-12 col-md-5">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                    <input type="text" id="marketFilterInput" class="form-control border-start-0" placeholder="Filter company, ticker, or sector...">
                </div>
            </div>
            <div class="col-12 col-md-3">
                <div class="d-flex align-items-center justify-content-md-end gap-2">
                    <label for="countryFilterSelect" class="small fw-semibold text-muted text-nowrap">Country:</label>
                    <select id="countryFilterSelect" class="form-select form-select-sm" onchange="if(window.MarketPulse) MarketPulse.setCountry(this.value, true); window.location.href='markets.php?country=' + encodeURIComponent(this.value)">
                        <?php foreach ($MARKET_COUNTRIES as $cName => $c): ?>
                            <option value="<?php echo $cName; ?>" <?php echo ($cName === $selectedCountry) ? 'selected' : ''; ?>>
                                <?php echo $c['flag'] . ' ' . $cName; ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <!-- Active Country Overview Banner -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="h5 fw-bold mb-0">
            <span><?php echo $countryInfo['flag']; ?></span> 
            <span><?php echo $selectedCountry; ?> Indices</span>
            <span class="badge bg-light text-dark border ms-2 small fw-normal"><?php echo $countryInfo['exchange']; ?></span>
        </h2>
        <span class="mp-status-live"><i class="bi bi-broadcast me-1"></i> Trading Session Open</span>
    </div>

    <!-- Indices Cards Row (Interactive) -->
    <div class="row g-3 mb-4">
        <?php foreach ($countryInfo['indices'] as $idx): 
            $isPos = $idx['change'] >= 0;
        ?>
            <div class="col-12 col-sm-6 col-lg-4">
                <div class="mp-card mp-index-card h-100" style="cursor: pointer; transition: transform 0.2s, box-shadow 0.2s;" 
                     data-name="<?php echo htmlspecialchars($idx['name']); ?>" 
                     data-symbol="<?php echo htmlspecialchars($idx['symbol']); ?>" 
                     data-price="<?php echo $idx['price']; ?>" 
                     data-change="<?php echo $idx['change']; ?>" 
                     data-change-pct="<?php echo $idx['changePercent']; ?>"
                     title="Click to view <?php echo htmlspecialchars($idx['name']); ?> details">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div>
                            <span class="badge bg-dark-subtle text-dark fw-bold"><?php echo htmlspecialchars($idx['symbol']); ?></span>
                            <div class="fw-bold mt-1"><?php echo htmlspecialchars($idx['name']); ?></div>
                        </div>
                        <span class="<?php echo $isPos ? 'mp-badge-positive' : 'mp-badge-negative'; ?>">
                            <?php echo $isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>'; ?><?php echo number_format($idx['changePercent'], 2); ?>%
                        </span>
                    </div>
                    <div class="d-flex align-items-baseline gap-2 mt-2">
                        <span class="fs-4 fw-bold" data-base-price="<?php echo $idx['price']; ?>">
                            <?php echo $countryCurrencySymbol . number_format($idx['price'], 2); ?>
                        </span>
                        <span class="small <?php echo $isPos ? 'text-success' : 'text-danger'; ?> fw-semibold">
                            (<?php echo ($isPos ? '+' : '') . number_format($idx['change'], 2); ?>)
                        </span>
                    </div>
                    <div class="mt-2 pt-2 border-top border-light d-flex justify-content-between small text-muted">
                        <span>Benchmark Index</span>
                        <span class="text-primary fw-semibold">Index Telemetry <i class="bi bi-arrow-right ms-1"></i></span>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    </div>

    <!-- Stocks Table with Strict Red / Green Visual Styling -->
    <div class="mp-card">
        <div class="mp-card-header flex-wrap gap-2">
            <div>
                <h3 class="h5 fw-bold mb-0">Listed Equities & Quotations</h3>
                <span class="small text-muted">Click any row for detailed charts, historical analytics and news</span>
            </div>
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <div class="btn-group btn-group-sm" role="group">
                    <button type="button" class="btn btn-outline-primary active" id="filterAllBtn">All Stocks</button>
                    <button type="button" class="btn btn-outline-primary" id="filterWatchlistBtn"><i class="bi bi-star-fill text-warning me-1"></i> Watchlist</button>
                    <button type="button" class="btn btn-outline-primary" id="filterGainersBtn">Gainers <i class="bi bi-caret-up-fill text-success ms-1"></i></button>
                    <button type="button" class="btn btn-outline-primary" id="filterLosersBtn">Losers <i class="bi bi-caret-down-fill text-danger ms-1"></i></button>
                </div>
                <span class="badge bg-secondary-subtle text-secondary" id="stockCountBadge">
                    <?php echo count($countryStocks); ?> Available
                </span>
            </div>
        </div>
        <div class="table-responsive">
            <table class="mp-table align-middle" id="marketsTable">
                <thead>
                    <tr>
                        <th style="width: 40px;"></th>
                        <th>Symbol</th>
                        <th>Company Name</th>
                        <th>Exchange</th>
                        <th>Sector</th>
                        <th>Market Price</th>
                        <th>Change</th>
                        <th>% Change</th>
                        <th>24h Volume</th>
                        <th class="text-end">Interactive</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($countryStocks as $stk): 
                        $isPos = $stk['change'] >= 0;
                        $trendClass = $isPos ? 'trend-positive' : 'trend-negative';
                    ?>
                        <tr class="market-stock-row <?php echo $trendClass; ?>" data-symbol="<?php echo htmlspecialchars($stk['symbol']); ?>" onclick="window.location.href='stock.php?symbol=<?php echo urlencode($stk['symbol']); ?>'" style="cursor: pointer;">
                            <td onclick="event.stopPropagation();">
                                <button class="mp-star-btn" data-symbol="<?php echo htmlspecialchars($stk['symbol']); ?>" title="Toggle Watchlist">
                                    <i class="bi bi-star"></i>
                                </button>
                            </td>
                            <td>
                                <span class="badge bg-dark text-white fw-bold px-2 py-1 fs-6">
                                    <?php echo htmlspecialchars($stk['symbol']); ?>
                                </span>
                            </td>
                            <td>
                                <div class="fw-bold text-dark"><?php echo htmlspecialchars($stk['companyName']); ?></div>
                                <div class="small text-muted"><?php echo htmlspecialchars($stk['country']); ?></div>
                            </td>
                            <td>
                                <span class="small text-muted fw-semibold"><?php echo htmlspecialchars($stk['exchange']); ?></span>
                            </td>
                            <td>
                                <span class="badge bg-light text-secondary border"><?php echo htmlspecialchars($stk['sector']); ?></span>
                            </td>
                            <td>
                                <span class="fw-bold fs-5" data-base-price="<?php echo $stk['price']; ?>">
                                    <?php echo $countryCurrencySymbol . number_format($stk['price'], 2); ?>
                                </span>
                            </td>
                            <td>
                                <span class="fw-bold <?php echo $isPos ? 'text-success' : 'text-danger'; ?>">
                                    <?php echo ($isPos ? '+' : '') . number_format($stk['change'], 2); ?>
                                </span>
                            </td>
                            <td>
                                <span class="<?php echo $isPos ? 'mp-badge-positive' : 'mp-badge-negative'; ?>">
                                    <?php echo $isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>'; ?><?php echo number_format($stk['changePercent'], 2); ?>%
                                </span>
                            </td>
                            <td>
                                <span class="small text-muted"><?php echo number_format($stk['volume']); ?></span>
                            </td>
                            <td class="text-end">
                                <a href="stock.php?symbol=<?php echo urlencode($stk['symbol']); ?>" class="btn btn-sm btn-primary" onclick="event.stopPropagation();">
                                    Analyze <i class="bi bi-arrow-right ms-1"></i>
                                </a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal: Index Details & Constituents -->
<div class="modal fade" id="indexDetailModal" tabindex="-1" aria-labelledby="indexDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <div>
                    <h5 class="modal-title fw-bold mb-0" id="indexModalTitle">Index Overview</h5>
                    <span class="small text-muted" id="indexModalSubtitle">Real-time benchmark telemetry</span>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="p-3 bg-light rounded-3 mb-3">
                    <div class="d-flex justify-content-between align-items-baseline mb-2">
                        <span class="text-muted small">Current Level</span>
                        <span class="fs-3 fw-bold" id="indexModalPrice">€0.00</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-muted small">Session Movement</span>
                        <span class="fw-bold" id="indexModalChange">+0.00 (+0.00%)</span>
                    </div>
                </div>
                <div class="row g-2 mb-3 text-center small">
                    <div class="col-4">
                        <div class="p-2 border rounded">
                            <div class="text-muted">Exchange</div>
                            <strong id="indexModalExchange"><?php echo htmlspecialchars($countryInfo['exchange']); ?></strong>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="p-2 border rounded">
                            <div class="text-muted">Market</div>
                            <strong><?php echo htmlspecialchars($selectedCountry); ?></strong>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="p-2 border rounded">
                            <div class="text-muted">Status</div>
                            <strong class="text-success"><i class="bi bi-record-fill me-1"></i>Open</strong>
                        </div>
                    </div>
                </div>
                <div class="alert alert-info small mb-0">
                    <i class="bi bi-lightbulb-fill text-warning me-1"></i> <strong>Constituents Filter:</strong> You can filter the listed equities table below by searching for tickers or sectors belonging to this index.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary btn-sm px-3" id="indexFilterStocksBtn">Filter Equities</button>
            </div>
        </div>
    </div>
</div>

<script src="assets/js/markets.js"></script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
