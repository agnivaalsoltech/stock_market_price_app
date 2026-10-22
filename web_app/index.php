<?php
$pageTitle = 'MarketPulse - Real-time Stock Market Intelligence';
$currentPage = 'home';
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/includes/header.php';

$defaultCountry = 'Germany';
$countryData = $MARKET_COUNTRIES[$defaultCountry];
?>

<div class="container-fluid px-lg-4 py-4">
    <!-- Hero Banner -->
    <div class="mp-hero">
        <div class="row align-items-center">
            <div class="col-lg-7">
                <span class="badge bg-primary-subtle text-primary mb-3 px-3 py-2 fw-semibold">Global Financial Dashboard</span>
                <h1 class="display-5 fw-bold mb-3">Your Market. Your Data.</h1>
                <p class="lead text-white-50 mb-4">
                    Track real-time market indices, intelligent stock analytics, and breaking financial news tailored to your country and location.
                </p>
                <div class="d-flex gap-3 flex-wrap">
                    <a href="markets.php" class="btn mp-btn-primary btn-lg px-4">Explore Markets</a>
                    <a href="portfolio.php" class="btn btn-outline-light btn-lg px-4">Manage Portfolio</a>
                </div>
            </div>
            <div class="col-lg-5 d-none d-lg-block text-center">
                <img src="assets/images/market_hero.png" alt="MarketPulse Visualization" class="img-fluid rounded-4 shadow-lg border border-secondary" style="max-height: 280px; object-fit: cover;">
            </div>
        </div>
    </div>

    <!-- Country & Market Status Header -->
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
        <div>
            <h2 class="h4 fw-bold mb-1">
                <span id="countryFlag"><?php echo $countryData['flag']; ?></span>
                <span id="countryTitle"><?php echo $defaultCountry; ?></span> Market Overview
            </h2>
            <p class="text-muted small mb-0">
                Primary Exchange: <span id="exchangeTitle" class="fw-semibold"><?php echo $countryData['exchange']; ?></span> • 
                Status: <span class="mp-status-live">Market Open</span>
            </p>
        </div>
        <div class="d-flex align-items-center gap-2">
            <label for="countrySelectQuick" class="small text-muted fw-semibold">Switch Market:</label>
            <select id="countrySelectQuick" class="form-select form-select-sm" style="width: 170px;">
                <?php foreach ($MARKET_COUNTRIES as $cName => $c): ?>
                    <option value="<?php echo $cName; ?>" <?php echo ($cName === $defaultCountry) ? 'selected' : ''; ?>>
                        <?php echo $c['flag'] . ' ' . $cName; ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </div>
    </div>

    <!-- Main Market Indices Grid -->
    <div class="row g-3 mb-4" id="indicesContainer">
        <?php foreach ($countryData['indices'] as $idx): 
            $isPos = $idx['change'] >= 0;
        ?>
            <div class="col-12 col-sm-6 col-xl-4">
                <div class="mp-card h-100" style="cursor: pointer; transition: transform 0.2s ease, box-shadow 0.2s ease;" onclick="window.location.href='markets.php?country=<?php echo urlencode($defaultCountry); ?>'" title="View <?php echo htmlspecialchars($idx['name']); ?> in Markets">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase"><?php echo htmlspecialchars($idx['symbol']); ?></span>
                            <h3 class="h5 fw-bold mb-0"><?php echo htmlspecialchars($idx['name']); ?></h3>
                        </div>
                        <span class="<?php echo $isPos ? 'mp-badge-positive' : 'mp-badge-negative'; ?>">
                            <?php echo $isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>'; ?><?php echo number_format($idx['changePercent'], 2); ?>%
                        </span>
                    </div>
                    <div class="d-flex align-items-baseline gap-2 mt-2">
                        <span class="fs-3 fw-bold" data-base-price="<?php echo $idx['price']; ?>">
                            €<?php echo number_format($idx['price'], 2); ?>
                        </span>
                        <span class="small <?php echo $isPos ? 'text-success' : 'text-danger'; ?> fw-semibold">
                            <?php echo ($isPos ? '+' : '') . number_format($idx['change'], 2); ?>
                        </span>
                    </div>
                    <div class="mt-3 pt-2 border-top border-light d-flex justify-content-between small text-muted">
                        <span>Updated live</span>
                        <a href="markets.php?country=<?php echo urlencode($defaultCountry); ?>" class="fw-semibold text-primary text-decoration-none">View Index <i class="bi bi-arrow-right ms-1"></i></a>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    </div>

    <!-- Top Movers & News Section -->
    <div class="row g-4">
        <!-- Top Movers Column -->
        <div class="col-12 col-lg-7">
            <div class="mp-card">
                <div class="mp-card-header">
                    <h3 class="h5 fw-bold mb-0">Trending Stocks & Top Movers</h3>
                    <a href="markets.php" class="small fw-semibold text-primary text-decoration-none">View All Markets <i class="bi bi-arrow-right ms-1"></i></a>
                </div>
                <div class="table-responsive">
                    <table class="mp-table align-middle">
                        <thead>
                            <tr>
                                <th style="width: 32px;"></th>
                                <th>Symbol</th>
                                <th>Company</th>
                                <th>Price</th>
                                <th>24h Change</th>
                                <th class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody id="trendingStocksBody">
                            <?php 
                            $sampleStocks = array_slice($STOCKS, 0, 5, true);
                            foreach ($sampleStocks as $stk):
                                $isPos = $stk['change'] >= 0;
                            ?>
                                <tr onclick="window.location.href='stock.php?symbol=<?php echo urlencode($stk['symbol']); ?>'" style="cursor: pointer;">
                                    <td onclick="event.stopPropagation();">
                                        <button class="mp-star-btn" data-symbol="<?php echo htmlspecialchars($stk['symbol']); ?>" title="Toggle Watchlist">
                                            <i class="bi bi-star"></i>
                                        </button>
                                    </td>
                                    <td>
                                        <a href="stock.php?symbol=<?php echo urlencode($stk['symbol']); ?>" class="fw-bold text-dark text-decoration-none">
                                            <?php echo htmlspecialchars($stk['symbol']); ?>
                                        </a>
                                    </td>
                                    <td>
                                        <div class="fw-semibold"><?php echo htmlspecialchars($stk['companyName']); ?></div>
                                        <div class="small text-muted"><?php echo htmlspecialchars($stk['sector']); ?></div>
                                    </td>
                                    <td>
                                        <span class="fw-bold" data-base-price="<?php echo $stk['price']; ?>">
                                            €<?php echo number_format($stk['price'], 2); ?>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="<?php echo $isPos ? 'mp-badge-positive' : 'mp-badge-negative'; ?>">
                                            <?php echo $isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>'; ?><?php echo number_format($stk['changePercent'], 2); ?>%
                                        </span>
                                    </td>
                                    <td class="text-end" onclick="event.stopPropagation();">
                                        <a href="stock.php?symbol=<?php echo urlencode($stk['symbol']); ?>" class="btn btn-sm btn-outline-primary">
                                            Details <i class="bi bi-arrow-right ms-1"></i>
                                        </a>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- News Snapshot Column -->
        <div class="col-12 col-lg-5">
            <div class="mp-card">
                <div class="mp-card-header">
                    <h3 class="h5 fw-bold mb-0">Market News Snapshot</h3>
                    <span class="badge bg-secondary-subtle text-secondary">Real-time Feed</span>
                </div>
                <div class="d-flex flex-column">
                    <?php 
                    $sampleNews = array_slice($NEWS_FEED, 0, 4);
                    foreach ($sampleNews as $n):
                    ?>
                        <div class="mp-news-card" onclick="openArticleModal('<?php echo addslashes(htmlspecialchars($n['title'])); ?>', '<?php echo addslashes(htmlspecialchars($n['source'])); ?>', '<?php echo addslashes(htmlspecialchars($n['time'])); ?>', '<?php echo addslashes(htmlspecialchars($n['symbol'])); ?>', '<?php echo addslashes(htmlspecialchars($n['summary'])); ?>', '<?php echo htmlspecialchars($n['url']); ?>')" style="cursor: pointer;">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <a href="stock.php?symbol=<?php echo urlencode($n['symbol']); ?>" class="badge bg-light text-dark border text-decoration-none" onclick="event.stopPropagation();" title="View <?php echo htmlspecialchars($n['symbol']); ?> stock details">
                                    <?php echo htmlspecialchars($n['symbol']); ?>
                                </a>
                                <span class="small text-muted"><?php echo htmlspecialchars($n['time']); ?> • <?php echo htmlspecialchars($n['source']); ?></span>
                            </div>
                            <h4 class="h6 fw-bold mb-1">
                                <span class="text-body text-decoration-none">
                                    <?php echo htmlspecialchars($n['title']); ?>
                                </span>
                            </h4>
                            <p class="small text-muted mb-2"><?php echo htmlspecialchars($n['summary']); ?></p>
                            <button type="button" class="btn btn-sm btn-outline-primary py-1 px-2 fw-semibold" onclick="event.stopPropagation(); openArticleModal('<?php echo addslashes(htmlspecialchars($n['title'])); ?>', '<?php echo addslashes(htmlspecialchars($n['source'])); ?>', '<?php echo addslashes(htmlspecialchars($n['time'])); ?>', '<?php echo addslashes(htmlspecialchars($n['symbol'])); ?>', '<?php echo addslashes(htmlspecialchars($n['summary'])); ?>', '<?php echo htmlspecialchars($n['url']); ?>')" style="font-size: 0.78rem;">
                                Read Full Article <i class="bi bi-arrow-right ms-1"></i>
                            </button>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="assets/js/home.js"></script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
