<?php
$pageTitle = 'Search & Explore Markets - MarketPulse';
$currentPage = 'search';
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/includes/header.php';

$initialQuery = isset($_GET['q']) ? trim($_GET['q']) : '';
?>

<div class="container-fluid px-lg-4 py-4">
    <div class="mp-card mb-4 p-4 text-center">
        <h1 class="h3 fw-bold mb-2">Market & Equities Explorer</h1>
        <p class="text-muted small mx-auto mb-4" style="max-width: 550px;">
            Search any listed company, stock symbol, exchange or country market to view live quotations and analytical charts.
        </p>

        <div class="row justify-content-center">
            <div class="col-12 col-md-8 col-lg-6">
                <div class="input-group input-group-lg shadow-sm">
                    <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                    <input type="text" id="globalSearchInput" class="form-control border-start-0" 
                           placeholder="Try 'SAP', 'Apple', 'Germany', 'USA', 'BMW'..." 
                           value="<?php echo htmlspecialchars($initialQuery); ?>" autofocus>
                    <button class="btn mp-btn-primary d-inline-flex align-items-center gap-1" type="button" id="triggerSearchBtn"><i class="bi bi-search"></i> Search</button>
                </div>
            </div>
        </div>

        <!-- Quick Search Tags -->
        <div class="d-flex justify-content-center gap-2 flex-wrap mt-3 small">
            <span class="text-muted">Popular:</span>
            <a href="#" class="badge bg-light text-dark border text-decoration-none px-2 py-1 quick-tag" data-query="SAP">SAP</a>
            <a href="#" class="badge bg-light text-dark border text-decoration-none px-2 py-1 quick-tag" data-query="BMW">BMW</a>
            <a href="#" class="badge bg-light text-dark border text-decoration-none px-2 py-1 quick-tag" data-query="Apple">Apple</a>
            <a href="#" class="badge bg-light text-dark border text-decoration-none px-2 py-1 quick-tag" data-query="Germany"><i class="bi bi-geo-alt-fill text-danger me-1"></i>Germany</a>
            <a href="#" class="badge bg-light text-dark border text-decoration-none px-2 py-1 quick-tag" data-query="USA"><i class="bi bi-geo-alt-fill text-primary me-1"></i>USA</a>
            <a href="#" class="badge bg-light text-dark border text-decoration-none px-2 py-1 quick-tag" data-query="India"><i class="bi bi-geo-alt-fill text-success me-1"></i>India</a>
        </div>
    </div>

    <!-- Search Results Section -->
    <div class="row g-4">
        <!-- Matching Countries Section -->
        <div class="col-12 col-lg-4" id="countryResultsCol">
            <div class="mp-card h-100">
                <div class="mp-card-header">
                    <h3 class="h5 fw-bold mb-0">Matching Country Markets</h3>
                    <span class="badge bg-light text-dark border" id="countryCount">0 Found</span>
                </div>
                <div class="d-flex flex-column gap-2" id="countryResultsContainer">
                    <!-- Populated dynamically -->
                </div>
            </div>
        </div>

        <!-- Matching Stocks Section -->
        <div class="col-12 col-lg-8" id="stockResultsCol">
            <div class="mp-card h-100">
                <div class="mp-card-header">
                    <h3 class="h5 fw-bold mb-0">Matching Equities & Tickers</h3>
                    <span class="badge bg-secondary-subtle text-secondary" id="stockCount">0 Found</span>
                </div>
                <div class="table-responsive">
                    <table class="mp-table align-middle" id="searchResultsTable">
                        <thead>
                            <tr>
                                <th>Symbol</th>
                                <th>Company</th>
                                <th>Exchange</th>
                                <th>Price</th>
                                <th>Change</th>
                                <th class="text-end">Details</th>
                            </tr>
                        </thead>
                        <tbody id="stockResultsBody">
                            <!-- Populated dynamically -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="assets/js/search.js"></script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
