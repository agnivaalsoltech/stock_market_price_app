    </main>
    <footer class="mp-footer mt-5">
        <div class="container-fluid px-lg-4">
            <div class="row g-4 mb-4">
                <div class="col-12 col-md-4">
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <img src="assets/images/logo.png" alt="MarketPulse" width="28" height="28" class="rounded">
                        <span class="text-white fw-bold fs-5">MarketPulse</span>
                    </div>
                    <p class="small text-secondary mb-3">Real-time financial intelligence, country market indexing, and intelligent portfolio analytics built with modern web technologies.</p>
                    <div class="d-flex gap-2">
                        <span class="badge bg-success-subtle text-success border border-success-subtle"><i class="bi bi-broadcast me-1"></i> Live Data Active</span>
                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle"><i class="bi bi-cpu me-1"></i> HTML5 • PHP • Chart.js</span>
                    </div>
                </div>
                <div class="col-6 col-md-2">
                    <h6 class="text-white small fw-bold text-uppercase mb-3">Markets</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="markets.php?country=Germany">Germany (DAX)</a></li>
                        <li class="mb-2"><a href="markets.php?country=USA">USA (S&P 500)</a></li>
                        <li class="mb-2"><a href="markets.php?country=United%20Kingdom">UK (FTSE 100)</a></li>
                        <li class="mb-2"><a href="markets.php?country=India">India (NIFTY 50)</a></li>
                    </ul>
                </div>
                <div class="col-6 col-md-2">
                    <h6 class="text-white small fw-bold text-uppercase mb-3">Platform</h6>
                    <ul class="list-unstyled small">
                        <li class="mb-2"><a href="index.php">Home Overview</a></li>
                        <li class="mb-2"><a href="portfolio.php">My Portfolio</a></li>
                        <li class="mb-2"><a href="pro.php">Pro Membership</a></li>
                        <li class="mb-2"><a href="search.php">Market Explorer</a></li>
                    </ul>
                </div>
                <div class="col-12 col-md-4">
                    <h6 class="text-white small fw-bold text-uppercase mb-3">Quick Stock Search</h6>
                    <form action="search.php" method="GET" class="d-flex gap-2">
                        <input type="text" name="q" class="form-control form-control-sm bg-dark text-white border-secondary" placeholder="e.g. SAP, BMW, Apple, Germany...">
                        <button type="submit" class="btn btn-sm btn-primary d-inline-flex align-items-center gap-1"><i class="bi bi-search"></i> Search</button>
                    </form>
                    <p class="small text-secondary mt-2 mb-0">Multi-currency exchange supported: EUR, USD, GBP, INR.</p>
                </div>
            </div>
            <div class="border-top border-secondary pt-3 d-flex flex-wrap justify-content-between align-items-center small text-secondary">
                <span>© <?php echo date('Y'); ?> MarketPulse Inc. All rights reserved.</span>
                <span>Designed for Academic Presentation & Stock Market Demonstration.</span>
            </div>
        </div>
    </footer>

    <!-- Universal Full Article Reader Modal -->
    <div class="modal fade" id="articleReaderModal" tabindex="-1" aria-labelledby="articleReaderModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content shadow-lg border-0">
                <div class="modal-header border-bottom">
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-primary" id="readerSymbol">SAP</span>
                        <span class="badge bg-success-subtle text-success border border-success-subtle small"><i class="bi bi-patch-check-fill me-1"></i> Verified Story</span>
                        <span class="small text-muted ms-2" id="readerMeta">Financial Times • 15m ago</span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <h3 class="h4 fw-bold mb-3 text-body" id="readerTitle"></h3>
                    <div class="p-3 rounded bg-body-tertiary border mb-3">
                        <p class="mb-0 fw-semibold text-body" id="readerSummary"></p>
                    </div>
                    <div class="article-expanded-body text-body-secondary small lh-lg mb-4">
                        <p>Institutional trading desks and asset managers noted heightened liquidity and steady order flow across key European and US exchanges following today's report. Sector leadership reflects sustained enterprise capital commitment and disciplined cost management.</p>
                        <p>Market analysts continue to monitor cross-asset volume trends and forward guidance indicators to assess upcoming valuation adjustments and earnings momentum.</p>
                    </div>
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 pt-3 border-top">
                        <a href="stock.php?symbol=SAP" id="readerStockLink" class="btn btn-sm btn-outline-primary">
                            <i class="bi bi-graph-up me-1"></i> View Stock Details
                        </a>
                        <a href="#" id="readerExternalLink" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-primary">
                            <i class="bi bi-box-arrow-up-right me-1"></i> Open Publisher Source
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Core App JS -->
    <script src="assets/js/app.js"></script>
</body>
</html>
