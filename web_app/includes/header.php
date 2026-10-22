<?php
if (!isset($pageTitle)) {
    $pageTitle = 'MarketPulse - Global Stock Market Dashboard';
}
if (!isset($currentPage)) {
    $currentPage = 'home';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($pageTitle); ?></title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <!-- Custom Stylesheet -->
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <!-- Global Navigation -->
    <nav class="navbar navbar-expand-lg mp-navbar sticky-top">
        <div class="container-fluid px-lg-4">
            <a class="navbar-brand mp-brand" href="index.php">
                <img src="assets/images/logo.png" alt="MarketPulse Logo" width="34" height="34">
                <span>MarketPulse</span>
            </a>
            
            <button class="navbar-toggler text-white border-secondary" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon" style="filter: invert(1);"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarContent">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-3">
                    <li class="nav-item">
                        <a class="nav-link mp-nav-link <?php echo ($currentPage === 'home') ? 'active' : ''; ?>" href="index.php">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link mp-nav-link <?php echo ($currentPage === 'markets') ? 'active' : ''; ?>" href="markets.php">Markets</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link mp-nav-link <?php echo ($currentPage === 'portfolio') ? 'active' : ''; ?>" href="portfolio.php">Portfolio</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link mp-nav-link <?php echo ($currentPage === 'pro') ? 'active' : ''; ?>" href="pro.php">Pro</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link mp-nav-link <?php echo ($currentPage === 'search') ? 'active' : ''; ?>" href="search.php">Search</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link mp-nav-link <?php echo ($currentPage === 'profile') ? 'active' : ''; ?>" href="profile.php">Profile</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link mp-nav-link <?php echo ($currentPage === 'kyc') ? 'active' : ''; ?>" href="kyc.php">KYC</a>
                    </li>
                </ul>

                <div class="d-flex align-items-center gap-3 flex-wrap">
                    <!-- Twelve Data API Live Status Button -->
                    <?php $twelveDataActive = TwelveDataService::isConfigured(); ?>
                    <button type="button" class="btn btn-sm <?php echo $twelveDataActive ? 'btn-outline-success' : 'btn-outline-secondary'; ?> text-white small d-inline-flex align-items-center gap-1 border-0" data-bs-toggle="modal" data-bs-target="#apiSettingsModal" title="Twelve Data Live API Settings">
                        <i class="bi bi-broadcast <?php echo $twelveDataActive ? 'text-success' : 'text-warning'; ?>"></i>
                        <span class="d-none d-md-inline"><?php echo $twelveDataActive ? 'Twelve Data Live' : 'API Key'; ?></span>
                    </button>

                    <!-- Country Market Switcher Dropdown in Navbar -->
                    <div class="d-flex align-items-center">
                        <label for="mpNavbarCountrySelect" class="text-white-50 small me-1 d-none d-lg-inline"><i class="bi bi-geo-alt-fill text-danger me-1"></i>Market:</label>
                        <select id="mpNavbarCountrySelect" class="form-select form-select-sm bg-dark text-white border-secondary" style="width: auto; min-width: 125px;" title="Switch Country Market (automatically updates market data and currency)">
                            <?php if (isset($MARKET_COUNTRIES)): foreach ($MARKET_COUNTRIES as $cName => $c): ?>
                                <option value="<?php echo $cName; ?>" data-currency="<?php echo $c['currency']; ?>">
                                    <?php echo $c['flag'] . ' ' . $cName; ?>
                                </option>
                            <?php endforeach; endif; ?>
                        </select>
                        <button type="button" id="mpLocationBadge" class="d-none" data-bs-toggle="modal" data-bs-target="#countrySwitcherModal"></button>
                    </div>

                    <!-- Currency Switcher -->
                    <div class="d-flex align-items-center">
                        <label for="mpCurrencySelect" class="text-white-50 small me-2">Curr:</label>
                        <select id="mpCurrencySelect" class="form-select form-select-sm bg-dark text-white border-secondary" style="width: 85px;">
                            <option value="EUR">EUR (€)</option>
                            <option value="USD">USD ($)</option>
                            <option value="GBP">GBP (£)</option>
                            <option value="INR">INR (₹)</option>
                        </select>
                    </div>

                    <!-- Theme Toggle (Dark/Light) -->
                    <button id="mpThemeToggle" class="btn btn-sm btn-outline-light px-2" title="Toggle Dark / Light Theme" aria-label="Toggle Theme">
                        <i class="bi bi-moon-stars-fill"></i>
                    </button>

                    <!-- Sign In / Profile Container -->
                    <div id="mpAuthNavContainer" class="d-inline-block">
                        <a id="mpAuthNav" href="auth.php" class="btn btn-sm btn-outline-light <?php echo ($currentPage === 'auth') ? 'active' : ''; ?>">
                            Sign In
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </nav>

    <!-- Global Country Switcher Modal -->
    <div class="modal fade" id="countrySwitcherModal" tabindex="-1" aria-labelledby="countrySwitcherModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="countrySwitcherModalLabel"><i class="bi bi-globe-americas me-2 text-primary"></i> Switch Country Market</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-0">
                    <div class="list-group list-group-flush">
                        <?php if (isset($MARKET_COUNTRIES)): foreach ($MARKET_COUNTRIES as $cName => $c): ?>
                            <a href="markets.php?country=<?php echo urlencode($cName); ?>" onclick="if(window.MarketPulse) MarketPulse.setCountry('<?php echo $cName; ?>', true);" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3 px-4">
                                <div class="d-flex align-items-center gap-3">
                                    <span class="fs-3"><?php echo $c['flag']; ?></span>
                                    <div>
                                        <div class="fw-bold fs-6"><?php echo $cName; ?></div>
                                        <div class="small text-muted"><?php echo $c['exchange']; ?> • <?php echo $c['currency']; ?></div>
                                    </div>
                                </div>
                                <span class="badge bg-primary-subtle text-primary rounded-pill px-3 py-2 fw-semibold">View Market <i class="bi bi-arrow-right ms-1"></i></span>
                            </a>
                        <?php endforeach; endif; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <main class="flex-grow-1">
