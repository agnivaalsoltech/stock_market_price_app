<?php
$pageTitle = 'My Portfolio - MarketPulse';
$currentPage = 'portfolio';
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/includes/header.php';
?>

<div class="container-fluid px-lg-4 py-4">
    <!-- Header with Action Button -->
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
        <div>
            <h1 class="h3 fw-bold mb-1">Portfolio Intelligence</h1>
            <p class="text-muted small mb-0">Track real-time valuations, capital gains, and asset diversification</p>
        </div>
        <div class="d-flex gap-2">
            <button class="btn btn-outline-secondary btn-sm" onclick="resetDemoHoldings()"><i class="bi bi-arrow-counterclockwise me-1"></i> Reset Demo</button>
            <button class="btn mp-btn-primary btn-sm px-3" data-bs-toggle="modal" data-bs-target="#addHoldingModal">
                <i class="bi bi-plus-lg me-1"></i> Add Investment
            </button>
        </div>
    </div>

    <!-- Investor Profile Status Header Banner -->
    <div id="investorProfileBanner" class="card mb-4 border-0 shadow-sm d-none" style="background: linear-gradient(135deg, rgba(37, 99, 235, 0.08) 0%, rgba(16, 185, 129, 0.08) 100%); border-left: 4px solid var(--mp-secondary) !important;">
        <div class="card-body p-3 d-flex flex-wrap justify-content-between align-items-center gap-2">
            <div class="d-flex align-items-center gap-3">
                <div class="bg-primary text-white rounded-circle p-2 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                    <i class="bi bi-shield-check fs-5"></i>
                </div>
                <div>
                    <div class="d-flex align-items-center gap-2">
                        <span class="fw-bold" id="bannerInvestorName">Alex Morgan</span>
                        <span class="badge bg-success-subtle text-success small" id="bannerInvestorTier"><i class="bi bi-patch-check-fill me-1"></i>Verified Global Trader</span>
                        <span class="badge bg-secondary-subtle text-secondary small font-monospace" id="bannerAccountId">MP-849201-GL</span>
                    </div>
                    <div class="small text-muted" id="bannerProfileDetails">
                        Jurisdiction: United States • Risk Profile: Moderate • Primary Markets: US & European Equities
                    </div>
                </div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <a href="kyc.php" class="btn btn-sm btn-outline-primary"><i class="bi bi-shield-check me-1"></i> View KYC Clearance</a>
            </div>
        </div>
    </div>

    <!-- Summary Metrics Cards -->
    <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-lg-3">
            <div class="mp-card">
                <span class="text-muted small fw-semibold">Total Portfolio Value</span>
                <div class="fs-3 fw-bold mt-1" id="totalPortfolioValue" data-base-price="0">€0.00</div>
                <div class="small text-muted mt-2">Live market evaluated</div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
            <div class="mp-card">
                <span class="text-muted small fw-semibold">Total Capital Invested</span>
                <div class="fs-3 fw-bold mt-1" id="totalInvestedValue" data-base-price="0">€0.00</div>
                <div class="small text-muted mt-2">Cumulative cost basis</div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
            <div class="mp-card">
                <span class="text-muted small fw-semibold">Total Profit / Loss</span>
                <div class="fs-3 fw-bold mt-1" id="totalProfitLoss">€0.00</div>
                <div class="small mt-2" id="totalProfitPercent">+0.00%</div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
            <div class="mp-card">
                <span class="text-muted small fw-semibold">Active Assets</span>
                <div class="fs-3 fw-bold mt-1" id="totalAssetsCount">0</div>
                <div class="small text-muted mt-2">Equities held</div>
            </div>
        </div>
    </div>

    <!-- Allocation Chart and Holdings Table -->
    <div class="row g-4">
        <!-- Allocation Doughnut Chart via Chart.js -->
        <div class="col-12 col-lg-4">
            <div class="mp-card h-100">
                <div class="mp-card-header">
                    <h3 class="h5 fw-bold mb-0">Asset Allocation</h3>
                    <span class="small text-muted">Chart.js</span>
                </div>
                <div style="position: relative; height: 260px; width: 100%;">
                    <canvas id="allocationChartCanvas"></canvas>
                </div>
                <div id="allocationLegend" class="mt-3 small">
                    <!-- Populated dynamically -->
                </div>
            </div>
        </div>

        <!-- Holdings List -->
        <div class="col-12 col-lg-8">
            <div class="mp-card h-100">
                <div class="mp-card-header">
                    <h3 class="h5 fw-bold mb-0">Holdings & Performance</h3>
                    <span class="badge bg-secondary-subtle text-secondary" id="holdingsBadge">0 Positions</span>
                </div>
                <div class="table-responsive">
                    <table class="mp-table align-middle" id="holdingsTable">
                        <thead>
                            <tr>
                                <th>Symbol</th>
                                <th>Qty</th>
                                <th>Buy Price</th>
                                <th>Current</th>
                                <th>Total Value</th>
                                <th>P/L</th>
                                <th>Return</th>
                                <th class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody id="holdingsTableBody">
                            <!-- Populated dynamically -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Add Holding -->
<div class="modal fade" id="addHoldingModal" tabindex="-1" aria-labelledby="addHoldingModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="addHoldingForm">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="addHoldingModalLabel"><i class="bi bi-plus-circle me-2 text-primary"></i> Add Stock Holding</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="holdingSymbol" class="form-label small fw-semibold">Select Stock Symbol</label>
                        <select class="form-select" id="holdingSymbol" required>
                            <?php foreach ($STOCKS as $s): ?>
                                <option value="<?php echo $s['symbol']; ?>" data-price="<?php echo $s['price']; ?>">
                                    <?php echo $s['symbol'] . ' - ' . $s['companyName'] . ' (€' . number_format($s['price'], 2) . ')'; ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label for="holdingQty" class="form-label small fw-semibold">Quantity (Shares)</label>
                            <input type="number" class="form-control" id="holdingQty" value="10" min="1" step="1" required>
                        </div>
                        <div class="col-6">
                            <label for="holdingBuyPrice" class="form-label small fw-semibold">Buy Price (€ EUR)</label>
                            <input type="number" class="form-control" id="holdingBuyPrice" value="200" min="0.01" step="0.01" required>
                        </div>
                    </div>
                    <div class="alert alert-light border small text-muted">
                        <span>The current market price is retrieved dynamically from the active market quote data.</span>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn mp-btn-primary btn-sm px-4">Add Holding</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Trade / Add More Shares -->
<div class="modal fade" id="tradePositionModal" tabindex="-1" aria-labelledby="tradePositionModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form id="tradePositionForm" onsubmit="executeTradePosition(event)">
                <div class="modal-header">
                    <div>
                        <h5 class="modal-title fw-bold mb-0" id="tradePositionModalLabel">Buy Additional Shares</h5>
                        <span class="small text-muted" id="tradePositionSymbol">SAP</span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="tradeHoldingId">
                    <div class="p-3 bg-light rounded-3 mb-3">
                        <div class="d-flex justify-content-between mb-1 small">
                            <span class="text-muted">Current Quantity Held:</span>
                            <strong id="tradeCurrentQty">0 shares</strong>
                        </div>
                        <div class="d-flex justify-content-between small">
                            <span class="text-muted">Average Cost Basis:</span>
                            <strong id="tradeCurrentPrice">€0.00</strong>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="tradeAddQty" class="form-label small fw-semibold">Additional Shares to Purchase</label>
                        <input type="number" class="form-control form-control-lg" id="tradeAddQty" value="5" min="1" step="1" required>
                    </div>
                    <div class="mb-3">
                        <label for="tradeExecutePrice" class="form-label small fw-semibold">Execution Price (€ EUR)</label>
                        <input type="number" class="form-control" id="tradeExecutePrice" step="0.01" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn mp-btn-primary btn-sm px-4">Confirm Purchase</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="assets/js/portfolio.js"></script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
